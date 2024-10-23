# Build rvlinux
FROM ubuntu:24.04 AS rvlinux-build


# Install libriscv
RUN apt-get update
RUN apt-get install -y gcc g++ make git cmake python3 python3-pip
WORKDIR /root/
RUN git clone https://github.com/lynzrand/libriscv.git 
WORKDIR /root/libriscv/emulator
RUN ./build.sh --native --64 -b -v
# output at .build/rvlinux


FROM ubuntu:24.04 as moonbit-build

RUN apt-get update 
RUN apt-get install -y curl tar xz-utils wget git jq binutils

# Install nodejs
RUN wget https://nodejs.org/dist/v22.10.0/node-v22.10.0-linux-x64.tar.xz -O /tmp/node-v22.10.0-linux-x64.tar.xz \
    && tar -xJf /tmp/node-v22.10.0-linux-x64.tar.xz -C /usr/local --strip-components=1 \
    && rm /tmp/node-v22.10.0-linux-x64.tar.xz

RUN mkdir -p /root/.zig /root/.moon/bin /root/bin

# Install MoonBit toolchain
RUN curl -fsSL https://cli.moonbitlang.cn/install/unix.sh | bash -s minimoonbit

# Install zig toolchain
RUN curl -fsSL https://ziglang.org/download/0.13.0/zig-linux-x86_64-0.13.0.tar.xz | tar -xJf - -C /root/.zig --strip-components 1

# Install wasm-tools
RUN wget https://github.com/bytecodealliance/wasm-tools/releases/download/v1.219.1/wasm-tools-1.219.1-x86_64-linux.tar.gz -O /tmp/wasm-tools.tar.gz \
    && tar -xzf /tmp/wasm-tools.tar.gz -C /root/bin --strip-components=1 \
    && rm /tmp/wasm-tools.tar.gz

# Copy libriscv emulator
COPY --from=rvlinux-build /root/libriscv/emulator/.build /root/libriscv/emulator/.build

# Add ~/.moon/bin and ~/.zig to PATH
ENV PATH="/root/libriscv/emulator/.build:/root/.moon/bin:/root/bin:/root/.zig:${PATH}"

RUN moon update

# Zig build environment
FROM moonbit-build AS zig-build

COPY ./riscv_rt /root/riscv_rt
WORKDIR /root/riscv_rt
RUN zig build

# Build example implementation
FROM moonbit-build as example-build
WORKDIR /app

# No example implementation provided in public repository
# COPY . .
# RUN moon build

# Pre-install common build dependencies
WORKDIR /tmp
RUN moon new foo
WORKDIR /tmp/foo
# RUN moon add moonbitlang/x
RUN moon add lijunchen/unstable_io 
RUN moon add Yoorkin/ArgParser 
RUN moon add Yoorkin/trie
RUN moon check

FROM moonbit-build

COPY --from=zig-build /root/riscv_rt/zig-out/lib/libmincaml.a /riscv_rt/libmincaml.a

# Check MoonBit version
RUN moon version --all
# Check Zig version
RUN zig version
# Check node version
RUN node --version

# Prebuild libc
RUN echo "int main() { return 0; }" > /tmp/main.c
RUN zig build-exe -target riscv64-linux -femit-bin=/tmp/main /tmp/main.c -fno-strip -mcpu=baseline_rv64
RUN rm /tmp/main.c /tmp/main

# Check libriscv version
RUN rvlinux --help

# Check wasm-tools version
RUN wasm-tools --version

## Copy example implementation
# Not copied due to being public repository
# COPY --from=example-build /app/target/wasm-gc/release/build/bin/bin.wasm /example/bin.wasm

# Copy dependency cache
COPY --from=example-build /root/.moon /root/.moon
