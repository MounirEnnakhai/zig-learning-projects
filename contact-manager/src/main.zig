const std = @import("std");
const ContactManager = @import("ContactManager.zig");

pub fn main() !void {
    std.debug.print("=====================================\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        const leaked = gpa.deinit();
        if (leaked == .leak) {
            std.debug.print("memory is leaked patch it \n", .{});
        } else {
            std.debug.print("memory isnt leaked\n", .{});
        }
    }

    const allocator = gpa.allocator();

    var manager = ContactManager.init(allocator);
    defer manager.deinit();

    std.debug.print("========== adding contacts =========\n", .{});
    try manager.addContact("mounir", "mounir@xdgmail", "06232325525");
    try manager.addContact("Bob Smith", "bob@example.com", "555-0102");
    try manager.addContact("Charlie Brown", "charlie@example.com", "555-0103");

    manager.listContacts();

    std.debug.print("\n--- Finding Contact ---\n", .{});
    if (manager.findContact("mounir")) |contact| {
        std.debug.print("Found contact:\n", .{});
        contact.display();
    }

    std.debug.print("\n--- Searching for Non-existent Contact ---\n", .{});
    if (manager.findContact("David Lee")) |contact| {
        contact.display();
    } else {
        std.debug.print("Contact 'David Lee' not found.\n", .{});
    }

    std.debug.print("removing contact \n", .{});
    if (manager.removeContact("mounir")) {
        std.debug.print("contact removed succesfully ", .{});
    }
    manager.listContacts();
    manager.getStats();

    std.debug.print("\n--- Attempting to Add Duplicate ---\n", .{});
    try manager.addContact("Bob Smith", "bob@example.com", "555-0102");

    std.debug.print("\n--- Final State ---\n", .{});
    manager.listContacts();
    manager.getStats();
}
