const std = @import("std");

const Task = @This();

id: u32,
title: []u8,
description: []u8,
completed: bool,
allocator: std.mem.Allocator,

pub fn init(allocator: std.mem.Allocator, id: u32, title: []const u8, description: []const u8) !*Task {
    const task = try allocator.create(Task);
    errdefer allocator.destroy(task);

    const title_copy = try allocator.dupe(u8, title);
    errdefer allocator.free(title_copy);

    const desc_copy = try allocator.dupe(u8, description);
    errdefer allocator.free(desc_copy);

    task.* = .{
        .id = id,
        .title = title_copy,
        .description = desc_copy,
        .completed = false,
        .allocator = allocator,
    };

    return task;
}

pub fn deinit(self: *Task) void {
    const allocator = self.allocator;
    allocator.free(self.title);
    allocator.free(self.description);
    allocator.destroy(self);
}

pub fn toJson(self: *const Task, writer: anytype) !void {
    try writer.print(
        \\{{"id":{d},"title":"{s}","description":"{s}","completed":{}}}
    , .{ self.id, self.title, self.description, self.completed });
}
