const vectors = @import("vectors.zig");

pub const Vec3 = @This();

values: @Vector(3, f64),

pub fn new(X: f64, Y: f64, Z: f64) Vec3
{
    return Vec3 { .values = vectors.vec(3, f64, .{ X, Y, Z }) };
}

pub fn x(self: *const Vec3) f64
{
    return vectors.x(self);
}

pub fn y(self: *const Vec3) f64
{
    return vectors.y(self);
}

pub fn z(self: *const Vec3) f64
{
    return vectors.z(self);
}

pub fn set_x(self: *const Vec3, X: f64) void
{
    return vectors.set_x(self, X);
}

pub fn set_y(self: *const Vec3, Y: f64) void
{
    return vectors.set_y(self, Y);
}

pub fn set_z(self: *const Vec3, Z: f64) void
{
    return vectors.set_z(self, Z);
}

pub fn add(self: *const Vec3, v: Vec3) Vec3
{
    return Vec3 { .values = vectors.add(self, v) };
}

pub fn sub(self: *const Vec3, v: Vec3) Vec3 
{
    return Vec3 { .values = vectors.add(self, v) };
}

pub fn mul(self: *const Vec3, v: Vec3) Vec3
{
    return Vec3 { .values = vectors.mul(self, v) };
}

pub fn mull_s(self: *const Vec3, s: f64) Vec3
{
    return Vec3 { .values = vectors.mul_s(self, s, 3) };
}

pub fn div(self: *const Vec3, v: Vec3) Vec3 
{
    return Vec3 { .values = vectors.div(self, v) };
}

pub fn dot(self: *const Vec3, v: Vec3) Vec3 
{
    return Vec3 { .values = vectors.dot(self, v) };
}

pub fn cross(self: *const Vec3, v: Vec3) Vec3 
{
    const self_1 = vectors.swizzle(self, .{ vectors.VectorComponent.Y, vectors.VectorComponent.Z, vectors.VectorComponent.X}, 3);
    const self_2 = vectors.swizzle(self, .{ vectors.VectorComponent.Z, vectors.VectorComponent.X, vectors.VectorComponent.Y}, 3);
    const v_1 = vectors.swizzle(v, .{ vectors.VectorComponent.Y, vectors.VectorComponent.Z, vectors.VectorComponent.X}, 3);
    const v_2 = vectors.swizzle(v, .{ vectors.VectorComponent.Z, vectors.VectorComponent.X, vectors.VectorComponent.Y}, 3);

    return self_1.mul(v_1).sub(self_2.mul(v_2));
}

pub fn mag(self: *const Vec3) f64
{
    return vectors.magnitude(self.values, f64);
}

pub fn normalize(self: *const Vec3) f64
{
    return vectors.normalize(self.values, f64);
}

