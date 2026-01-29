const std = @import("std");

fn findUser(id: i32) ?[]const u8 {
    if (id == 1) {
        return "alice";
    } else if (id == 2) {
        return "bob";
    } else if (id == 3) {
        return "lisa";
    }

    return null;
}

pub fn main() void {
    const user1 = findUser(4);
    if (user1) |name| {
        std.debug.print("exists {s}\n", .{name});
    } else {
        std.debug.print("doesn't exist", .{});
    }
}
