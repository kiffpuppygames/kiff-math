const std = @import("std");

const vectors = @import("vectors.zig");
const quaternions = @import("quaternions.zig");

pub const Quat = @This();

values: @Vector(4, f64),

pub fn new(X: f64, Y: f64, Z: f64) Quat
{
    return Quat { .values = vectors.vec(3, f64, .{ X, Y, Z }) };
}

pub fn w(self: *const Quat) f64
{
    return vectors.w(self);
}

pub fn x(self: *const Quat) f64
{
    return vectors.x(self);
}

pub fn y(self: *const Quat) f64
{
    return vectors.y(self);
}

pub fn z(self: *const Quat) f64
{
    return vectors.z(self);
}

pub fn set_w(self: *const Quat, W: f64) void
{
    return vectors.set_w(self, W);
}

pub fn set_x(self: *const Quat, X: f64) void
{
    return vectors.set_x(self, X);
}

pub fn set_y(self: *const Quat, Y: f64) void
{
    return vectors.set_y(self, Y);
}

pub fn set_z(self: *const Quat, Z: f64) void
{
    return vectors.set_z(self, Z);
}

pub fn mul(self: *const Quat, q: Quat) Quat
{
    return Quat { .values = quaternions.mul(self.values, q.values, f64) };
}

