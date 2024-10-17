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
    @setFloatMode(.optimized);
    return v1 * v2;
}

pub inline fn mul_s(v: anytype, s: anytype) @TypeOf(v)
{
    @setFloatMode(.optimized);
    return v * @as(@Vector(@typeInfo(@TypeOf(v)).vector.len, @TypeOf(s)), @splat(s));
}

pub inline fn div(v1: anytype, v2: anytype) @TypeOf(v1, v2)
{
    @setFloatMode(.optimized);
    return v1 / v2;
}

pub inline fn div_s(v: anytype, s: anytype) @TypeOf(v)
{
    @setFloatMode(.optimized);
    return v / @as(@Vector(@typeInfo(@TypeOf(v)).vector.len, @TypeOf(s)), @splat(s));
}

pub inline fn add(v1: anytype, v2: anytype) @TypeOf(v1, v2)
{
    @setFloatMode(.optimized);
    return v1 + v2;
}

pub inline fn sub(v1: anytype, v2: anytype) @TypeOf(v1, v2)
{
    @setFloatMode(.optimized);
    return v1 - v2;
}

pub inline fn dot(v1: anytype, v2: anytype) @typeInfo(v1).Vector.elem_type
{
    @setFloatMode(.optimized);
    return @reduce(.Add, v1 * v2);
}

pub inline fn swizzle(v: anytype, mask: @Vector(@typeInfo(v).Vector.len, usize)) @TypeOf(v)
{
    @setFloatMode(.optimized);
    return @shuffle(@typeInfo(v).Vector.elem_type, v, undefined, mask);
}

/// |𝑞1| = srt(𝑤^2+𝑥^2+𝑦^2+𝑧^2)
pub inline fn magnitude(v: anytype) @typeInfo(@TypeOf(v)).vector.child
{
    @setFloatMode(.optimized);
    const sum = @reduce(.Add, mul(v, v));
    return @sqrt(sum);
}

/// This will normalize the vector (includes the magnitude calculation) will return the vector unchaged if the magnitude is already 1. 
pub inline fn normalize(v: anytype) @TypeOf(v)
{
    @setFloatMode(.optimized);
    const mag = magnitude(v);

    if (!std.math.approxEqAbs(@typeInfo(@TypeOf(v)).vector.child, mag, 1, comptime std.math.floatEps(@typeInfo(@TypeOf(v)).vector.child)))
    {
        return normalize_with_magnitude(v, mag);
    }

    return v;
}

/// This will normalize the vector (includes the magnitude calculation) will not check if the vector is already a unit vector
/// Will return the normalized vector and its magnitude
pub inline fn normalize_nocheck(v: anytype) @typeInfo(@TypeOf(v)).vector.child
{
    @setFloatMode(.optimized);
    return normalize_with_magnitude(v, magnitude(v));
}

//This will normalize the vector by an already know magnitude
pub inline fn normalize_with_magnitude(q: anytype, mag: anytype) @TypeOf(q)
{
    @setFloatMode(.optimized);
    return mul_s(q, 1 / mag);
}

test "Magnitude"
{
    const q = @Vector(4, f64) {1, 2, 3, 4};

    const mag = magnitude(q);

    const expected: f64 = 5.477225575051661;
    try std.testing.expectApproxEqAbs(expected, mag, std.math.floatEps(f64));
}

test "Normalize"
{
    const q = @Vector(4, f64) {1, 2, 3, 4};

    const normalized = normalize(q);
    
    try std.testing.expectApproxEqAbs(0.18257418583505536, normalized[0], std.math.floatEps(f64));
    try std.testing.expectApproxEqAbs(0.3651483716701107, normalized[1], std.math.floatEps(f64));
    try std.testing.expectApproxEqAbs(0.5477225575051661, normalized[2], std.math.floatEps(f64));
    try std.testing.expectApproxEqAbs(0.7302967433402214, normalized[3], std.math.floatEps(f64));
}