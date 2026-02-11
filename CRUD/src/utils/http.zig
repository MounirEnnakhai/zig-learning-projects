const std = @import("std");
const Server = std.http.Server;

pub fn sendJsonResponse(request: *Server.Request, status_code: u16, body: []const u8) !void {
    try request.respond(body, .{
        .status = @enumFromInt(status_code),
        .extra_headers = &.{
            .{ .name = "content-type", .value = "application/json" },
            .{ .name = "access-control-allow-origin", .value = "*" },
        },
    });
}

pub fn sendTextResponse(request: *Server.Request, status_code: u16, body: []const u8) !void {
    try request.respond(body, .{
        .status = @enumFromInt(status_code),
        .extra_headers = &.{
            .{ .name = "content-type", .value = "text/plain" },
            .{ .name = "access-control-allow-origin", .value = "*" },
        },
    });
}

pub fn parseJsonField(body: []const u8, field_name: []const u8) ?[]const u8 {
    const search_str = std.fmt.allocPrint(std.heap.page_allocator, "\"{s}\":\"", .{field_name}) catch return null;
    defer std.heap.page_allocator.free(search_str);

    if (std.mem.indexOf(u8, body, search_str)) |field_start| {
        const value_start = field_start + search_str.len;
        if (std.mem.indexOfPos(u8, body, value_start, "\"")) |value_end| {
            return body[value_start..value_end];
        }
    }
    return null;
}

pub fn parseJsonBool(body: []const u8, field_name: []const u8) ?bool {
    const search_true = std.fmt.allocPrint(std.heap.page_allocator, "\"{s}\":true", .{field_name}) catch return null;
    defer std.heap.page_allocator.free(search_true);

    const search_false = std.fmt.allocPrint(std.heap.page_allocator, "\"{s}\":false", .{field_name}) catch return null;
    defer std.heap.page_allocator.free(search_false);

    if (std.mem.indexOf(u8, body, search_true)) |_| {
        return true;
    } else if (std.mem.indexOf(u8, body, search_false)) |_| {
        return false;
    }
    return null;
}
