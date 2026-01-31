const std = @import("std");

const DynamicList = struct {
    items: std.ArrayList(i32),
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) DynamicList {
        return DynamicList{
            .items = .empty,
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *DynamicList) void {
        self.items.deinit(self.allocator);
    }

    pub fn add(self: *DynamicList, value: i32) !void {
        try self.items.append(self.allocator, value);
    }

    pub fn display(self: DynamicList) void {
        std.debug.print("list: {any}\n", .{self.items.items});
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var my_list = DynamicList.init(allocator);
    defer my_list.deinit();

    try my_list.add(50);
    try my_list.add(100);
    try my_list.add(150);

    my_list.display();
}
