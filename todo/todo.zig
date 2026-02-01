const std = @import("std");

const Task = struct {
    id: u32,
    title: []const u8,
    completed: bool,
};

const TodoApp = struct {
    tasks: std.ArrayList(Task),
    allocator: std.mem.Allocator,
    next_id: u32,

    pub fn init(allocator: std.mem.Allocator) TodoApp {
        return TodoApp{
            .tasks = .empty,
            .allocator = allocator,
            .next_id = 1,
        };
    }

    pub fn deinit(self: *TodoApp) void {
        for (self.tasks.items) |task| {
            self.allocator.free(task.title);
        }
        self.tasks.deinit(self.allocator);
    }

    pub fn addtask(self: *TodoApp, title: []const u8) !void {
        const task = Task{
            .id = self.next_id,
            .title = title,
            .completed = false,
        };

        try self.tasks.append(self.allocator, task);
        self.next_id += 1;

        std.debug.print("guud Task added successfully: {s}\n", .{title});
    }

    pub fn listTasks(self: TodoApp) void {
        if (self.tasks.items.len == 0) {
            std.debug.print("\nNo tasks yet! Add one with 'add <task>'\n\n", .{});
            return;
        }

        std.debug.print("\n=== YOUR TASKS ===\n", .{});
        for (self.tasks.items) |task| {
            const status = if (task.completed) "[X]" else "[ ]";
            std.debug.print("{}. {s} {s}\n", .{ task.id, status, task.title });
        }
        std.debug.print("\n", .{});
    }

    pub fn completeTask(self: *TodoApp, id: u32) !void {
        for (self.tasks.items) |*task| {
            if (task.id == id) {
                task.completed = true;
                std.debug.print("good Task {} marked as completed\n", .{id});
                return;
            }
        }
        std.debug.print("X Task {} not found\n", .{id});
    }

    pub fn deleteTask(self: *TodoApp, id: u32) !void {
        var index: ?usize = null;

        for (self.tasks.items, 0..) |task, i| {
            if (task.id == id) {
                index = i;
                break;
            }
        }

        if (index) |i| {
            self.allocator.free(self.tasks.items[i].title);
            _ = self.tasks.orderedRemove(i);
            std.debug.print("good Task {} removed successfully\n", .{id});
        } else {
            std.debug.print("X Task {} not found\n", .{id});
        }
    }
};

fn showHelp() void {
    std.debug.print("\n=== TODO APP COMMANDS ===\n", .{});
    std.debug.print("  add <task>     - Add a new task\n", .{});
    std.debug.print("  list           - Show all tasks\n", .{});
    std.debug.print("  done <id>      - Mark task as complete\n", .{});
    std.debug.print("  remove <id>    - Delete a task\n", .{});
    std.debug.print("  help           - Show this menu\n", .{});
    std.debug.print("  quit           - Exit app\n", .{});
    std.debug.print("\n", .{});
}

fn handleCommand(app: *TodoApp, input: []const u8, allocator: std.mem.Allocator) !bool {
    const trimmed = std.mem.trim(u8, input, " \t\r\n");

    if (trimmed.len == 0) {
        return true;
    }

    if (std.mem.eql(u8, trimmed, "exit") or std.mem.eql(u8, trimmed, "quit")) {
        return false;
    }

    if (std.mem.eql(u8, trimmed, "list") or std.mem.eql(u8, trimmed, "ls")) {
        app.listTasks();
        return true;
    }

    if (std.mem.eql(u8, trimmed, "help") or std.mem.eql(u8, trimmed, "?")) {
        showHelp();
        return true;
    }

    if (std.mem.startsWith(u8, trimmed, "add ")) {
        const title = std.mem.trim(u8, trimmed[4..], " \t");
        if (title.len == 0) {
            std.debug.print("X Usage: add <task description>\n", .{});
            return true;
        }

        const title_copy = try allocator.dupe(u8, title);
        try app.addtask(title_copy);
        return true;
    }

    if (std.mem.startsWith(u8, trimmed, "done ")) {
        const id_str = std.mem.trim(u8, trimmed[5..], " \t");
        const id = std.fmt.parseInt(u32, id_str, 10) catch {
            std.debug.print("X Invalid task ID: {s}\n", .{id_str});
            return true;
        };
        try app.completeTask(id);
        return true;
    }

    if (std.mem.startsWith(u8, trimmed, "remove ") or std.mem.startsWith(u8, trimmed, "rm ")) {
        const start: usize = if (std.mem.startsWith(u8, trimmed, "remove ")) 7 else 3;
        const id_str = std.mem.trim(u8, trimmed[start..], " \t");
        const id = std.fmt.parseInt(u32, id_str, 10) catch {
            std.debug.print("✗ Invalid task ID: {s}\n", .{id_str});
            return true;
        };
        try app.deleteTask(id);
        return true;
    }

    std.debug.print("✗ Unknown command: {s}\n", .{trimmed});
    std.debug.print("Type 'help' for available commands\n", .{});
    return true;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var app = TodoApp.init(allocator);
    defer app.deinit();

    std.debug.print("\n------------------------------\n", .{});
    std.debug.print("|     TODO APP v2.0          |\n", .{});
    std.debug.print("------------------------------\n", .{});
    std.debug.print("Type 'help' for commands\n\n", .{});

    const stdin = std.fs.File.stdin();

    while (true) {
        std.debug.print("> ", .{});

        var buffer: [1024]u8 = undefined;
        const len = try stdin.read(&buffer);

        if (len == 0) break;

        const input = try allocator.dupe(u8, std.mem.trimRight(u8, buffer[0..len], "\r\n"));
        defer allocator.free(input);

        const should_continue = handleCommand(&app, input, allocator) catch |err| {
            std.debug.print("Error: {}\n", .{err});
            continue;
        };

        if (!should_continue) {
            std.debug.print("\n Goodbye!\n\n", .{});
            break;
        }
    }
}
