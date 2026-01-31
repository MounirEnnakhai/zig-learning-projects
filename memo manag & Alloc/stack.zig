const std = @import("std");

fn stack_example() !void {
    const stack_array = [_]i32{ 1, 2, 3, 4, 5 };
    std.debug.print("here is the stack {any}", .{stack_array});
}

pub fn main() !void {
    try stack_example();
}
