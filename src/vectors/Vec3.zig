const vectors = @import("vectors.zig");

const F64x3 = vectors.F64x3;
const f64x3 = vectors.f64x3;
const f64x3s = vectors.f64x3s;

pub const Vec3 = @This(); 

values: F64x3,

pub fn new(e0: f64, e1: f64, e2: f64) Vec3
{
    return .{ .values = f64x3(e0, e1, e2) };
}

pub fn splat(value: f64) Vec3
{
    return .{ .values = f64x3s(value) };
}

pub fn from_array(arr: [3]f64) Vec3
{
    return .{ .values = f64x3(arr[0], arr[1], arr[2]) };
}

pub fn zero() Vec3
{
    return .{ .values = f64x3(0, 0, 0) };
}

pub fn x(self: *const Vec3) f64
{
    return self.values[0];
}

pub fn y(self: *const Vec3) f64
{
    return self.values[1];
}

pub fn z(self: *const Vec3) f64
{
    return self.values[2];
}

pub fn add(self: Vec3, other: Vec3) Vec3
{
    return .{ .values = self.values + other.values };
}

pub fn sub(self: *const Vec3, other: Vec3) Vec3
{
    return .{ .values = self.values - other.values };
}

pub fn to_array(self: *Vec3) [3]f64 
{
    return .{ self.values[0], self.values[1], self.values[2] };
}