const vectors = @import("vectors.zig");

const I64x4 = vectors.I64x4;
const i64x4 = vectors.i64x4;
const i64x4s = vectors.i64x4s;

pub const IVec4 = @This();

values: I64x4,

pub fn new(e0: i64, e1: i64, e2: i64, e3: i64) IVec4
{
    return .{ .values = i64x4(e0, e1, e2, e3) };
}

pub fn splat(value: i64) IVec4
{
    return .{ .values = i64x4s(value) };
}

pub fn from_array(arr: [4]i64) IVec4
{
    return .{ .values = i64x4(arr[0], arr[1], arr[2], arr[3]) };
}

pub fn zero() IVec4
{
    return .{ .values = i64x4(0, 0, 0, 0) };
}

pub fn x(self: *const IVec4) i64
{
    return self.values[0];
}

pub fn y(self: *const IVec4) i64
{
    return self.values[1];
}

pub fn z(self: *const IVec4) i64
{
    return self.values[2];
}

pub fn w(self: *const IVec4) i64
{
    return self.values[3];
}

pub fn add(self: *const IVec4, other: IVec4) IVec4
{
    return .{ .values = self.values + other.values };
}

pub fn sub(self: *const IVec4, other: IVec4) IVec4
{
    return .{ .values = self.values - other.values };
}

pub fn to_array(self: *IVec4) [4]i64 
{
    return .{ self.values[0], self.values[1], self.values[2], self.values[3] };
}