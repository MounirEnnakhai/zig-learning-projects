const std = @import("std");
const Contact = @import("Contact.zig");

const ContactManager = @This();

contacts: std.ArrayList(*Contact),
lookup: std.StringHashMap(*Contact),
allocator: std.mem.Allocator,

pub fn init(allocator: std.mem.Allocator) ContactManager {
    return .{
        .contacts = std.ArrayList(*Contact){},
        .lookup = std.StringHashMap(*Contact).init(allocator),
        .allocator = allocator,
    };
}

pub fn deinit(self: *ContactManager) void {
    for (self.contacts.items) |contact| {
        contact.deinit();
    }
    self.contacts.deinit(self.allocator);
    self.lookup.deinit();
}

pub fn addContact(self: *ContactManager, name: []const u8, email: []const u8, phone: []const u8) !void {
    if (self.lookup.get(name)) |_| {
        std.debug.print("=========================contact {s} already exists ====================== \n", .{name});
        return;
    }

    const contact = try Contact.init(self.allocator, name, email, phone);
    errdefer contact.deinit();

    try self.contacts.append(self.allocator, contact);
    errdefer _ = self.contacts.pop();

    try self.lookup.put(contact.name, contact);
}

pub fn findContact(self: *ContactManager, name: []const u8) ?*Contact {
    return self.lookup.get(name);
}

pub fn removeContact(self: *ContactManager, name: []const u8) bool {
    if (self.lookup.get(name)) |contact| {
        _ = self.lookup.remove(name);

        for (self.contacts.items, 0..) |c, i| {
            if (c == contact) {
                _ = self.contacts.orderedRemove(i);
                break;
            }
        }
        contact.deinit();
        return true;
    }
    return false;
}

pub fn listContacts(self: *ContactManager) void {
    if (self.contacts.items.len == 0) {
        std.debug.print("no contacts here add one UWU\n", .{});
        return;
    }

    std.debug.print("here are ur contacts\n", .{});

    for (self.contacts.items, 0..) |contact, i| {
        std.debug.print("contact {}\n", .{i});
        contact.display();
    }
}

pub fn getStats(self: *ContactManager) void {
    std.debug.print("memory stats ============= \n", .{});
    std.debug.print("total contacts {}\n", .{self.contacts.items.len});
    std.debug.print("array capacity {}\n", .{self.contacts.capacity});
    std.debug.print("hashmap count {}\n", .{self.lookup.count()});
}
