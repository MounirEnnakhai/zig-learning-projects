const std = @import("std");
const TaskService = @import("services/TaskService.zig");
const TaskController = @import("controllers/TaskController.zig");
const http_utils = @import("utils/http.zig");

const Server = std.http.Server;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var service = TaskService.init(allocator);
    defer service.deinit();

    _ = try service.createTask("Learn Zig", "Study Zig programming language");
    _ = try service.createTask("Learn lol", "play ranked");

    const address = try std.net.Address.parseIp("127.0.0.1", 8080);
    var server = try address.listen(.{
        .reuse_address = true,
    });
    defer server.deinit();

    std.debug.print("Task API Server\n", .{});
    std.debug.print("==================\n", .{});
    std.debug.print("Running on: http://127.0.0.1:8080\n\n", .{});
    std.debug.print("Project Structure:\n", .{});
    std.debug.print("  src/models/      - Data models\n", .{});
    std.debug.print("  src/services/    - Business logic\n", .{});
    std.debug.print("  src/controllers/ - HTTP handlers\n", .{});
    std.debug.print("  src/utils/       - Helper functions\n\n", .{});
    std.debug.print("Endpoints:\n", .{});
    std.debug.print("  GET    /tasks     - Get all tasks\n", .{});
    std.debug.print("  GET    /tasks/:id - Get task by ID\n", .{});
    std.debug.print("  POST   /tasks     - Create new task\n", .{});
    std.debug.print("  PUT    /tasks/:id - Update task\n", .{});
    std.debug.print("  DELETE /tasks/:id - Delete task\n\n", .{});

    while (true) {
        const connection = try server.accept();
        const thread = try std.Thread.spawn(.{}, handleConnection, .{ connection, &service, allocator });
        thread.detach();
    }
}
fn handleConnection(connection: std.net.Server.Connection, service: *TaskService, allocator: std.mem.Allocator) void {
    defer connection.stream.close();

    const read_buffer = allocator.alloc(u8, 8 * 1024) catch |err| {
        std.debug.print("allocate error: {}\n", .{err});
        return;
    };
    defer allocator.free(read_buffer);

    const write_buffer = allocator.alloc(u8, 8 * 1024) catch |err| {
        std.debug.print("allocate error: {}\n", .{err});
        return;
    };
    defer allocator.free(write_buffer);

    var con_reader = connection.stream.reader(read_buffer);
    var con_writer = connection.stream.writer(write_buffer);
    var server = std.http.Server.init(con_reader.interface(), &con_writer.interface);

    var request = server.receiveHead() catch |err| {
        std.debug.print("error receiving head: {}\n", .{err});
        return;
    };

    handleRequest(&request, service, allocator) catch |err| {
        std.debug.print("error: {}\n", .{err});
    };
}

fn handleRequest(request: *std.http.Server.Request, service: *TaskService, allocator: std.mem.Allocator) !void {
    const target = request.head.target;
    const method = request.head.method;

    std.debug.print(" {s: <7} {s}\n", .{ @tagName(method), target });

    // Router
    if (std.mem.eql(u8, target, "/tasks")) {
        if (method == .GET) {
            try TaskController.handleGetAllTasks(request, service, allocator);
        } else if (method == .POST) {
            try TaskController.handleCreateTask(request, service, allocator);
        } else {
            try http_utils.sendTextResponse(request, 405, "Method Not Allowed");
        }
    } else if (std.mem.startsWith(u8, target, "/tasks/")) {
        const id_str = target[7..];
        const id = std.fmt.parseInt(u32, id_str, 10) catch {
            try http_utils.sendTextResponse(request, 400, "Invalid task ID");
            return;
        };

        if (method == .GET) {
            try TaskController.handleGetTask(request, service, id, allocator);
        } else if (method == .PUT) {
            try TaskController.handleUpdateTask(request, service, id, allocator);
        } else if (method == .DELETE) {
            try TaskController.handleDeleteTask(request, service, id);
        } else {
            try http_utils.sendTextResponse(request, 405, "Method Not Allowed");
        }
    } else {
        try http_utils.sendTextResponse(request, 404, "Not Found");
    }
}
