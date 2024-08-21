It's a minimal implementation of a RISC-V runtime using Zig, as a replacement for [`libmincaml`](https://github.com/esumii/min-caml/blob/master/SPARC/libmincaml.S) and [`stub.c`](https://github.com/esumii/min-caml/blob/master/stub.c). It serves as a proof of concept and still need more testing and improvements.

The advantage of using Zig that we can cross-compile in a platform-agnostic way with minimal dependencies. Especially when RISC-V programs need to use Linux system libs.

Another approch is to implement a minimal custom libc (like [this](https://github.com/fwsGonzo/libriscv/tree/master/binaries/barebones)). Then we can compile to bare-metal programs. Also, this educational compiler will present all the basics from scratch, which is nice.
