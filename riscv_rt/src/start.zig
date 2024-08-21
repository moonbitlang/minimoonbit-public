const std = @import("std");
const lib = @import("./lib.zig");

extern fn mincaml_main() void;

pub fn main() void {
    lib.init_allocator();
    mincaml_main();
    lib.deinit_allocator();
}
