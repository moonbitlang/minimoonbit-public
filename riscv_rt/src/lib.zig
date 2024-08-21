const std = @import("std");

var arena_alloc: std.heap.ArenaAllocator = undefined;
var allocator: std.mem.Allocator = undefined;

// we don't need to free the memory, so we can just use a dead large arena, and never releasing it
// until the program exits :)
pub fn init_allocator() void {
    arena_alloc = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    allocator = arena_alloc.allocator();
}

pub fn deinit_allocator() void {
    arena_alloc.deinit();
    arena_alloc = undefined;
    allocator = undefined;
}

export fn mincaml_print_int(i: i32) void {
    std.debug.print("{d}", .{i});
}

export fn mincaml_print_newline() void {
    std.debug.print("\n", .{});
}

export fn mincaml_int_of_float(f: f64) i32 {
    return @intFromFloat(f);
}

export fn mincaml_float_of_int(i: i32) f64 {
    return @floatFromInt(i);
}

export fn mincaml_truncate(f: f64) i32 {
    return @intFromFloat(f);
}

export fn mincaml_floor(f: f64) i32 {
    return @intFromFloat(@floor(f));
}

export fn mincaml_abs_float(f: f64) f64 {
    return @abs(f);
}

export fn mincaml_sqrt(f: f64) f64 {
    return @sqrt(f);
}

export fn mincaml_sin(f: f64) f64 {
    return @sin(f);
}

export fn mincaml_cos(f: f64) f64 {
    return @cos(f);
}

export fn mincaml_atan(f: f64) f64 {
    return std.math.atan(f);
}

export fn mincaml_malloc(sz: usize) [*]u8 {
    const payload = allocator.allocWithOptions(u8, sz, @alignOf(usize), null) catch @panic("Aalloc failed!");
    return @ptrCast(payload);
}

export fn mincaml_create_array(n: usize, v: i32) [*]i32 {
    const arr = allocator.alloc(i32, n) catch @panic("Alloc failed!");
    for (arr) |*item| {
        item.* = v;
    }
    return @ptrCast(arr);
}

export fn mincaml_create_ptr_array(n: usize, init: usize) [*]usize {
    const arr = allocator.alloc(usize, n) catch @panic("Alloc failed!");
    for (arr) |*item| {
        item.* = init;
    }
    return @ptrCast(arr);
}

export fn mincaml_create_float_array(n: usize, v: f64) [*]f64 {
    const arr = allocator.alloc(f64, n) catch @panic("Alloc failed!");
    for (arr) |*item| {
        item.* = v;
    }
    return @ptrCast(arr);
}

export fn print_int(i: i32) void {
    mincaml_print_int(i);
}

export fn print_newline() void {
    mincaml_print_newline();
}

export fn int_of_float(f: f64) i32 {
    return mincaml_int_of_float(f);
}

export fn float_of_int(i: i32) f64 {
    return mincaml_float_of_int(i);
}

export fn truncate(f: f64) i32 {
    return mincaml_truncate(f);
}

export fn floor(f: f64) i32 {
    return mincaml_floor(f);
}

export fn abs_float(f: f64) f64 {
    return mincaml_abs_float(f);
}

export fn sqrt(f: f64) f64 {
    return mincaml_sqrt(f);
}

export fn sin(f: f64) f64 {
    return mincaml_sin(f);
}

export fn cos(f: f64) f64 {
    return mincaml_cos(f);
}

export fn atan(f: f64) f64 {
    return mincaml_atan(f);
}

export fn malloc(sz: usize) [*]u8 {
    return mincaml_malloc(sz);
}

export fn create_array(n: usize, v: i32) [*]i32 {
    return mincaml_create_array(n, v);
}

export fn create_ptr_array(n: usize, init: usize) [*]usize {
    return mincaml_create_ptr_array(n, init);
}

export fn create_float_array(n: usize, v: f64) [*]f64 {
    return mincaml_create_float_array(n, v);
}
