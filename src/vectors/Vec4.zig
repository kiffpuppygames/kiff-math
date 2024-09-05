const vectors = @import("vectors.zig");

const F64x4 = vectors.F64x4;

pub const Vec4 = @This();

values: F64x4,

pub fn new(e0: f64, e1: f64, e2: f64, e3: f64) Vec4 
{
    return vectors.new(Vec4, f64, .{ e0, e1, e2, e3 });
}

pub fn splat(value: f64) Vec4 {
    return vectors.splat(Vec4, value);
}

pub fn from_array(arr: [4]f64) Vec4 {
    return vectors.new(Vec4, arr);
}

pub fn zero() Vec4 {
    return splat(0);
}

pub fn x(self: *const Vec4) f64 {
    return self.values[0];
}

pub fn y(self: *const Vec4) f64 {
    return self.values[1];
}

pub fn z(self: *const Vec4) f64 {
    return self.values[2];
}

pub fn w(self: *const Vec4) f64 {
    return self.values[3];
}

pub fn add(self: *const Vec4, other: Vec4) Vec4 {
    return .{ .values = self.values + other.values };
}

pub fn sub(self: *const Vec4, other: Vec4) Vec4 {
    return .{ .values = self.values - other.values };
}

pub fn to_array(self: *Vec4) [4]f64 {
    return .{ self.values[0], self.values[1], self.values[2], self.values[3] };
}

pub fn len() usize {
    return 4;
}