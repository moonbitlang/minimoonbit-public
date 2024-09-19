const std = @import("std");
const lib = @import("./lib.zig");

extern fn minimbt_main() void;

pub fn main() void {
    lib.init_allocator();
    minimbt_main();
    lib.deinit_allocator();
}
