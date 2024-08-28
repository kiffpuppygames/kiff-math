const std = @import("std");

const testing = std.testing;
const expect = testing.expect;
const expectEqual = testing.expectEqual;

const vectors = @import("vectors.zig");

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
    const vec = vectors.new(Vec2, f64, 2, 2, values);
    const expected = @Vector(2, f64){ 1.0, 2.0 };
    try expectEqual(vec.values, expected);
}

test "Fail to create a new Vec2 from a slice of values" {
    const values = [2]f64{ 1, 2 };
    const vec = vectors.new(Vec2, f64, 2, 2, values);
    const expected = @Vector(2, f64){ 3, 4 };
    
    var ok = true;
    
    if (@reduce( .And, (vec.values == expected)))
    {
        ok = false;        
    }
    try expect(ok);
}

test "Create a new Vec2 from a single value" {
    const values: [1]f64 = .{1.0};
    const vec = vectors.new(Vec2, f64, 2, 1, values);
    const expected = @Vector(2, f64){ 1.0, 1.0 };
    try expectEqual(vec.values, expected);
}

test "Create a new Vec3 from a slice of values" {
    const values: [3]f64 = .{1, 2, 3};
    const vec = vectors.new(Vec3, f64, 3, 3, values);
    const expected = @Vector(3, f64){ 1, 2, 3 };
    try expectEqual(vec.values, expected);
}

test "Create a new Vec3 from a single value" {    
    const values: [1]f64 = .{1};
    const vec = vectors.new(Vec3, f64, 3, 1, values);
    const expected = @Vector(3, f64){ 1, 1, 1 };
    try expectEqual(vec.values, expected);
}
