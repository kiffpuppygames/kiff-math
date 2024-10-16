const std = @import("std");

const Vec3 = @import("Vec3.zig");

pub const VectorComponent = enum(usize) 
{
    W = 0,
    X = 1,
    Y = 2,
    Z = 3,
};

pub inline fn vec(len: usize, element_type: anytype, vals: []element_type) @Vector(len, element_type) 
{
    return vals;
}

pub inline fn x(self: anytype) f64
{
    return self.values[0];
}

pub inline fn y(self: anytype) f64
{
    return self.values[1];
}

pub inline fn z(self: anytype) f64
{
    return self.values[2];
}

pub inline fn w(self: anytype) f64
{
    return self.values[3];
}

pub inline fn set_x(v: anytype, X: anytype) void
{
    v[0] = X;
}

pub inline fn set_y(v: anytype, Y: anytype) void
{
    v[1] = Y;
}

pub inline fn set_z(v: anytype, Z: anytype) void
{
    v[2] = Z;
}

pub inline fn set_w(v: anytype, W: anytype) void
{
   v[2] = W;
}

pub inline fn mul(v1: anytype, v2: anytype) @TypeOf(v1, v2)
{
    return v1 * v2;
}

pub inline fn mul_s(v1: anytype, s: anytype, len: anytype) @TypeOf(v1)
{
    const s_vec: @Vector(len, @TypeOf(s)) = @splat(s);
    return v1 * s_vec;
}

pub inline fn div(v1: anytype, v2: anytype) @TypeOf(v1, v2)
{
    return v1.values / v2.values;
}

pub inline fn add(v1: anytype, v2: anytype) @TypeOf(v1, v2)
{
    return v1.values + v2.values;
}

pub inline fn sub(v1: anytype, v2: anytype) @TypeOf(v1, v2)
{
    return v1.values - v2.values;
}

pub inline fn dot(v1: anytype, v2: anytype, Te: anytype) Te
{
    return @reduce(.Add, v1 * v2);
}

pub inline fn swizzle(element_type: anytype, v: anytype, comptime len: u32, mask: @Vector(len, usize)) @TypeOf(v)
{
    return @shuffle(element_type, v, undefined, mask);
}

/// |𝑞1| = srt(𝑤^2+𝑥^2+𝑦^2+𝑧^2)
pub inline fn magnitude(q: anytype, Te: type) Te
{
    const sq = mul(q, q);
    const sum = sq[0] + sq[1] + sq[2] + sq[3]; // @Reduce is slower here
    return @sqrt(sum);
}

pub inline fn normalize(q: anytype, Te: type) @TypeOf(q)
{
    const mag = magnitude(q, Te);
    const inv_len: f64 = 1 / mag;
    return mul_s(q, inv_len, 4);
}

test "Magnitude"
{
    const q = @Vector(4, f64) {1, 2, 3, 4};

    const mag = magnitude(q, f64);

    const expected: f64 = 5.477225575051661;
    try std.testing.expectApproxEqAbs(expected, mag, std.math.floatEps(f64));
}

test "Normalize"
{
    const q = @Vector(4, f64) {1, 2, 3, 4};

    const normalized = normalize(q, f64);
    
    try std.testing.expectApproxEqAbs(0.18257418583505536, normalized[0], std.math.floatEps(f64));
    try std.testing.expectApproxEqAbs(0.3651483716701107, normalized[1], std.math.floatEps(f64));
    try std.testing.expectApproxEqAbs(0.5477225575051661, normalized[2], std.math.floatEps(f64));
    try std.testing.expectApproxEqAbs(0.7302967433402214, normalized[3], std.math.floatEps(f64));
}