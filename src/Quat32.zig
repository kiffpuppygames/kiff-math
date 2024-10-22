const std = @import("std");

const vectors = @import("vectors.zig");
const quaternions = @import("quaternions.zig");

pub const Quat32 = @This();

values: @Vector(4, f32),

pub fn new(X: f32, Y: f32, Z: f32) Quat32
{
    return Quat32 { .values = vectors.vec(3, f32, .{ X, Y, Z }) };
}

pub fn w(self: *const Quat32) f32
{
    return vectors.w(self);
}

pub fn x(self: *const Quat32) f32
{
    return vectors.x(self);
}

pub fn y(self: *const Quat32) f32
{
    return vectors.y(self);
}

pub fn z(self: *const Quat32) f32
{
    return vectors.z(self);
}

pub fn set_w(self: *const Quat32, W: f32) void
{
    return vectors.set_w(self, W);
}

pub fn set_x(self: *const Quat32, X: f32) void
{
    return vectors.set_x(self, X);
}

pub fn set_y(self: *const Quat32, Y: f32) void
{
    return vectors.set_y(self, Y);
}

pub fn set_z(self: *const Quat32, Z: f32) void
{
    return vectors.set_z(self, Z);
}

pub inline fn mul(self: *const Quat32, q: Quat32) Quat32
{
    return Quat32 { .values = quaternions.mul(self.values, q.values, f32) };
}

pub fn mag(self: *const Quat32) f32
{
    return vectors.magnitude(self.values, f32);
}

pub fn normalize(self: *const Quat32) Quat32
{
    return vectors.normalize(self.values, f32);
}

pub fn inverse(self: *const Quat32) Quat32
{
    return Quat32 { .values = quaternions.inverse(self.values) };
}

pub fn inverse_normalized(self: *const Quat32) Quat32
{
    return quaternions.inverse_normalized(self.values);
}