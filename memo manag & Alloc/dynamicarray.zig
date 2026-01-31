const std = @import("std");

fn arraylist_example() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var list: std.ArrayList(i32) = .empty;
    defer list.deinit(allocator);

    try list.append(allocator, 10);
    try list.append(allocator, 20);
    try list.append(allocator, 30);

    std.debug.print("items {any}\n", .{list.items});

    _ = list.pop();
    std.debug.print("items {any}\n", .{list.items});
}

pub fn main() !void {
    try arraylist_example();
}
