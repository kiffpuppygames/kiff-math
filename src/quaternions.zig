/// Common Quaternion Operations:
/// Operation       | Description                                               | Use Cases
/// Multiplication  | Combines two rotations, results in a new quaternion       | Combining rotations, 3D transformations
/// Conjugate       | Negates the imaginary part, used to find inverse          | Inverting rotations, quaternion division (Not implemented use inverse instead)
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
pub inline fn mul(q1: anytype, q2: anytype) @TypeOf(q2)
{
    @setFloatMode(.optimized);
    const T = comptime @TypeOf(q2);
    const Te = comptime @typeInfo(T).vector.child;

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

/// The conjugate of the provided quaterninon
pub inline fn conjugate(q: anytype) @TypeOf(q)
{
    @setFloatMode(.optimized);
    return .{ q[0], -q[1], -q[2], -q[3] };
}

/// This will normalize before getting the inverse. 
pub inline fn inverse(q: anytype) @TypeOf(q)
{
    @setFloatMode(.optimized);
    return conjugate(vectors.normalize(q));
}

/// This will not nomalize before getting the inverse. 
pub inline fn inverse_normalized(q: anytype) @TypeOf(q)
{
    @setFloatMode(.optimized);
    return conjugate(q);
}

/// This funtion requiers that the quaternion be a unit/normalized quaternion
pub inline fn rotate_vec(v: anytype, qr: anytype) @TypeOf(v)
{    
    @setFloatMode(.optimized);

    const Tqr = comptime @TypeOf(qr);

    const qv = Tqr {0, v[0], v[1], v[2] };
    const qvr = mul( mul(qr, qv), conjugate(qr));
    return .{ qvr[1], qvr[2], qvr[3] };
}

pub inline fn lerp(q1: anytype, q2: anytype, factor: f64) @TypeOf(q1, q2)
{
    var dot = vectors.dot(q1, q2);
    var q2_shortest = q2;
    
    if (dot < 0)
    {
        dot = -dot;
        q2_shortest = vectors.negate(q2);
    }
    
    const q = @TypeOf(q1, q2) { q1[0] * (1.0 - factor) + q2_shortest[0] * factor, q1[1] * (1.0 - factor) + q2_shortest[1] * factor, q1[2] * (1.0 - factor) + q2_shortest[2] * factor, q1[3] * (1.0 - factor) + q2_shortest[3] * factor };
    return vectors.normalize(q);    
}

pub inline fn slerp(q1: anytype, q2: anytype, factor: f64) @TypeOf(q1, q2)
{
    var dot = vectors.dot(q1, q2);
    var q2_shortest = q2;
    
    if (dot < 0)
    {
        dot = -dot;
        q2_shortest = vectors.negate(q2);
    }

    const epsilon = 1e-6;
    if (dot > 1.0 - epsilon) 
    {
        // If quaternions are very close, use LERP
        return lerp(q1, q2_shortest, factor);
    }

    const theta = std.math.acos(dot);
    const sin_theta = @sin(theta);

    const sin_theta_inv = 1.0 / sin_theta;
    const factor1 = @sin((1.0 - factor) * theta) * sin_theta_inv;
    const factor2 = @sin(factor * theta) * sin_theta_inv;

    return .{ q1[0] * factor1 + q2_shortest[0] * factor2, q1[1] * factor1 + q2_shortest[1] * factor2, q1[2] * factor1 + q2_shortest[2] * factor2, q1[3] * factor1 + q2_shortest[3] * factor2 };
}

pub inline fn approx_equal(q1: anytype, q2: anytype) bool
{
    const eps = comptime std.math.floatEps(f64);
    return @abs(q1[0] - q2[0]) < eps and  @abs(q1[1] - q2[1]) < eps and @abs(q1[2] - q2[2]) < eps and @abs(q1[3] - q2[3]) < eps;
}

test "Quaternion slerp" {
    // Define two quaternions to interpolate between
    const q1 = @Vector(4, f64) { 1.0, 0.0, 0.0, 0.0 }; // Identity quaternion
    const q2 = @Vector(4, f64) { 0.7071067811865476, 0.0, 0.7071067811865475, 0.0 }; // 90-degree rotation about the Y-axis

    // 1. Test t = 0 (should return q1)
    const result_t0 = slerp(q1, q2, 0.0);
    try test_quat_expect_approx_eq_abs(result_t0, q1);

    // 2. Test t = 1 (should return q2)
    const result_t1 = slerp(q1, q2, 1.0);
    try test_quat_expect_approx_eq_abs(q2, result_t1);

    // 3. Test t = 0.5 (should return halfway between q1 and q2)
    const expected_halfway = @Vector(4, f64) { 0.9238795325112867, 0.0, 0.3826834323650898, 0.0 }; // 45-degree rotation
    const result_t05 = slerp(q1, q2, 0.5);
    try test_quat_expect_approx_eq_abs(result_t05, expected_halfway);

    // 4. Check the result is normalized (unit quaternion) for t = 0.5
    const normalized_result = vectors.normalize(result_t05);
    const mag = vectors.magnitude(normalized_result);

    const eps = comptime std.math.floatEps(f64);
    try std.testing.expectApproxEqAbs(1.0, mag, eps);
}

fn test_quat_expect_approx_eq_abs(expected: anytype, actual: anytype) !void
{
    const eps = comptime std.math.floatEps(f64);
    try std.testing.expectApproxEqAbs(expected[0], actual[0], eps);
    try std.testing.expectApproxEqAbs(expected[1], actual[1], eps);
    try std.testing.expectApproxEqAbs(expected[2], actual[2], eps);
    try std.testing.expectApproxEqAbs(expected[3], actual[3], eps);
}

test "Quaternion Multiplication"
{
    const q1 = @Vector(4, f64) {1, 0, 1, 0};
    const q2 = @Vector(4, f64) {1, 0.5, 0.5, 0.75};

    // 𝑞1⋅𝑞2=(𝑤1𝑤2−𝑥1𝑥2−𝑦1𝑦2−𝑧1𝑧2,𝑤1𝑥2+𝑥1𝑤2+𝑦1𝑧2−𝑧1𝑦2,𝑤1𝑦2+𝑦1𝑤2+𝑧1𝑥2−𝑥1𝑧2,𝑤1𝑧2+𝑧1𝑤2+𝑥1𝑦2−𝑦1𝑥2)
    // 1*1-0*0.5-1*0.5-0*0.75
    // 1-0.5-0-0
    // 0.5

    const prod = mul(q1, q2);

    const expected: @Vector(4, f64) = .{0.5, 1.25, 1.5, 0.25};
    try std.testing.expectEqual(prod, expected);
}

test "Quaternion Inverse"
{
    const q = @Vector(4, f64) {1, 0.5, 0.5, 0.75};

    const inv = inverse(q);

    const expected: @Vector(4, f64) = .{ 0.6963106238227914, -0.34815531191139570, -0.34815531191139570, -0.52223296786709361 };

    try test_quat_expect_approx_eq_abs(expected, inv);
}

test "Quaternion Rotate Vector"
{
    const eps = comptime std.math.floatEps(f64);
    const q = @Vector(4, f64) {0.7071067811865476, 0, 0, 0.7071067811865476};
    const v = @Vector(3, f64) { 1, 0, 0 };
    const expected = @Vector(3, f64) { 0, 1, 0 };

    const vr = rotate_vec(v, q);

    try std.testing.expectApproxEqAbs(expected[0], vr[0], eps);
    try std.testing.expectApproxEqAbs(expected[1], vr[1], eps);
    try std.testing.expectApproxEqAbs(expected[2], vr[2], eps);
}