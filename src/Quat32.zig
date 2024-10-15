const std = @import("std");

const vectors = @import("vectors.zig");

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

/// Quat32ernion multiplication is non-commutative (i.e., 𝑞1⋅𝑞2≠𝑞2⋅𝑞1). This operation is essential for combining rotations, and it produces another Quat32ernion that represents the composition of two rotations.
/// Formula: 𝑞1⋅𝑞2=(𝑤1𝑤2−𝑥1𝑥2−𝑦1𝑦2−𝑧1𝑧2,𝑤1𝑥2+𝑥1𝑤2+𝑦1𝑧2−𝑧1𝑦2,𝑤1𝑦2+𝑦1𝑤2+𝑧1𝑥2−𝑥1𝑧2,𝑤1𝑧2+𝑧1𝑤2+𝑥1𝑦2−𝑦1𝑥2)
pub inline fn mul(self: *const Quat32, q: Quat32) Quat32
{
    @setFloatMode(.optimized);
    const w_prod = vectors.mul(self.values, q.values); 
    const x_prod = vectors.mul(
        self.values, 
        @as(@Vector(4, f32), .{q.values[1], q.values[0], q.values[3], q.values[2]}));
    const y_prod = vectors.mul(
        @as(@Vector(4, f32), .{ self.values[0], self.values[2], self.values[3], self.values[1] }), 
        @as(@Vector(4, f32), .{ q.values[2], q.values[0], q.values[1], q.values[3] })
    );
    const z_prod = vectors.mul(
        @as(@Vector(4, f32), .{ self.values[0], self.values[3], self.values[1], self.values[2]}), 
        @as(@Vector(4, f32), .{ q.values[3], q.values[0], q.values[2], q.values[1] }));

    return Quat32 { .values = .{ 
            w_prod[0] - w_prod[1] - w_prod[2] - w_prod[3], 
            x_prod[0] + x_prod[1] + x_prod[2] - x_prod[3], 
            y_prod[0] + y_prod[1] + y_prod[2] - y_prod[3], 
            z_prod[0] + z_prod[1] + z_prod[2] - z_prod[3]
        } 
    };    
}

pub inline fn mul2(self: *const Quat32, q: Quat32) Quat32
{
    @setFloatMode(.optimized);
    const w_prod = vectors.mul(self.values, q.values); 
    const x_prod = vectors.mul(
        self.values, 
        @as(@Vector(4, f32), .{q.values[1], q.values[0], q.values[3], q.values[2]}));
    const y_prod = vectors.mul(
        @as(@Vector(4, f32), .{ self.values[0], self.values[2], self.values[3], self.values[1] }), 
        @as(@Vector(4, f32), .{ q.values[2], q.values[0], q.values[1], q.values[3] })
    );
    const z_prod = vectors.mul(
        @as(@Vector(4, f32), .{ self.values[0], self.values[3], self.values[1], self.values[2]}), 
        @as(@Vector(4, f32), .{ q.values[3], q.values[0], q.values[2], q.values[1] }));

    return Quat32 { .values = .{ 
            w_prod[0] - w_prod[1] - w_prod[2] - w_prod[3], 
            x_prod[0] + x_prod[1] + x_prod[2] - x_prod[3], 
            y_prod[0] + y_prod[1] + y_prod[2] - y_prod[3], 
            z_prod[0] + z_prod[1] + z_prod[2] - z_prod[3]
        } 
    };    
}

test "Quat32ernion Multiplication"
{
    const q1 = Quat32 { .values = .{1, 0, 1, 0} };
    const q2 = Quat32 { .values = .{1, 0.5, 0.5, 0.75} };

    // 𝑞1⋅𝑞2=(𝑤1𝑤2−𝑥1𝑥2−𝑦1𝑦2−𝑧1𝑧2,𝑤1𝑥2+𝑥1𝑤2+𝑦1𝑧2−𝑧1𝑦2,𝑤1𝑦2+𝑦1𝑤2+𝑧1𝑥2−𝑥1𝑧2,𝑤1𝑧2+𝑧1𝑤2+𝑥1𝑦2−𝑦1𝑥2)
    // 1*1-0*0.5-1*0.5-0*0.75
    // 1-0.5-0-0
    // 0.5

    const prod = q1.mul(q2);

    const expected: @Vector(4, f32) = .{0.5, 1.25, 1.5, 0.25};
    try std.testing.expectEqual(prod.values, expected);
}