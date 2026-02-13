const std = @import("std");
const TaskService = @import("../services/TaskService.zig");
const http_utils = @import("../utils/http.zig");

const Server = std.http.Server;

pub fn handleGetAllTasks(request: *Server.Request, service: *TaskService, allocator: std.mem.Allocator) !void {
    var buffer = std.ArrayList(u8){};
    defer buffer.deinit(allocator);

    const writer = buffer.writer(allocator);
    try writer.writeAll("[");

    const tasks = service.getAllTasks();
    for (tasks, 0..) |task, i| {
        try task.toJson(writer);
        if (i < tasks.len - 1) try writer.writeAll(",");
    }
    try writer.writeAll("]");

    try http_utils.sendJsonResponse(request, 200, buffer.items);
}

pub fn handleGetTask(request: *Server.Request, service: *TaskService, id: u32, allocator: std.mem.Allocator) !void {
    const task = try service.getTask(id) orelse {
        try http_utils.sendTextResponse(request, 404, "task was not found");
        return;
    };

    var buffer = std.ArrayList(u8){};
    defer buffer.deinit(allocator);

    try task.toJson(buffer.writer(allocator));
    try http_utils.sendJsonResponse(request, 200, buffer.items);
}

pub fn handleCreateTask(request: *Server.Request, service: *TaskService, allocator: std.mem.Allocator) !void {
    var body_buf: [1024]u8 = undefined;
    const body_reader = request.server.reader.bodyReader(
        &body_buf,
        request.head.transfer_encoding,
        request.head.content_length,
    );

    var body_list = std.ArrayList(u8){};
    defer body_list.deinit(allocator);
    try body_reader.appendRemaining(allocator, &body_list, @enumFromInt(1024 * 1024));
    const body = body_list.items;

    const title = http_utils.parseJsonField(body, "title") orelse {
        try http_utils.sendTextResponse(request, 400, "title is required");
        return;
    };

    const description = http_utils.parseJsonField(body, "description") orelse "";

    const task = try service.createTask(title, description);

    var buffer = std.ArrayList(u8){};
    defer buffer.deinit(allocator);

    try task.toJson(buffer.writer(allocator));
    try http_utils.sendJsonResponse(request, 201, buffer.items);
}

pub fn handleUpdateTask(request: *Server.Request, service: *TaskService, id: u32, allocator: std.mem.Allocator) !void {
    var body_buf: [1024]u8 = undefined;
    const body_reader = request.server.reader.bodyReader(
        &body_buf,
        request.head.transfer_encoding,
        request.head.content_length,
    );

    var body_list = std.ArrayList(u8){};
    defer body_list.deinit(allocator);
    try body_reader.appendRemaining(allocator, &body_list, @enumFromInt(1024 * 1024));
    const body = body_list.items;

    const title = http_utils.parseJsonField(body, "title");
    const description = http_utils.parseJsonField(body, "description");
    const completed = http_utils.parseJsonField(body, "completed");

    const updated = try service.updateTask(id, title, description, completed);
    if (!updated) {
        try http_utils.sendTextResponse(request, 404, "task not found");
        return;
    }

    const task = service.getTask(id).?;
    var buffer = std.ArrayList(u8){};
    defer buffer.deinit(allocator);

    try task.toJson(buffer.writer(allocator));
    try http_utils.sendJsonResponse(request, 200, buffer.items);
}
