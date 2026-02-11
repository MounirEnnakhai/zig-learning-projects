const std = @import("std");
const Task = @import("../models/Task.zig");

const TaskService = @This();

tasks: std.ArrayList(*Task),
next_id: u32,
allocator: std.mem.Allocator,

pub fn init(allocator: std.mem.Allocator) TaskService {
    return .{
        .tasks = std.ArrayList(*Task){},
        .next_id = 1,
        .allocator = allocator,
    };
}

pub fn deinit(self: *TaskService) void {
    for (self.tasks.items) |task| {
        task.deinit();
    }
    self.tasks.deinit(self.allocator);
}

pub fn createTask(self: *TaskService, title: []const u8, description: []const u8) !*Task {
    const task = try Task.init(self.allocator, self.next_id, title, description);
    errdefer task.deinit();

    try self.tasks.append(self.allocator, task);
    self.next_id += 1;

    return task;
}

pub fn getTask(self: *TaskService, id: u32) ?*Task {
    for (self.tasks.items) |task| {
        if (task.id == id) return task;
    }
    return null;
}

pub fn getAllTasks(self: *TaskService) []*Task {
    return self.tasks.items;
}

pub fn updateTask(self: *TaskService, id: u32, title: ?[]const u8, description: ?[]const u8, completed: ?bool) !bool {
    const task = self.getTask(id) orelse return false;

    if (title) |new_title| {
        self.allocator.free(task.title);
        task.title = try self.allocator.dupe(u8, new_title);
    }

    if (description) |new_desc| {
        self.allocator.free(task.description);
        task.description = try self.allocator.dupe(u8, new_desc);
    }

    if (completed) |new_completed| {
        task.completed = new_completed;
    }

    return true;
}

pub fn deleteTask(self: *TaskService, id: u32) bool {
    for (self.tasks.items, 0..) |task, i| {
        if (task.id == id) {
            _ = self.tasks.orderedRemove(i);
            task.deinit();
            return true;
        }
    }
    return false;
}
