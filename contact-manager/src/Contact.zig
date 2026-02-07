const std = @import("std");

const Contact = @This();

name: []u8,
email: []u8,
phone: []u8,
allocator: std.mem.Allocator,

pub fn init(allocator: std.mem.Allocator, name: []const u8, email: []const u8, phone: []const u8) !*Contact {
    const contact = try allocator.create(Contact);
    errdefer allocator.destroy(contact);

    const name_copy = try allocator.dupe(u8, name);
    errdefer allocator.free(name_copy);

    const email_copy = try allocator.dupe(u8, email);
    errdefer allocator.free(email_copy);

    const phone_copy = try allocator.dupe(u8, phone);

    contact.* = .{
        .name = name_copy,
        .email = email_copy,
        .phone = phone_copy,
        .allocator = allocator,
    };

    return contact;
}

pub fn deinit(self: *Contact) void {
    self.allocator.free(self.name);
    self.allocator.free(self.email);
    self.allocator.free(self.phone);
    self.allocator.destroy(self);
}

pub fn display(self: *const Contact) void {
    std.debug.print("Name : {s}\n", .{self.name});
    std.debug.print("Email : {s}\n", .{self.email});
    std.debug.print("Phone : {s}\n", .{self.phone});
}
