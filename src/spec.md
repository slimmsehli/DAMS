# AMS Wrapper — Netlist Elaboration Specification

## 1. Purpose

`amswrap` is an open-source C++ tool that prepares a mixed-signal design for a later Verilator + ngspice co-simulation flow.

The first release, **v0.1-elaboration**, does not simulate. Given a Verilog/SystemVerilog file list and a SPICE netlist, it must:

1. discover digital modules and analog `.subckt` definitions;
2. build the digital instance hierarchy from a selected top module;
3. classify every instance as digital, analog, unresolved, or ambiguous;
4. validate explicitly declared analog/digital boundaries; and
5. produce generated Verilog stubs for analog blocks and machine-readable reports.

The implementation is split into independent milestones below. A milestone is complete only when its stated output and acceptance checks pass.

## 2. Supported command

The completed elaboration command shall be:

```text
amswrap elaborate \
  --filelist <design.f> \
  --spice <top.spi> \
  --top <digital_top_module> \
  --boundary <boundary.yaml> \
  --out <output_directory>
```

The boundary file is optional until M6. Before M6, the command may omit `--boundary` and only report candidate crossings.

On success, `<output_directory>` shall contain:

```text
resolved_filelist.json
spice_definitions.json
digital_definitions.json
hierarchy.json
hierarchy.dot
partitions.json
boundaries.json
generated/analog_stubs.sv
diagnostics.txt
```

Only reports relevant to a completed milestone need to exist during early development.

## 3. General engineering rules

- Use C++20 and CMake.
- Keep parsing, database construction, hierarchy creation, validation, and code generation in separate components.
- Parsers must not generate Verilog or make simulation decisions.
- Every object derived from a source file should retain a source location: path, line, and column when known.
- All fatal input errors must produce a readable diagnostic and a non-zero process exit code.
- Never silently guess electrical direction from a SPICE pin name such as `in`, `out`, `vdd`, or `gnd`.
- Tests must use only files stored under `tests/` or `examples/`; no installed simulator is required through M10.

Recommended source layout:

```text
include/ams/
  diagnostic.hpp
  source_location.hpp
  design_db.hpp
  filelist_parser.hpp
  spice_parser.hpp
  verilog_frontend.hpp
  hierarchy_builder.hpp
  boundary_manifest.hpp
  partition_analyzer.hpp
  stub_generator.hpp
src/
tests/
examples/
```

## M0 — Project skeleton

### Objective

Create a buildable C++ project and a single command-line entry point.

### Required implementation

- Add a root `CMakeLists.txt` that builds an `amswrap` executable.
- Create `include/ams`, `src`, `tests`, and `examples` directories.
- Implement `amswrap elaborate --help`.
- Add `Diagnostic { severity, message, SourceLocation }` and a diagnostic collector.
- Add a small JSON output utility. Any dependency is acceptable if its license is compatible and it is documented.

### Inputs and outputs

- Input: command-line arguments only.
- Output: help text; an empty JSON document may be written for a smoke test.

### Completion checks

- [ ] `cmake --build` succeeds on the supported host.
- [ ] `amswrap elaborate --help` exits with code 0.
- [ ] An unknown option exits non-zero and produces one diagnostic.

## M1 — Shared design database

### Objective

Define the only internal data model shared by all later phases.

### Required implementation

Implement at least these concepts:

```cpp
enum class Domain { Digital, Analog, Unknown };
enum class PortDirection { Input, Output, Inout, Unknown };

struct SourceLocation { std::filesystem::path file; int line; int column; };
struct Port { std::string name; PortDirection direction; std::optional<int> width; SourceLocation location; };
struct PortConnection { std::optional<std::string> formal; std::string actual; SourceLocation location; };
struct Instance { std::string name; std::string type_name; std::vector<PortConnection> connections; SourceLocation location; };
struct Definition { std::string name; Domain domain; std::vector<Port> ports; std::vector<Instance> instances; SourceLocation location; };
```

`DesignDatabase` shall store digital modules and SPICE subcircuits in separate maps keyed by definition name. It shall expose lookup methods that report whether a type is digital, analog, missing, or defined in both domains.

### Completion checks

- [ ] A unit test can add and retrieve one digital module and one analog subcircuit.
- [ ] A duplicate definition in one domain produces a diagnostic.
- [ ] A definition present in both domains is detectable as ambiguous.

## M2 — Verilog file-list parser

### Objective

Resolve a `.f` file into a deterministic list of RTL source files and compile options.

### Supported syntax

- A source-file path on its own line.
- `-f <other.f>` and `-f<other.f>`.
- `+incdir+<dir>[+<dir>...]`.
- `+define+<name>[=<value>][+<name>...]`.
- Blank lines and lines beginning with `#` or `//`.

