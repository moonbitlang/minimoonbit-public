#!/usr/bin/env bash

pushd riscv_rt
zig build
popd
ln -fs riscv_rt/zig-out/bin/rvelf .
