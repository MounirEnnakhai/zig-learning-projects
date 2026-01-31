const std = @import("std");

const Student = struct {
    name: []const u8,
    grades: std.ArrayList(f32),

    pub fn init(name: []const u8) Student {
        return Student{
            .name = name,
            .grades = .empty,
        };
    }

    pub fn deinit(self: *Student, allocator: std.mem.Allocator) void {
        self.grades.deinit(allocator);
    }

    pub fn addGrade(self: *Student, allocator: std.mem.Allocator, grade: f32) !void {
        try self.grades.append(allocator, grade);
    }

    pub fn average(self: *Student) f32 {
        if (self.grades.items.len == 0) return 0;

        var sum: f32 = 0;

        for (self.grades.items) |grade| {
            sum += grade;
        }

        return sum / @as(f32, @floatFromInt(self.grades.items.len));
    }

    pub fn display(self: *Student) void {
        std.debug.print("name of student is : {s}\n", .{self.name});
        std.debug.print("her grades are : {any}\n", .{self.grades.items});
        std.debug.print("her average is : {d:.2}\n", .{self.average()});
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    std.debug.print("student grade manager", .{});

    var mounir = Student.init("mounir");
    defer mounir.deinit(allocator);

    var sasa = Student.init("sasa");
    defer sasa.deinit(allocator);

    try mounir.addGrade(allocator, 50);
    try mounir.addGrade(allocator, 100);
    try mounir.addGrade(allocator, 33);

    try sasa.addGrade(allocator, 50);
    try sasa.addGrade(allocator, 50);
    try sasa.addGrade(allocator, 50);

    sasa.display();
    mounir.display();
}
