const std = @import("std");
const print = std.debug.print;

const builtin = @import("builtin");

pub fn main() void {
    print("Hello, world!", .{});
}

const testing = if (builtin.is_test) std.testing else void;
const skip = error.SkipZigTest;
test {}
