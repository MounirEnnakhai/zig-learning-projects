const std = @import("std");

const MathError = error{
    DivideError,
    overflow,
};

pub fn divide(N1: f32, N2: f32) MathError!f32 {
    if (N2 == 0) {
        return MathError.DivideError;
    }
    return N1 / N2;
}

pub fn main() !void {
    const result = try divide(10, 1.2);
    std.debug.print("the division equals = {}", .{result});
}
