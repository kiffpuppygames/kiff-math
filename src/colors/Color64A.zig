const colors = @import("colors.zig");

const Color64A = @This();

values: @Vector(4, f64),

pub fn new(R: f64, G: f64, B: f64, A: f64) Color64A
{
    return colors.new(Color64A, f64, 4, 4, .{ R, G, B, A });
}

pub fn splat(value: f64) Color64A
{
    return .colors.new(Color64A, f64, 4, 1, .{ value } );
}

pub fn from_array(arr: [4]f64) Color64A
{
    return colors.new(Color64A, f64, 4, 1, arr );
}

pub fn black() Color64A
{
    return .{ .values = .{ 0, 0, 0, 1} };
}

pub fn white() Color64A
{
    return .{ .values = .{ 1, 1, 1, 1} };
}

pub fn red() Color64A
{
    return .{ .values = .{ 1, 0, 0, 1} };
}

pub fn green() Color64A
{
    return .{ .values = .{ 0, 1, 0, 1} };
}

pub fn blue() Color64A
{
    return .{ .values = .{ 0, 0, 1, 1} };
}

pub fn magenta() Color64A
{
    return .{ .values = .{ 1, 0, 1, 1} };
}

pub fn r(self: *const Color64A) f64
{
    return self.values[0];
}

pub fn g(self: *const Color64A) f64
{
    return self.values[1];
}

pub fn b(self: *const Color64A) f64
{
    return self.values[2];
}

pub fn a(self: *const Color64A) f64
{
    return self.values[3];
}

pub fn add(self: Color64A, other: Color64A) Color64A
{
    return .{ .values = self.values + other.values };
}

pub fn sub(self: *const Color64A, other: Color64A) Color64A
{
    return .{ .values = self.values - other.values };
}

pub fn to_array(self: *Color64A) [4]f64 
{
    return .{ self.values[0], self.values[1], self.values[2], self.values[3] };
}