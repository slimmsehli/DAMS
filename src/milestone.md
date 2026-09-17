# AMS Wrapper — Elaboration Milestones

This project starts as a netlist-only elaboration tool for a future open-source AMS simulator wrapper. The first milestone does not require Verilator compilation, ngspice, or simulation setup.

## M0 — Create the C++ project skeleton

- [ ] Create CMake project structure.
- [ ] Add `include/ams`, `src`, `tests`, and `examples` directories.
- [ ] Add a minimal CLI: `amswrap elaborate`.
- [ ] Add a diagnostic type with file, line, severity, and message.
- [ ] Add a JSON writer for reports.

## M1 — Define the shared internal model

- [ ] Define `Domain`: `Digital`, `Analog`, `Unknown`.
- [ ] Define `PortDirection`: `Input`, `Output`, `Inout`, `Unknown`.
- [ ] Define `Port`, `Instance`, `PortConnection`, and `Definition`.
- [ ] Define `DesignDatabase` with digital modules and SPICE subcircuits.
- [ ] Add source-location tracking.
- [ ] Write unit tests for constructing and querying the model.

## M2 — Parse Verilog file lists (`.f`)

- [ ] Read source file paths.
- [ ] Support comments and blank lines.
- [ ] Resolve paths relative to the `.f` file.
- [ ] Support nested `-f` file lists.
- [ ] Support `+incdir+`.
- [ ] Support `+define+`.
- [ ] Detect repeated or recursive `.f` inclusion.
- [ ] Export `resolved_filelist.json`.
- [ ] Add unit tests.

## M3 — Parse SPICE hierarchy

- [ ] Read `.sp`, `.spi`, and `.cir` files.
- [ ] Support comments and continuation lines.
- [ ] Extract `.subckt` names.
- [ ] Extract ordered `.subckt` port names.
- [ ] Extract `X...` subcircuit instances.
- [ ] Support `.include` and `.lib`.
- [ ] Detect missing `.ends`.
- [ ] Detect duplicate `.subckt` definitions.
- [ ] Export `spice_definitions.json`.
- [ ] Add a test with an inverter and nested analog hierarchy.

## M4 — Extract Verilog modules and instances

- [ ] Choose the digital frontend; start with Verilator metadata/XML.
- [ ] Extract module definitions.
- [ ] Extract `input`, `output`, and `inout` ports.
- [ ] Extract instance names and type names.
- [ ] Extract named port connections.
- [ ] Extract positional port connections.
- [ ] Preserve source locations where available.
- [ ] Export `digital_definitions.json`.
- [ ] Test with nested digital modules and one unresolved analog instance.

## M5 — Build and classify the hierarchy

- [ ] Select a user-specified digital top module.
- [ ] Build a tree of fully qualified paths, such as `top.u_latch.u_storage`.
- [ ] Classify instances as digital or analog.
- [ ] Report unresolved instances.
- [ ] Report ambiguous names defined in both Verilog and SPICE.
- [ ] Detect recursive instantiation loops.
- [ ] Export `hierarchy.json`.
- [ ] Generate `hierarchy.dot`.
- [ ] Test a digital latch containing an analog inverter instance.

## M6 — Define and parse the boundary manifest

- [ ] Choose YAML or JSON; YAML is easier to hand-edit.
- [ ] Identify each analog instance by full hierarchical path.
- [ ] Specify each analog port as `d2a`, `a2d`, `inout`, `supply`, or `ground`.
- [ ] Allow D2A parameters: `vlow`, `vhigh`, rise/fall time.
- [ ] Allow A2D parameters: `vil`, `vih`, hysteresis.
- [ ] Validate manifest syntax and duplicate entries.
- [ ] Export normalized `boundaries.json`.

## M7 — Validate boundaries

- [ ] Confirm the instance path exists in the hierarchy.
- [ ] Confirm it is classified as analog.
- [ ] Confirm every declared SPICE port exists.
- [ ] Confirm every connected digital signal exists in the parent scope.
- [ ] Check D2A direction against Verilog port declarations where possible.
- [ ] Check A2D direction against Verilog port declarations where possible.
- [ ] Require explicit handling of supply and ground pins.
- [ ] Warn for unclassified analog ports.
- [ ] Fail on invalid or incomplete ordinary signal boundaries.

## M8 — Generate Verilog analog stubs

- [ ] Generate one module per referenced SPICE `.subckt`.
- [ ] Preserve SPICE subcircuit port order.
- [ ] Use manifest direction to emit `input`, `output`, or `inout`.
- [ ] Add a generated-file header: “Do not edit.”
- [ ] Write to `build/elab/generated/analog_stubs.sv`.
- [ ] Compile the original RTL plus generated stubs with Verilator lint.
- [ ] Add golden-file tests for generated stub text.

## M9 — Complete elaboration command

- [ ] Implement:

  ```text
  amswrap elaborate --filelist design.f --spice analog.spi --top top --boundary boundary.yaml --out build/elab
  ```

- [ ] Produce all reports in one run.
- [ ] Return nonzero on validation errors.
- [ ] Return clear diagnostics with source location.
- [ ] Add an end-to-end D-latch → SPICE inverter example.
- [ ] Add CI test that runs the full elaboration flow.

## M10 — Freeze the netlist-only milestone

- [ ] Confirm no Verilator model compilation is required for parsing/elaboration.
- [ ] Confirm no ngspice library is required.
- [ ] Document supported syntax and deliberate limitations.
- [ ] Tag the result as `v0.1-elaboration`.

## Future work

The following are intentionally outside the netlist-only milestone:

- [ ] M11 — Verilator runtime adapter.
- [ ] M12 — ngspice shared-library adapter.
- [ ] M13 — D2A and A2D bridge implementations.
- [ ] M14 — Digital/analog time synchronization.
- [ ] M15 — Combined waveform output and regression tests.
