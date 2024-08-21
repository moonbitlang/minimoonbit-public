#!/usr/bin/env bash

pushd libriscv/emulator
./build.sh --no-C --native --64 -b -v
popd
ln -fs libriscv/emulator/.build/rvlinux .
