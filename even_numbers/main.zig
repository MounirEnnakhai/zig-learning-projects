const std = @import("std");
pub fn main() void {
    var i: u32 = 0;
    std.debug.print("even numbers", .{});
    while (i <= 10) : (i += 1) {
        if (i % 2 != 0) continue;
        std.debug.print("{}", .{i});
        std.debug.print("\n\n", .{});
    }
}
