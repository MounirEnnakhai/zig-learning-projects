const std = @import("std");

fn hash_map() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    var map = std.StringHashMap(i32).init(allocator);
    defer map.deinit();

    try map.put("Alice", 25);
    try map.put("Bob", 30);
    try map.put("Mounir", 35);

    if (map.get("Alice")) |age| {
        std.debug.print("Alice {}\n", .{age});
    }

    std.debug.print("contains 'Bob'{}\n", .{map.contains("Bob")});
    var iterator = map.iterator();
    while (iterator.next()) |entry| {
        std.debug.print("{s}: {}\n", .{ entry.key_ptr.*, entry.value_ptr.* });
    }
}

pub fn main() !void {
    try hash_map();
}
