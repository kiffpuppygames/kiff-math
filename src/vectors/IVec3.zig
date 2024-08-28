const vectors = @import("vectors.zig");

const I64x3 = vectors.I64x3;
const i64x3 = vectors.i64x3;
const i64x3s = vectors.i64x3s;

pub const IVec3 = @This();

values: I64x3,

pub fn new(e0: f64, e1: f64) IVec3
{
    return .{ .values = i64x3s(e0, e1) };
}

pub fn splat(value: f64) IVec3
{
    return .{ .values = i64x3s(value) };
}

pub fn from_array(arr: [2]f64) IVec3
{
    return .{ .values = i64x3s(arr[0], arr[1]) };
}

pub fn zero() IVec3
{
    return .{ .values = i64x3s(0, 0) };
}

pub fn x(self: *const IVec3) f64
{
    return self.values[0];
}

pub fn y(self: *const IVec3) f64
{
    return self.values[1];
}

pub fn add(self: *const IVec3, other: IVec3) IVec3
{
    return .{ .values = self.values + other.values };
}

pub fn sub(self: *const IVec3, other: IVec3) IVec3
{
    return .{ .values = self.values - other.values };
}

pub fn to_array(self: *IVec3) [2]i32 
{
    return .{ self.values[0], self.values[1] };
}