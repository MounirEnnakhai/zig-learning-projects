const std = @import("std");

fn arena_example() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var arena = std.heap.ArenaAllocator.init(gpa.allocator());
    defer arena.deinit();

    const allocator = arena.allocator();

    const array1 = try allocator.alloc(i32, 100);
    const array2 = try allocator.alloc(i32, 200);
    const array3 = try allocator.alloc(i32, 300);

    std.debug.print("allocated 3 arrays {}, {}, {}\n", .{ array1.len, array2.len, array3.len });
}

pub fn main() !void {
    try arena_example();
}
