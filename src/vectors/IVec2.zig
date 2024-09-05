const vectors = @import("vectors.zig");

const I64x2 = vectors.I64x2;
const i64x2 = vectors.i64x2;
const i64x2s = vectors.i64x2s;

pub const IVec2 = @This();

values: I64x2,

pub fn new(e0: f64, e1: f64) IVec2
{
    return .{ .values = i64x2s(e0, e1) };
}

pub fn splat(value: f64) IVec2
{
    return .{ .values = i64x2s(value) };
}

pub fn from_array(arr: [2]f64) IVec2
{
    return .{ .values = i64x2s(arr[0], arr[1]) };
}

pub fn zero() IVec2
{
    return .{ .values = i64x2s(0, 0) };
}

pub fn x(self: *const IVec2) f64
{
    return self.values[0];
}

pub fn y(self: *const IVec2) f64
{
    return self.values[1];
}

pub fn add(self: *const IVec2, other: IVec2) IVec2
{
    return .{ .values = self.values + other.values };
}

pub fn sub(self: *const IVec2, other: IVec2) IVec2
{
    return .{ .values = self.values - other.values };
}

pub inline fn to_array(self: *IVec2) [2]i32 
{
    return .{ self.values[0], self.values[1] };
}

pub fn len() usize {
    return 2;
}