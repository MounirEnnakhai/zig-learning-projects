const std = @import("std");

fn heap_example() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    const heap_array = try allocator.alloc(i32, 5);
    defer allocator.free(heap_array);
    heap_array[0] = 501;
    heap_array[1] = 1040;
    heap_array[2] = 30;
    heap_array[3] = 50;
    heap_array[4] = 20;

    std.debug.print("heap array {any}\n", .{heap_array});
}

pub fn main() !void {
    try heap_example();
}
