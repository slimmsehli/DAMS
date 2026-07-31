#!/bin/sh -f

# using gcc 13.0
# using python 3.13.0

git clone https://github.com/verilator/verilator.git
cd verilator

export VERILATOR_ROOT=`pwd`

# configure
autoconf         # Create ./configure script
./configure --prefix $PWD/installation  # Configure and create Makefile

# compile
make -j`nproc`  # Build Verilator itself (if error, try just 'make')

# test compilation
make test

# install
sudo make install -j`nproc` 

unsetenv VERILATOR_ROOT
setenv PATH $PWD/installation/bin:$PATH
