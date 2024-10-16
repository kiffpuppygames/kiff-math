/// Common Quaternion Operations:
/// Operation       | Description                                               | Use Cases
/// Multiplication  | Combines two rotations, results in a new quaternion       | Combining rotations, 3D transformations
/// Conjugate       | Negates the imaginary part, used to find inverse          | Inverting rotations, quaternion division
/// Magnitude       | Magnitude of the quaternion                               | Normalization, measuring quaternion size, 
/// Normalize       | Scales the quaternion to have unit length                 | Unit quaternions for pure rotations
/// Inverse         | Reverses the rotation represented by a quaternion         | Undoing a rotation
/// Vector Rotation | Rotates a vector by applying quaternion multiplication    | 3D rotations in graphics and physics
/// Slerp           | Smooth interpolation between two quaternions              | Animation, smooth transitions between orientations
/// Dot Product     | Measures similarity between quaternions                   | Slerp, checking quaternion alignment
/// Division        | Quaternion division using the inverse                     | Finding relative rotations between orientations


const std = @import("std");

const vectors = @import("vectors.zig");
const quaternions = @import("quaternions.zig");

/// Quaternion multiplication is non-commutative (i.e., 𝑞1⋅𝑞2≠𝑞2⋅𝑞1). This operation is essential for combining rotations, and it produces another quaternion that represents the composition of two rotations.
/// Formula: 𝑞1⋅𝑞2=(𝑤1𝑤2−𝑥1𝑥2−𝑦1𝑦2−𝑧1𝑧2,𝑤1𝑥2+𝑥1𝑤2+𝑦1𝑧2−𝑧1𝑦2,𝑤1𝑦2+𝑦1𝑤2+𝑧1𝑥2−𝑥1𝑧2,𝑤1𝑧2+𝑧1𝑤2+𝑥1𝑦2−𝑦1𝑥2)
pub inline fn mul(q1: anytype, q2: anytype, Te: type) @TypeOf(q2)
{
    @setFloatMode(.optimized);
    const T = comptime @TypeOf(q2);

    const w_prod = vectors.mul(q1, q2); 
    const x_prod = vectors.mul(
        q1, 
        @as(@Vector(4, Te), .{q2[1], q2[0], q2[3], q2[2]}));
    const y_prod = vectors.mul(
        @as(@Vector(4, Te), .{ q1[0], q1[2], q1[3], q1[1] }), 
        @as(@Vector(4, Te), .{ q2[2], q2[0], q2[1], q2[3] })
    );
    const z_prod = vectors.mul(
        @as(@Vector(4, Te), .{ q1[0], q1[3], q1[1], q1[2]}), 
        @as(@Vector(4, Te), .{ q2[3], q2[0], q2[2], q2[1] }));

    return T { 
            w_prod[0] - w_prod[1] - w_prod[2] - w_prod[3], 
            x_prod[0] + x_prod[1] + x_prod[2] - x_prod[3], 
            y_prod[0] + y_prod[1] + y_prod[2] - y_prod[3], 
            z_prod[0] + z_prod[1] + z_prod[2] - z_prod[3]
    };
}

pub inline fn conjugate(q: anytype) @TypeOf(q)
{
    return .{ q[0], -q[1], -q[2], -q[3] };
}

/// |𝑞1| = srt(𝑤^2+𝑥^2+𝑦^2+𝑧^2)
pub inline fn magnitude(q: anytype, Te: type) Te
{
    const sq = vectors.mul(q, q);
    const sum = sq[0] + sq[1] + sq[2] + sq[3]; // @Reduce is slower here
    return @sqrt(sum);
}

test "Quaternion Multiplication"
{
    const q1 = @Vector(4, f64) {1, 0, 1, 0};
    const q2 = @Vector(4, f64) {1, 0.5, 0.5, 0.75};

    // 𝑞1⋅𝑞2=(𝑤1𝑤2−𝑥1𝑥2−𝑦1𝑦2−𝑧1𝑧2,𝑤1𝑥2+𝑥1𝑤2+𝑦1𝑧2−𝑧1𝑦2,𝑤1𝑦2+𝑦1𝑤2+𝑧1𝑥2−𝑥1𝑧2,𝑤1𝑧2+𝑧1𝑤2+𝑥1𝑦2−𝑦1𝑥2)
    // 1*1-0*0.5-1*0.5-0*0.75
    // 1-0.5-0-0
    // 0.5

    const prod = mul(q1, q2, f64);

    const expected: @Vector(4, f64) = .{0.5, 1.25, 1.5, 0.25};
    try std.testing.expectEqual(prod, expected);
}

test "Quaternion Magnitude"
{
    const q = @Vector(4, f64) {1, 2, 3, 4};

    const mag = magnitude(q, f64);

    const expected: f64 = 5.477225575051661;
    try std.testing.expectApproxEqAbs(expected, mag, std.math.floatEps(f64));
}