All relative paths are relative to the file that contains the reference, not the process working directory.

### Required output

Create `VerilogSourceSet` containing source files, include directories, and defines. Write `resolved_filelist.json` with normalized paths and the order in which source files were discovered.

### Error rules

- A missing referenced file is fatal.
- A recursive nested file list is fatal and must show the include chain.
- Repeated source files may be deduplicated, but preserve the first occurrence and emit a warning.

### Completion checks

- [ ] A flat file list resolves correctly.
- [ ] A nested list resolves paths relative to its own directory.
- [ ] Include directories and defines are captured.
- [ ] A recursive `-f` reference fails predictably.

## M3 — SPICE parser and analog definition database

### Objective

Extract enough SPICE structure to discover analog subcircuits and their instance hierarchy. This is not a full SPICE simulator parser.

### Supported syntax

- `.subckt <name> <ordered ports...>`.
- `.ends` and `.ends <name>`.
- `X<instance> <nodes...> <subckt_name>` instance cards.
- `.include <path>` and `.lib <path> [section]`.
- Whole-line `*` comments, `$` comments, and continuation lines beginning with `+`.
- Case-insensitive SPICE keywords; preserve original names in reports.

### Required behavior

For every `.subckt`, store its ordered port list and contained `X` instances. Expand included files recursively. A SPICE port direction is always `Unknown` unless supplied later in the boundary manifest.

### Error rules

- Nested `.subckt` declarations are fatal.
- An `.ends` without an open `.subckt`, or an unclosed `.subckt`, is fatal.
- Duplicate subcircuit names are fatal unless a future explicit library-precedence policy is implemented.
- Unknown primitive cards are allowed; they are not hierarchy instances.

### Completion checks

- [ ] Parse an inverter subcircuit with ordered ports.
- [ ] Parse a filter that instantiates resistor/capacitor wrapper subcircuits.
- [ ] Parse a top-level analog block that instantiates those blocks.
- [ ] Resolve an included file.
- [ ] Write `spice_definitions.json`.

## M4 — Digital module extraction

### Objective

Extract module definitions, ports, and instances from the resolved RTL set.

### Required implementation

Use a maintained SystemVerilog frontend rather than implementing the language grammar. The preferred initial implementation is a Verilator metadata/XML adapter. The adapter must convert the frontend result into `Definition`, `Port`, and `Instance` objects in `DesignDatabase`.

The adapter must extract module names; `input`, `output`, and `inout` directions; scalar or known packed-vector widths; instance names and type names; named and positional port connections; and source locations where available.

### Boundaries and limitations

The initial version may reject unsupported constructs with a clear error, rather than guessing. Examples include generated hierarchy whose instance names cannot be resolved, parameter-dependent port lists, and unresolved macros.

### Completion checks

- [ ] Extract a module with all three port directions.
- [ ] Extract nested digital instances.
- [ ] Extract an instance whose type does not exist in RTL; it must remain unresolved for M5.
- [ ] Write `digital_definitions.json`.

## M5 — Hierarchy construction and domain classification

### Objective

Construct the instance tree beneath `--top` and classify every child instance.

### Classification rule

```text
T in digital definitions only  => Digital
T in analog definitions only   => Analog
T in both definition sets      => Ambiguous (fatal)
T in neither definition set    => Unresolved (fatal)
```

### Required behavior

- Start at the digital module named by `--top`.
- Create a fully qualified path for each node, for example `ms_alarm_top.u_controller.u_debounce.u_counter`.
- Recursively expand digital instances.
- Keep analog instances as leaf partition nodes in this release; their internal SPICE hierarchy remains available through `spice_definitions.json`.
- Detect a recursive digital instantiation cycle and report its complete path.
- Write a JSON tree and a Graphviz DOT graph.

### Completion checks

- [ ] The `examples/ms_alarm` design produces the documented hierarchy.
- [ ] Analog instances are leaves labelled `Analog`.
- [ ] An unresolved cell produces a source-located error.
- [ ] A name defined in both analog and digital libraries produces an ambiguity error.
- [ ] `hierarchy.json` and `hierarchy.dot` are written.

## M6 — Boundary-manifest parser

### Objective

Read the explicit source of truth for analog/digital bridge intent.

### Required format

Support YAML first. The minimum schema is:

```yaml
instances:
  ms_alarm_top.u_output.u_driver:
    en:
      direction: d2a
      vlow: 0.0
      vhigh: 1.8
    vout:
      direction: analog
    vdd:
      direction: supply
    vss:
      direction: ground
```

Allowed direction values are `d2a`, `a2d`, `inout`, `analog`, `supply`, and `ground`.

### Required behavior

Normalize all entries into a `BoundaryPort` record containing instance path, SPICE port name, direction, and optional bridge parameters. Write this representation as `boundaries.json`.

