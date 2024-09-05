const std = @import("std");

const testing = std.testing;
const expect = testing.expect;
const expectEqual = testing.expectEqual;

const vectors = @import("vectors.zig");
const bool_vectors = @import("bool_vectors.zig");

const Vec2 = @import("Vec2.zig");
const Vec3 = @import("Vec3.zig");
const Vec4 = @import("Vec4.zig");
const IVec2 = @import("IVec2.zig");
const IVec3 = @import("IVec3.zig");
const IVec4 = @import("IVec4.zig");

const F32Vec2 = @import("Vec2.zig");
const F32Vec3 = @import("Vec3.zig");
const F32Vec4 = @import("Vec4.zig");
const I32Vec2 = @import("IVec2.zig");
const I32Vec3 = @import("IVec3.zig");
const I32Vec4 = @import("IVec4.zig");

test "Create a new Vec2 from a slice of values" {
    const values = [2]f64{ 1.0, 2.0 };
    const vec = vectors.new(Vec2, f64, values);
    const expected = @Vector(2, f64){ 1.0, 2.0 };
    try expectEqual(vec.values, expected);
}

test "Fail to create a new Vec2 from a slice of values" {
    const values = [2]f64{ 1, 2 };
    const vec = vectors.new(Vec2, f64, values);
    const expected = @Vector(2, f64){ 3, 4 };

    var ok = true;

    if (@reduce(.And, (vec.values == expected))) {
        ok = false;
    }
    try expect(ok);
}

test "Create a new Vec from a single value" 
{
    const vec = vectors.splat(Vec2, f64, 1.0);
    const expected = @Vector(2, f64){ 1.0, 1.0 };
    try expectEqual(vec.values, expected);
}

test "Create a new Vec from a slice of values" {
    const values: [3]f64 = .{ 1, 2, 3 };
    const vec = vectors.new(Vec3, f64, values);
    const expected = @Vector(3, f64){ 1, 2, 3 };
    try expectEqual(vec.values, expected);
}

test "Is not a number" {
    {
        const v0 = Vec4.new(std.math.inf(f32), std.math.nan(f32), std.math.nan(f32), 7.0);
        const b = vectors.is_NAN(Vec4, v0);
        try std.testing.expect(@reduce(.And, b == bool_vectors.BVec4.new(false, true, true, false).values));
    }
}

test "Is any true" 
{
    try std.testing.expect(vectors.any_true(bool_vectors.BVec4.new(false, false, true, false)) == true);
    try std.testing.expect(vectors.any_true(bool_vectors.BVec4.new(false, false, false, true)) == false);
}
