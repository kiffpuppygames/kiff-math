const vectors = @import("vectors.zig");

const F64x2 = vectors.F64x2;
const f64x2 = vectors.f64x2;
const f64x2s = vectors.f64x2s;

pub const Vec2 = @This();

values: F64x2,

pub fn new(e0: f64, e1: f64) Vec2
{
    return .{ .values = f64x2(e0, e1) };
}

pub fn splat(value: f64) Vec2
{
    return .{ .values = f64x2s(value) };
}

pub fn from_array(arr: [2]f64) Vec2
{
    return .{ .values = f64x2(arr[0], arr[1]) };
}

pub fn zero() Vec2
{
    return .{ .values = f64x2(0, 0) };
}

pub fn x(self: *const Vec2) f64
{
    return self.values[0];
}

pub fn y(self: *const Vec2) f64
{
    return self.values[1];
}

pub fn add(self: *const Vec2, other: Vec2) Vec2
{
    return .{ .values = self.values + other.values };
}

pub fn sub(self: *const Vec2, other: Vec2) Vec2
{
    return .{ .values = self.values - other.values };
}

pub fn to_array(self: *Vec2) [2]f64 
{
    return .{ self.values[0], self.values[1] };
}