### Error rules

- Missing `direction` is fatal.
- Duplicate instance/port entries are fatal.
- `d2a` requires `vlow` and `vhigh`.
- `a2d` requires `vil` and `vih`.
- Unknown YAML fields may warn, but must not silently alter behavior.

### Completion checks

- [ ] Parse a D2A boundary.
- [ ] Parse an A2D boundary with thresholds.
- [ ] Reject malformed or duplicate entries.
- [ ] Write normalized `boundaries.json`.

## M7 — Partition and boundary validation

### Objective

Validate that the manifest correctly describes real analog instances and real Verilog connections.

### Required behavior

For every manifest entry:

1. find the hierarchy instance by full path;
2. require that instance to be Analog;
3. find the named port in its resolved SPICE subcircuit;
4. find the corresponding Verilog connection on the analog instance;
5. record the parent-scope digital signal connected to it; and
6. validate any direction information that Verilog can prove.

The tool must report unclassified SPICE ports on an analog instance. All power and ground ports must be explicitly listed as `supply` or `ground`; ordinary signal pins must be `d2a`, `a2d`, `inout`, or deliberately `analog`.

### Direction rules

- SPICE alone never determines a port direction.
- A D2A connection should not target a Verilog `input` of the analog stub from the parent perspective unless its driving digital net is valid.
- An A2D connection must not create a known multiple-driver conflict in RTL.
- When direction cannot be proven, warn and retain the explicit manifest value.

### Required output

Write `partitions.json`: analog instance path, referenced SPICE subcircuit, each connected RTL signal, and its declared boundary role.

### Completion checks

- [ ] Validate `ms_alarm_top.u_frontend.u_threshold.vout` as A2D.
- [ ] Validate `ms_alarm_top.u_output.u_driver.en` as D2A.
- [ ] Reject a manifest port absent from the SPICE subcircuit.
- [ ] Reject a hierarchy path absent from the design.
- [ ] Warn about an unclassified non-supply SPICE port.

## M8 — Analog Verilog-stub generation

### Objective

Generate compilable placeholder SystemVerilog module definitions for analog subcircuits referenced by the digital hierarchy.

### Required behavior

- Generate a stub only for analog subcircuits actually instantiated beneath `--top`.
- Use the SPICE subcircuit name as the generated module name for this example flow.
- Preserve SPICE port order in the module declaration.
- Select `input`, `output`, or `inout` from the validated boundary manifest.
- Map `analog`, `supply`, and `ground` to the conservative port declaration documented by the generator. For v0.1, use `input logic` for supply/ground and `inout wire` for untyped analog-only nodes.
- Include a banner saying the output is generated and must not be edited.
- Write one deterministic file: `generated/analog_stubs.sv`.

### Completion checks

- [ ] The generated stub has every SPICE port once and in the original order.
- [ ] The stub uses manifest directions for A2D/D2A ports.
- [ ] Generation is deterministic: two runs produce identical content.
- [ ] Golden-file tests compare expected and actual output.

## M9 — End-to-end elaboration command

### Objective

Connect M1 through M8 into one reliable command.

### Required execution order

1. Parse command-line options.
2. Resolve the file list.
3. Parse SPICE and all includes.
4. Extract digital definitions.
5. Build and classify the hierarchy.
6. Parse and validate the boundary manifest, if supplied.
7. Generate reports and analog stubs.
8. Print a concise summary: top module, number of digital modules, analog subcircuits, instances, boundaries, warnings, and errors.

Never generate a stub or report that claims successful validation when fatal diagnostics exist.

### Completion checks

- [ ] Run the documented command against `examples/ms_alarm`.
- [ ] All report files are created.
- [ ] Invalid input returns non-zero.
- [ ] Every error includes an actionable message and source location where available.
- [ ] Add this end-to-end command to CI.

## M10 — v0.1-elaboration release criteria

### Objective

Freeze the parser/elaboration milestone before adding simulator integration.

### Required documentation

- List supported `.f`, SPICE, SystemVerilog, and manifest syntax.
- List unsupported constructs and their diagnostics.
- Describe all generated report formats.
- Document the `examples/ms_alarm` input and expected hierarchy.

### Completion checks

- [ ] No ngspice shared library is linked or required.
- [ ] No Verilator C++ model is compiled or run as part of elaboration.
- [ ] A clean checkout builds and runs the example using only declared development dependencies.
- [ ] Tag the completed result `v0.1-elaboration`.

## Future milestones

The following work is intentionally out of scope until M10 is complete:

- M11: Verilator runtime adapter.
- M12: ngspice shared-library adapter.
- M13: D2A and A2D bridge models.
- M14: lockstep time synchronization and convergence handling.
- M15: merged waveform output and co-simulation regression tests.
