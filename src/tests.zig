const builtin = @import("builtin");
const std = @import("std");
const math = std.math;
const vectors = @import("vectors.zig");
const km = @import("kmath.zig");
const util = @import("util.zig");

test "kmath.load" {
    const a = [7]f32{ 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0 };
    var ptr = &a;
    var i: u32 = 0;
    const v0 = km.vectors.load(a[i..], km.vectors.F32x4, 2);
    try km.expectVecEqual(v0, km.vectors.F32x4{ 1.0, 2.0, 0.0, 0.0 });
    i += 2;
    const v1 = km.vectors.load(a[i .. i + 2], km.vectors.F32x4, 2);
    try km.expectVecEqual(v1, km.vectors.F32x4{ 3.0, 4.0, 0.0, 0.0 });
    const v2 = km.vectors.load(a[5..7], km.vectors.F32x4, 2);
    try km.expectVecEqual(v2, km.vectors.F32x4{ 6.0, 7.0, 0.0, 0.0 });
    const v3 = km.vectors.load(ptr[1..], km.vectors.F32x4, 2);
    try km.expectVecEqual(v3, km.vectors.F32x4{ 2.0, 3.0, 0.0, 0.0 });
    i += 1;
    const v4 = km.vectors.load(ptr[i .. i + 2], km.vectors.F32x4, 2);
    try km.expectVecEqual(v4, km.vectors.F32x4{ 4.0, 5.0, 0.0, 0.0 });
}

test "kmath.store" {
    var a = [7]f32{ 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0 };
    const v = km.vectors.load(a[1..], km.vectors.F32x4, 3);
    km.vectors.store(a[2..], v, 4);
    try std.testing.expect(a[0] == 1.0);
    try std.testing.expect(a[1] == 2.0);
    try std.testing.expect(a[2] == 2.0);
    try std.testing.expect(a[3] == 3.0);
    try std.testing.expect(a[4] == 4.0);
    try std.testing.expect(a[5] == 0.0);
}

test "kmath.arrNPtr" {
    {
        const mat = km.identity();
        const f32ptr = km.arrNPtr(&mat);
        try std.testing.expect(f32ptr[0] == 1.0);
        try std.testing.expect(f32ptr[5] == 1.0);
        try std.testing.expect(f32ptr[10] == 1.0);
        try std.testing.expect(f32ptr[15] == 1.0);
    }
    {
        const v8 = km.vectors.f32x8s(1.0);
        const f32ptr = km.arrNPtr(&v8);
        try std.testing.expect(f32ptr[1] == 1.0);
        try std.testing.expect(f32ptr[7] == 1.0);
    }
}

test "kmath.loadArr" {
    {
        const camera_position = [3]f32{ 1.0, 2.0, 3.0 };
        const simd_reg = km.vectors.loadArr3(camera_position);
        try km.expectVecEqual(simd_reg, km.vectors.f32x4(1.0, 2.0, 3.0, 0.0));
    }
    {
        const camera_position = [3]f32{ 1.0, 2.0, 3.0 };
        const simd_reg = km.vectors.loadArr3w(camera_position, 1.0);
        try km.expectVecEqual(simd_reg, km.vectors.f32x4(1.0, 2.0, 3.0, 1.0));
    }
}

test "kmath.km.all" {
    try std.testing.expect(km.all(km.vectors.boolx8(true, true, true, true, true, false, true, false), 5) == true);
    try std.testing.expect(km.all(km.vectors.boolx8(true, true, true, true, true, false, true, false), 6) == false);
    try std.testing.expect(km.all(km.vectors.boolx8(true, true, true, true, false, false, false, false), 4) == true);
    try std.testing.expect(km.all(km.vectors.boolx4(true, true, true, false), 3) == true);
    try std.testing.expect(km.all(km.vectors.boolx4(true, true, true, false), 1) == true);
    try std.testing.expect(km.all(km.vectors.boolx4(true, false, false, false), 1) == true);
    try std.testing.expect(km.all(km.vectors.boolx4(false, true, false, false), 1) == false);
    try std.testing.expect(km.all(km.vectors.boolx8(true, true, true, true, true, false, true, false), 0) == false);
    try std.testing.expect(km.all(km.vectors.boolx4(false, true, false, false), 0) == false);
    try std.testing.expect(km.all(km.vectors.boolx4(true, true, true, true), 0) == true);
}

test "kmath.km.isNearEqual" {
    {
        const v0 = km.vectors.f32x4(1.0, 2.0, -3.0, 4.001);
        const v1 = km.vectors.f32x4(1.0, 2.1, 3.0, 4.0);
        const b = km.isNearEqual(v0, v1, km.vectors.splat(km.vectors.F32x4, 0.01));
        try std.testing.expect(@reduce(.And, b == km.vectors.boolx4(true, false, false, true)));
    }
    {
        const v0 = km.vectors.f32x8(1.0, 2.0, -3.0, 4.001, 1.001, 2.3, -0.0, 0.0);
        const v1 = km.vectors.f32x8(1.0, 2.1, 3.0, 4.0, -1.001, 2.1, 0.0, 0.0);
        const b = km.isNearEqual(v0, v1, km.vectors.splat(km.vectors.F32x8, 0.01));
        try std.testing.expect(@reduce(.And, b == km.vectors.boolx8(true, false, false, true, false, false, true, true)));
    }
    try std.testing.expect(km.all(km.isNearEqual(
        km.vectors.splat(km.vectors.F32x4, math.inf(f32)),
        km.vectors.splat(km.vectors.F32x4, math.inf(f32)),
        km.vectors.splat(km.vectors.F32x4, 0.0001),
    ), 0) == false);
    try std.testing.expect(km.all(km.isNearEqual(
        km.vectors.splat(km.vectors.F32x4, -math.inf(f32)),
        km.vectors.splat(km.vectors.F32x4, math.inf(f32)),
        km.vectors.splat(km.vectors.F32x4, 0.0001),
    ), 0) == false);
    try std.testing.expect(km.all(km.isNearEqual(
        km.vectors.splat(km.vectors.F32x4, -math.inf(f32)),
        km.vectors.splat(km.vectors.F32x4, -math.inf(f32)),
        km.vectors.splat(km.vectors.F32x4, 0.0001),
    ), 0) == false);
    try std.testing.expect(km.all(km.isNearEqual(
        km.vectors.splat(km.vectors.F32x4, -math.nan(f32)),
        km.vectors.splat(km.vectors.F32x4, math.inf(f32)),
        km.vectors.splat(km.vectors.F32x4, 0.0001),
    ), 0) == false);
}

test "kmath.isInf" {
    {
        const v0 = km.vectors.f32x4(math.inf(f32), math.nan(f32), math.snan(f32), 7.0);
        const b = km.isInf(v0);
        try std.testing.expect(@reduce(.And, b == km.vectors.boolx4(true, false, false, false)));
    }
    {
        const v0 = km.vectors.f32x8(0, math.inf(f32), 0, 0, math.inf(f32), math.nan(f32), math.snan(f32), 7.0);
        const b = km.isInf(v0);
        try std.testing.expect(@reduce(.And, b == km.vectors.boolx8(false, true, false, false, true, false, false, false)));
    }
}

test "kmath.km.isInBounds" {
    {
        const v0 = km.vectors.f32x4(0.5, -2.0, -1.0, 1.9);
        const v1 = km.vectors.f32x4(-1.6, -2.001, -1.0, 1.9);
        const bounds = km.vectors.f32x4(1.0, 2.0, 1.0, 2.0);
        const b0 = km.isInBounds(v0, bounds);
        const b1 = km.isInBounds(v1, bounds);
        try std.testing.expect(@reduce(.And, b0 == km.vectors.boolx4(true, true, true, true)));
        try std.testing.expect(@reduce(.And, b1 == km.vectors.boolx4(false, false, true, true)));
    }
    {
        const v0 = km.vectors.f32x8(2.0, 1.0, 2.0, 1.0, 0.5, -2.0, -1.0, 1.9);
        const bounds = km.vectors.f32x8(1.0, 1.0, 1.0, math.inf(f32), 1.0, math.nan(f32), 1.0, 2.0);
        const b0 = km.isInBounds(v0, bounds);
        try std.testing.expect(@reduce(.And, b0 == km.vectors.boolx8(false, true, false, true, true, false, true, true)));
    }
}

test "kmath.km.andInt" {
    {
        const v0 = km.vectors.f32x4(0, @as(f32, @bitCast(~@as(u32, 0))), 0, @as(f32, @bitCast(~@as(u32, 0))));
        const v1 = km.vectors.f32x4(1.0, 2.0, 3.0, math.inf(f32));
        const v = km.andInt(v0, v1);
        try std.testing.expect(v[3] == math.inf(f32));
        try km.expectVecEqual(v, km.vectors.f32x4(0.0, 2.0, 0.0, math.inf(f32)));
    }
    {
        const v0 = km.vectors.f32x8(0, 0, 0, 0, 0, @as(f32, @bitCast(~@as(u32, 0))), 0, @as(f32, @bitCast(~@as(u32, 0))));
        const v1 = km.vectors.f32x8(0, 0, 0, 0, 1.0, 2.0, 3.0, math.inf(f32));
        const v = km.andInt(v0, v1);
        try std.testing.expect(v[7] == math.inf(f32));
        try km.expectVecEqual(v, km.vectors.f32x8(0, 0, 0, 0, 0.0, 2.0, 0.0, math.inf(f32)));
    }
}

test "kmath.km.andNotInt" {
    {
        const v0 = km.vectors.f32x4(1.0, 2.0, 3.0, 4.0);
        const v1 = km.vectors.f32x4(0, @as(f32, @bitCast(~@as(u32, 0))), 0, @as(f32, @bitCast(~@as(u32, 0))));
        const v = km.andNotInt(v1, v0);
        try km.expectVecEqual(v, km.vectors.f32x4(1.0, 0.0, 3.0, 0.0));
    }
    {
        const v0 = km.vectors.f32x8(0, 0, 0, 0, 1.0, 2.0, 3.0, 4.0);
        const v1 = km.vectors.f32x8(0, 0, 0, 0, 0, @as(f32, @bitCast(~@as(u32, 0))), 0, @as(f32, @bitCast(~@as(u32, 0))));
        const v = km.andNotInt(v1, v0);
        try km.expectVecEqual(v, km.vectors.f32x8(0, 0, 0, 0, 1.0, 0.0, 3.0, 0.0));
    }
}

test "kmath.km.orInt" {
    {
        const v0 = km.vectors.f32x4(0, @as(f32, @bitCast(~@as(u32, 0))), 0, 0);
        const v1 = km.vectors.f32x4(1.0, 2.0, 3.0, 4.0);
        const v = km.orInt(v0, v1);
        try std.testing.expect(v[0] == 1.0);
        try std.testing.expect(@as(u32, @bitCast(v[1])) == ~@as(u32, 0));
        try std.testing.expect(v[2] == 3.0);
        try std.testing.expect(v[3] == 4.0);
    }
    {
        const v0 = km.vectors.f32x8(0, 0, 0, 0, 0, @as(f32, @bitCast(~@as(u32, 0))), 0, 0);
        const v1 = km.vectors.f32x8(0, 0, 0, 0, 1.0, 2.0, 3.0, 4.0);
        const v = km.orInt(v0, v1);
        try std.testing.expect(v[4] == 1.0);
        try std.testing.expect(@as(u32, @bitCast(v[5])) == ~@as(u32, 0));
        try std.testing.expect(v[6] == 3.0);
        try std.testing.expect(v[7] == 4.0);
    }
}

test "kmath.km.minFast" {
    {
        const v0 = km.vectors.f32x4(1.0, 3.0, 2.0, 7.0);
        const v1 = km.vectors.f32x4(2.0, 1.0, 4.0, math.inf(f32));
        const v = km.minFast(v0, v1);
        try km.expectVecEqual(v, km.vectors.f32x4(1.0, 1.0, 2.0, 7.0));
    }
    {
        const v0 = km.vectors.f32x4(1.0, math.nan(f32), 5.0, math.snan(f32));
        const v1 = km.vectors.f32x4(2.0, 1.0, 4.0, math.inf(f32));
        const v = km.minFast(v0, v1);
        try std.testing.expect(v[0] == 1.0);
        try std.testing.expect(v[1] == 1.0);
        try std.testing.expect(!math.isNan(v[1]));
        try std.testing.expect(v[2] == 4.0);
        try std.testing.expect(v[3] == math.inf(f32));
        try std.testing.expect(!math.isNan(v[3]));
    }
}

test "kmath.km.maxFast" {
    {
        const v0 = km.vectors.f32x4(1.0, 3.0, 2.0, 7.0);
        const v1 = km.vectors.f32x4(2.0, 1.0, 4.0, math.inf(f32));
        const v = km.maxFast(v0, v1);
        try km.expectVecEqual(v, km.vectors.f32x4(2.0, 3.0, 4.0, math.inf(f32)));
    }
    {
        const v0 = km.vectors.f32x4(1.0, math.nan(f32), 5.0, math.snan(f32));
        const v1 = km.vectors.f32x4(2.0, 1.0, 4.0, math.inf(f32));
        const v = km.maxFast(v0, v1);
        try std.testing.expect(v[0] == 2.0);
        try std.testing.expect(v[1] == 1.0);
        try std.testing.expect(v[2] == 5.0);
        try std.testing.expect(v[3] == math.inf(f32));
        try std.testing.expect(!math.isNan(v[3]));
    }
}

test "kmath.min" {
    // Ckm.alling math.inf causes test to fail!
    if (builtin.target.os.tag == .macos and builtin.target.cpu.arch == .aarch64) return error.SkipZigTest;
    {
        const v0 = km.vectors.f32x4(1.0, 3.0, 2.0, 7.0);
        const v1 = km.vectors.f32x4(2.0, 1.0, 4.0, math.inf(f32));
        const v = km.min(v0, v1);
        try km.expectVecEqual(v, km.vectors.f32x4(1.0, 1.0, 2.0, 7.0));
    }
    {
        const v0 = km.vectors.f32x8(0, 0, -2.0, 0, 1.0, 3.0, 2.0, 7.0);
        const v1 = km.vectors.f32x8(0, 1.0, 0, 0, 2.0, 1.0, 4.0, math.inf(f32));
        const v = km.min(v0, v1);
        try km.expectVecEqual(v, km.vectors.f32x8(0.0, 0.0, -2.0, 0.0, 1.0, 1.0, 2.0, 7.0));
    }
    {
        const v0 = km.vectors.f32x4(1.0, math.nan(f32), 5.0, math.snan(f32));
        const v1 = km.vectors.f32x4(2.0, 1.0, 4.0, math.inf(f32));
        const v = km.min(v0, v1);
        try std.testing.expect(v[0] == 1.0);
        try std.testing.expect(v[1] == 1.0);
        try std.testing.expect(!math.isNan(v[1]));
        try std.testing.expect(v[2] == 4.0);
        try std.testing.expect(v[3] == math.inf(f32));
        try std.testing.expect(!math.isNan(v[3]));
    }

    {
        const v0 = km.vectors.f32x4(-math.inf(f32), math.inf(f32), math.inf(f32), math.snan(f32));
        const v1 = km.vectors.f32x4(math.snan(f32), -math.inf(f32), math.snan(f32), math.nan(f32));
        const v = km.min(v0, v1);
        try std.testing.expect(v[0] == -math.inf(f32));
        try std.testing.expect(v[1] == -math.inf(f32));
        try std.testing.expect(v[2] == math.inf(f32));
        try std.testing.expect(!math.isNan(v[2]));
        try std.testing.expect(math.isNan(v[3]));
        try std.testing.expect(!math.isInf(v[3]));
    }
}

test "kmath.max" {
    // Ckm.alling math.inf causes test to fail!
    if (builtin.target.os.tag == .macos and builtin.target.cpu.arch == .aarch64) return error.SkipZigTest;
    {
        const v0 = km.vectors.f32x4(1.0, 3.0, 2.0, 7.0);
        const v1 = km.vectors.f32x4(2.0, 1.0, 4.0, math.inf(f32));
        const v = km.max(v0, v1);
        try km.expectVecEqual(v, km.vectors.f32x4(2.0, 3.0, 4.0, math.inf(f32)));
    }
    {
        const v0 = km.vectors.f32x8(0, 0, -2.0, 0, 1.0, 3.0, 2.0, 7.0);
        const v1 = km.vectors.f32x8(0, 1.0, 0, 0, 2.0, 1.0, 4.0, math.inf(f32));
        const v = km.max(v0, v1);
        try km.expectVecEqual(v, km.vectors.f32x8(0.0, 1.0, 0.0, 0.0, 2.0, 3.0, 4.0, math.inf(f32)));
    }
    {
        const v0 = km.vectors.f32x4(1.0, math.nan(f32), 5.0, math.snan(f32));
        const v1 = km.vectors.f32x4(2.0, 1.0, 4.0, math.inf(f32));
        const v = km.max(v0, v1);
        try std.testing.expect(v[0] == 2.0);
        try std.testing.expect(v[1] == 1.0);
        try std.testing.expect(v[2] == 5.0);
        try std.testing.expect(v[3] == math.inf(f32));
        try std.testing.expect(!math.isNan(v[3]));
    }
    {
        const v0 = km.vectors.f32x4(-math.inf(f32), math.inf(f32), math.inf(f32), math.snan(f32));
        const v1 = km.vectors.f32x4(math.snan(f32), -math.inf(f32), math.snan(f32), math.nan(f32));
        const v = km.max(v0, v1);
        try std.testing.expect(v[0] == -math.inf(f32));
        try std.testing.expect(v[1] == math.inf(f32));
        try std.testing.expect(v[2] == math.inf(f32));
        try std.testing.expect(!math.isNan(v[2]));
        try std.testing.expect(math.isNan(v[3]));
        try std.testing.expect(!math.isInf(v[3]));
    }
}

test "kmath.round" {
    {
        try std.testing.expect(km.all(km.round(km.vectors.splat(km.vectors.F32x4, math.inf(f32))) == km.vectors.splat(km.vectors.F32x4, math.inf(f32)), 0));
        try std.testing.expect(km.all(km.round(km.vectors.splat(km.vectors.F32x4, -math.inf(f32))) == km.vectors.splat(km.vectors.F32x4, -math.inf(f32)), 0));
        try std.testing.expect(km.all(km.isNan(km.round(km.vectors.splat(km.vectors.F32x4, math.nan(f32)))), 0));
        try std.testing.expect(km.all(km.isNan(km.round(km.vectors.splat(km.vectors.F32x4, -math.nan(f32)))), 0));
        try std.testing.expect(km.all(km.isNan(km.round(km.vectors.splat(km.vectors.F32x4, math.snan(f32)))), 0));
        try std.testing.expect(km.all(km.isNan(km.round(km.vectors.splat(km.vectors.F32x4, -math.snan(f32)))), 0));
    }
    {
        const v = km.round(km.vectors.f32x16(1.1, -1.1, -1.5, 1.5, 2.1, 2.8, 2.9, 4.1, 5.8, 6.1, 7.9, 8.9, 10.1, 11.2, 12.7, 13.1));
        try km.expectVecApproxEqAbs(
            v,
            km.vectors.f32x16(1.0, -1.0, -2.0, 2.0, 2.0, 3.0, 3.0, 4.0, 6.0, 6.0, 8.0, 9.0, 10.0, 11.0, 13.0, 13.0),
            0.0,
        );
    }
    var v = km.round(km.vectors.f32x4(1.1, -1.1, -1.5, 1.5));
    try km.expectVecEqual(v, km.vectors.f32x4(1.0, -1.0, -2.0, 2.0));

    const v1 = km.vectors.f32x4(-10_000_000.1, -math.inf(f32), 10_000_001.5, math.inf(f32));
    v = km.round(v1);
    try std.testing.expect(v[3] == math.inf(f32));
    try km.expectVecEqual(v, km.vectors.f32x4(-10_000_000.1, -math.inf(f32), 10_000_001.5, math.inf(f32)));

    const v2 = km.vectors.f32x4(-math.snan(f32), math.snan(f32), math.nan(f32), -math.inf(f32));
    v = km.round(v2);
    try std.testing.expect(math.isNan(v2[0]));
    try std.testing.expect(math.isNan(v2[1]));
    try std.testing.expect(math.isNan(v2[2]));
    try std.testing.expect(v2[3] == -math.inf(f32));

    const v3 = km.vectors.f32x4(1001.5, -201.499, -10000.99, -101.5);
    v = km.round(v3);
    try km.expectVecEqual(v, km.vectors.f32x4(1002.0, -201.0, -10001.0, -102.0));

    const v4 = km.vectors.f32x4(-1_388_609.9, 1_388_609.5, 1_388_109.01, 2_388_609.5);
    v = km.round(v4);
    try km.expectVecEqual(v, km.vectors.f32x4(-1_388_610.0, 1_388_610.0, 1_388_109.0, 2_388_610.0));

    var f: f32 = -100.0;
    var i: u32 = 0;
    while (i < 100) : (i += 1) {
        const vr = km.round(km.vectors.splat(km.vectors.F32x4, f));
        const fr = @round(km.vectors.splat(km.vectors.F32x4, f));
        const vr8 = km.round(km.vectors.splat(km.vectors.F32x8, f));
        const fr8 = @round(km.vectors.splat(km.vectors.F32x8, f));
        const vr16 = km.round(km.vectors.splat(km.vectors.F32x16, f));
        const fr16 = @round(km.vectors.splat(km.vectors.F32x16, f));
        try km.expectVecEqual(vr, fr);
        try km.expectVecEqual(vr8, fr8);
        try km.expectVecEqual(vr16, fr16);
        f += 0.12345 * @as(f32, @floatFromInt(i));
    }
}

test "kmath.trunc" {
    {
        try std.testing.expect(km.all(km.trunc(km.vectors.splat(km.vectors.F32x4, math.inf(f32))) == km.vectors.splat(km.vectors.F32x4, math.inf(f32)), 0));
        try std.testing.expect(km.all(km.trunc(km.vectors.splat(km.vectors.F32x4, -math.inf(f32))) == km.vectors.splat(km.vectors.F32x4, -math.inf(f32)), 0));
        try std.testing.expect(km.all(km.isNan(km.trunc(km.vectors.splat(km.vectors.F32x4, math.nan(f32)))), 0));
        try std.testing.expect(km.all(km.isNan(km.trunc(km.vectors.splat(km.vectors.F32x4, -math.nan(f32)))), 0));
        try std.testing.expect(km.all(km.isNan(km.trunc(km.vectors.splat(km.vectors.F32x4, math.snan(f32)))), 0));
        try std.testing.expect(km.all(km.isNan(km.trunc(km.vectors.splat(km.vectors.F32x4, -math.snan(f32)))), 0));
    }
    {
        const v = km.trunc(km.vectors.f32x16(1.1, -1.1, -1.5, 1.5, 2.1, 2.8, 2.9, 4.1, 5.8, 6.1, 7.9, 8.9, 10.1, 11.2, 12.7, 13.1));
        try km.expectVecApproxEqAbs(
            v,
            km.vectors.f32x16(1.0, -1.0, -1.0, 1.0, 2.0, 2.0, 2.0, 4.0, 5.0, 6.0, 7.0, 8.0, 10.0, 11.0, 12.0, 13.0),
            0.0,
        );
    }
    var v = km.trunc(km.vectors.f32x4(1.1, -1.1, -1.5, 1.5));
    try km.expectVecEqual(v, km.vectors.f32x4(1.0, -1.0, -1.0, 1.0));

    v = km.trunc(km.vectors.f32x4(-10_000_002.1, -math.inf(f32), 10_000_001.5, math.inf(f32)));
    try km.expectVecEqual(v, km.vectors.f32x4(-10_000_002.1, -math.inf(f32), 10_000_001.5, math.inf(f32)));

    v = km.trunc(km.vectors.f32x4(-math.snan(f32), math.snan(f32), math.nan(f32), -math.inf(f32)));
    try std.testing.expect(math.isNan(v[0]));
    try std.testing.expect(math.isNan(v[1]));
    try std.testing.expect(math.isNan(v[2]));
    try std.testing.expect(v[3] == -math.inf(f32));

    v = km.trunc(km.vectors.f32x4(1000.5001, -201.499, -10000.99, 100.750001));
    try km.expectVecEqual(v, km.vectors.f32x4(1000.0, -201.0, -10000.0, 100.0));

    v = km.trunc(km.vectors.f32x4(-7_388_609.5, 7_388_609.1, 8_388_109.5, -8_388_509.5));
    try km.expectVecEqual(v, km.vectors.f32x4(-7_388_609.0, 7_388_609.0, 8_388_109.0, -8_388_509.0));

    var f: f32 = -100.0;
    var i: u32 = 0;
    while (i < 100) : (i += 1) {
        const vr = km.trunc(km.vectors.splat(km.vectors.F32x4, f));
        const fr = @trunc(km.vectors.splat(km.vectors.F32x4, f));
        const vr8 = km.trunc(km.vectors.splat(km.vectors.F32x8, f));
        const fr8 = @trunc(km.vectors.splat(km.vectors.F32x8, f));
        const vr16 = km.trunc(km.vectors.splat(km.vectors.F32x16, f));
        const fr16 = @trunc(km.vectors.splat(km.vectors.F32x16, f));
        try km.expectVecEqual(vr, fr);
        try km.expectVecEqual(vr8, fr8);
        try km.expectVecEqual(vr16, fr16);
        f += 0.12345 * @as(f32, @floatFromInt(i));
    }
}

test "kmath.floor" {
    {
        try std.testing.expect(km.all(km.floor(km.vectors.splat(km.vectors.F32x4, math.inf(f32))) == km.vectors.splat(km.vectors.F32x4, math.inf(f32)), 0));
        try std.testing.expect(km.all(km.floor(km.vectors.splat(km.vectors.F32x4, -math.inf(f32))) == km.vectors.splat(km.vectors.F32x4, -math.inf(f32)), 0));
        try std.testing.expect(km.all(km.isNan(km.floor(km.vectors.splat(km.vectors.F32x4, math.nan(f32)))), 0));
        try std.testing.expect(km.all(km.isNan(km.floor(km.vectors.splat(km.vectors.F32x4, -math.nan(f32)))), 0));
        try std.testing.expect(km.all(km.isNan(km.floor(km.vectors.splat(km.vectors.F32x4, math.snan(f32)))), 0));
        try std.testing.expect(km.all(km.isNan(km.floor(km.vectors.splat(km.vectors.F32x4, -math.snan(f32)))), 0));
    }
    {
        const v = km.floor(km.vectors.f32x16(1.1, -1.1, -1.5, 1.5, 2.1, 2.8, 2.9, 4.1, 5.8, 6.1, 7.9, 8.9, 10.1, 11.2, 12.7, 13.1));
        try km.expectVecApproxEqAbs(
            v,
            km.vectors.f32x16(1.0, -2.0, -2.0, 1.0, 2.0, 2.0, 2.0, 4.0, 5.0, 6.0, 7.0, 8.0, 10.0, 11.0, 12.0, 13.0),
            0.0,
        );
    }
    var v = km.floor(km.vectors.f32x4(1.5, -1.5, -1.7, -2.1));
    try km.expectVecEqual(v, km.vectors.f32x4(1.0, -2.0, -2.0, -3.0));

    v = km.floor(km.vectors.f32x4(-10_000_002.1, -math.inf(f32), 10_000_001.5, math.inf(f32)));
    try km.expectVecEqual(v, km.vectors.f32x4(-10_000_002.1, -math.inf(f32), 10_000_001.5, math.inf(f32)));

    v = km.floor(km.vectors.f32x4(-math.snan(f32), math.snan(f32), math.nan(f32), -math.inf(f32)));
    try std.testing.expect(math.isNan(v[0]));
    try std.testing.expect(math.isNan(v[1]));
    try std.testing.expect(math.isNan(v[2]));
    try std.testing.expect(v[3] == -math.inf(f32));

    v = km.floor(km.vectors.f32x4(1000.5001, -201.499, -10000.99, 100.75001));
    try km.expectVecEqual(v, km.vectors.f32x4(1000.0, -202.0, -10001.0, 100.0));

    v = km.floor(km.vectors.f32x4(-7_388_609.5, 7_388_609.1, 8_388_109.5, -8_388_509.5));
    try km.expectVecEqual(v, km.vectors.f32x4(-7_388_610.0, 7_388_609.0, 8_388_109.0, -8_388_510.0));

    var f: f32 = -100.0;
    var i: u32 = 0;
    while (i < 100) : (i += 1) {
        const vr = km.floor(km.vectors.splat(km.vectors.F32x4, f));
        const fr = @floor(km.vectors.splat(km.vectors.F32x4, f));
        const vr8 = km.floor(km.vectors.splat(km.vectors.F32x8, f));
        const fr8 = @floor(km.vectors.splat(km.vectors.F32x8, f));
        const vr16 = km.floor(km.vectors.splat(km.vectors.F32x16, f));
        const fr16 = @floor(km.vectors.splat(km.vectors.F32x16, f));
        try km.expectVecEqual(vr, fr);
        try km.expectVecEqual(vr8, fr8);
        try km.expectVecEqual(vr16, fr16);
        f += 0.12345 * @as(f32, @floatFromInt(i));
    }
}

test "kmath.ceil" {
    {
        try std.testing.expect(km.all(km.ceil(km.vectors.splat(km.vectors.F32x4, math.inf(f32))) == km.vectors.splat(km.vectors.F32x4, math.inf(f32)), 0));
        try std.testing.expect(km.all(km.ceil(km.vectors.splat(km.vectors.F32x4, -math.inf(f32))) == km.vectors.splat(km.vectors.F32x4, -math.inf(f32)), 0));
        try std.testing.expect(km.all(km.isNan(km.ceil(km.vectors.splat(km.vectors.F32x4, math.nan(f32)))), 0));
        try std.testing.expect(km.all(km.isNan(km.ceil(km.vectors.splat(km.vectors.F32x4, -math.nan(f32)))), 0));
        try std.testing.expect(km.all(km.isNan(km.ceil(km.vectors.splat(km.vectors.F32x4, math.snan(f32)))), 0));
        try std.testing.expect(km.all(km.isNan(km.ceil(km.vectors.splat(km.vectors.F32x4, -math.snan(f32)))), 0));
    }
    {
        const v = km.ceil(km.vectors.f32x16(1.1, -1.1, -1.5, 1.5, 2.1, 2.8, 2.9, 4.1, 5.8, 6.1, 7.9, 8.9, 10.1, 11.2, 12.7, 13.1));
        try km.expectVecApproxEqAbs(
            v,
            km.vectors.f32x16(2.0, -1.0, -1.0, 2.0, 3.0, 3.0, 3.0, 5.0, 6.0, 7.0, 8.0, 9.0, 11.0, 12.0, 13.0, 14.0),
            0.0,
        );
    }
    var v = km.ceil(km.vectors.f32x4(1.5, -1.5, -1.7, -2.1));
    try km.expectVecEqual(v, km.vectors.f32x4(2.0, -1.0, -1.0, -2.0));

    v = km.ceil(km.vectors.f32x4(-10_000_002.1, -math.inf(f32), 10_000_001.5, math.inf(f32)));
    try km.expectVecEqual(v, km.vectors.f32x4(-10_000_002.1, -math.inf(f32), 10_000_001.5, math.inf(f32)));

    v = km.ceil(km.vectors.f32x4(-math.snan(f32), math.snan(f32), math.nan(f32), -math.inf(f32)));
    try std.testing.expect(math.isNan(v[0]));
    try std.testing.expect(math.isNan(v[1]));
    try std.testing.expect(math.isNan(v[2]));
    try std.testing.expect(v[3] == -math.inf(f32));

    v = km.ceil(km.vectors.f32x4(1000.5001, -201.499, -10000.99, 100.75001));
    try km.expectVecEqual(v, km.vectors.f32x4(1001.0, -201.0, -10000.0, 101.0));

    v = km.ceil(km.vectors.f32x4(-1_388_609.5, 1_388_609.1, 1_388_109.9, -1_388_509.9));
    try km.expectVecEqual(v, km.vectors.f32x4(-1_388_609.0, 1_388_610.0, 1_388_110.0, -1_388_509.0));

    var f: f32 = -100.0;
    var i: u32 = 0;
    while (i < 100) : (i += 1) {
        const vr = km.ceil(km.vectors.splat(km.vectors.F32x4, f));
        const fr = @ceil(km.vectors.splat(km.vectors.F32x4, f));
        const vr8 = km.ceil(km.vectors.splat(km.vectors.F32x8, f));
        const fr8 = @ceil(km.vectors.splat(km.vectors.F32x8, f));
        const vr16 = km.ceil(km.vectors.splat(km.vectors.F32x16, f));
        const fr16 = @ceil(km.vectors.splat(km.vectors.F32x16, f));
        try km.expectVecEqual(vr, fr);
        try km.expectVecEqual(vr8, fr8);
        try km.expectVecEqual(vr16, fr16);
        f += 0.12345 * @as(f32, @floatFromInt(i));
    }
}

test "kmath. km.clamp" {
    // Ckm.alling math.inf causes test to fail!
    if (builtin.target.os.tag == .macos and builtin.target.cpu.arch == .aarch64) return error.SkipZigTest;
    {
        const v0 = km.vectors.f32x4(-1.0, 0.2, 1.1, -0.3);
        const v = km.clamp(v0, km.vectors.splat(km.vectors.F32x4, -0.5), km.vectors.splat(km.vectors.F32x4, 0.5));
        try km.expectVecApproxEqAbs(v, km.vectors.f32x4(-0.5, 0.2, 0.5, -0.3), 0.0001);
    }
    {
        const v0 = km.vectors.f32x8(-2.0, 0.25, -0.25, 100.0, -1.0, 0.2, 1.1, -0.3);
        const v = km.clamp(v0, km.vectors.splat(km.vectors.F32x8, -0.5), km.vectors.splat(km.vectors.F32x8, 0.5));
        try km.expectVecApproxEqAbs(v, km.vectors.f32x8(-0.5, 0.25, -0.25, 0.5, -0.5, 0.2, 0.5, -0.3), 0.0001);
    }
    {
        const v0 = km.vectors.f32x4(-math.inf(f32), math.inf(f32), math.nan(f32), math.snan(f32));
        const v = km.clamp(v0, km.vectors.f32x4(-100.0, 0.0, -100.0, 0.0), km.vectors.f32x4(0.0, 100.0, 0.0, 100.0));
        try km.expectVecApproxEqAbs(v, km.vectors.f32x4(-100.0, 100.0, -100.0, 0.0), 0.0001);
    }
    {
        const v0 = km.vectors.f32x4(math.inf(f32), math.inf(f32), -math.nan(f32), -math.snan(f32));
        const v = km.clamp(v0, km.vectors.splat(km.vectors.F32x4, -1.0), km.vectors.splat(km.vectors.F32x4, 1.0));
        try km.expectVecApproxEqAbs(v, km.vectors.f32x4(1.0, 1.0, -1.0, -1.0), 0.0001);
    }
}

test "kmath. km.clampFast" {
    {
        const v0 = km.vectors.f32x4(-1.0, 0.2, 1.1, -0.3);
        const v = km.clampFast(v0, km.vectors.splat(km.vectors.F32x4, -0.5), km.vectors.splat(km.vectors.F32x4, 0.5));
        try km.expectVecApproxEqAbs(v, km.vectors.f32x4(-0.5, 0.2, 0.5, -0.3), 0.0001);
    }
}

test "kmath. km.saturate" {
    // Ckm.alling math.inf causes test to fail!
    if (builtin.target.os.tag == .macos and builtin.target.cpu.arch == .aarch64) return error.SkipZigTest;
    {
        const v0 = km.vectors.f32x4(-1.0, 0.2, 1.1, -0.3);
        const v = km.saturate(v0);
        try km.expectVecApproxEqAbs(v, km.vectors.f32x4(0.0, 0.2, 1.0, 0.0), 0.0001);
    }
    {
        const v0 = km.vectors.f32x8(0.0, 0.0, 2.0, -2.0, -1.0, 0.2, 1.1, -0.3);
        const v = km.saturate(v0);
        try km.expectVecApproxEqAbs(v, km.vectors.f32x8(0.0, 0.0, 1.0, 0.0, 0.0, 0.2, 1.0, 0.0), 0.0001);
    }
    {
        const v0 = km.vectors.f32x4(-math.inf(f32), math.inf(f32), math.nan(f32), math.snan(f32));
        const v = km.saturate(v0);
        try km.expectVecApproxEqAbs(v, km.vectors.f32x4(0.0, 1.0, 0.0, 0.0), 0.0001);
    }
    {
        const v0 = km.vectors.f32x4(math.inf(f32), math.inf(f32), -math.nan(f32), -math.snan(f32));
        const v = km.saturate(v0);
        try km.expectVecApproxEqAbs(v, km.vectors.f32x4(1.0, 1.0, 0.0, 0.0), 0.0001);
    }
}

test "kmath. km.saturateFast" {
    {
        const v0 = km.vectors.f32x4(-1.0, 0.2, 1.1, -0.3);
        const v = km.saturateFast(v0);
        try km.expectVecApproxEqAbs(v, km.vectors.f32x4(0.0, 0.2, 1.0, 0.0), 0.0001);
    }
    {
        const v0 = km.vectors.f32x8(0.0, 0.0, 2.0, -2.0, -1.0, 0.2, 1.1, -0.3);
        const v = km.saturateFast(v0);
        try km.expectVecApproxEqAbs(v, km.vectors.f32x8(0.0, 0.0, 1.0, 0.0, 0.0, 0.2, 1.0, 0.0), 0.0001);
    }
    {
        const v0 = km.vectors.f32x4(-math.inf(f32), math.inf(f32), math.nan(f32), math.snan(f32));
        const v = km.saturateFast(v0);
        try km.expectVecApproxEqAbs(v, km.vectors.f32x4(0.0, 1.0, 0.0, 0.0), 0.0001);
    }
    {
        const v0 = km.vectors.f32x4(math.inf(f32), math.inf(f32), -math.nan(f32), -math.snan(f32));
        const v = km.saturateFast(v0);
        try km.expectVecApproxEqAbs(v, km.vectors.f32x4(1.0, 1.0, 0.0, 0.0), 0.0001);
    }
}

test "kmath. km.lerpInverse" {
    try std.testing.expect(math.approxEqAbs(f32, km.lerpInverseV(10.0, 100.0, 10.0), 0, 0.0005));
    try std.testing.expect(math.approxEqAbs(f32, km.lerpInverseV(10.0, 100.0, 100.0), 1, 0.0005));
    try std.testing.expect(math.approxEqAbs(f32, km.lerpInverseV(10.0, 100.0, 55.0), 0.5, 0.05));
    try km.expectVecApproxEqAbs(km.lerpInverse(km.vectors.f32x4(0, 0, 10, 10), km.vectors.f32x4(100, 200, 100, 100), 10.0), km.vectors.f32x4(0.1, 0.05, 0, 0), 0.0005);
}

test "kmath. km.lerpOverTime" {
    try std.testing.expect(math.approxEqAbs(f32, km.lerpVOverTime(0.0, 1.0, 1.0, 1.0), 0.5, 0.0005));
    try std.testing.expect(math.approxEqAbs(f32, km.lerpVOverTime(0.5, 1.0, 1.0, 1.0), 0.75, 0.0005));
    try km.expectVecApproxEqAbs(km.lerpOverTime(km.vectors.f32x4(0, 0, 10, 10), km.vectors.f32x4(100, 200, 100, 100), 1.0, 1.0), km.vectors.f32x4(50, 100, 55, 55), 0.0005);
}

test "kmath. km.mapLinear" {
    try std.testing.expect(math.approxEqAbs(f32, km.mapLinearV(0, 0, 1.2, 10, 100), 10, 0.0005));
    try std.testing.expect(math.approxEqAbs(f32, km.mapLinearV(1.2, 0, 1.2, 10, 100), 100, 0.0005));
    try std.testing.expect(math.approxEqAbs(f32, km.mapLinearV(0.6, 0, 1.2, 10, 100), 55, 0.0005));
    try km.expectVecApproxEqAbs(km.mapLinearV(km.vectors.splat(km.vectors.F32x4, 0), km.vectors.splat(km.vectors.F32x4, 0), km.vectors.splat(km.vectors.F32x4, 1.2), km.vectors.splat(km.vectors.F32x4, 10), km.vectors.splat(km.vectors.F32x4, 100)), km.vectors.splat(km.vectors.F32x4, 10), 0.0005);
    try km.expectVecApproxEqAbs(km.mapLinear(km.vectors.f32x4(0, 0, 0.6, 1.2), 0, 1.2, 10, 100), km.vectors.f32x4(10, 10, 55, 100), 0.0005);
}

test "kmath. km.mod" {
    try km.expectVecApproxEqAbs(km.mod(km.vectors.splat(km.vectors.F32x4, 3.1), km.vectors.splat(km.vectors.F32x4, 1.7)), km.vectors.splat(km.vectors.F32x4, 1.4), 0.0005);
    try km.expectVecApproxEqAbs(km.mod(km.vectors.splat(km.vectors.F32x4, -3.0), km.vectors.splat(km.vectors.F32x4, 2.0)), km.vectors.splat(km.vectors.F32x4, -1.0), 0.0005);
    try km.expectVecApproxEqAbs(km.mod(km.vectors.splat(km.vectors.F32x4, -3.0), km.vectors.splat(km.vectors.F32x4, -2.0)), km.vectors.splat(km.vectors.F32x4, -1.0), 0.0005);
    try km.expectVecApproxEqAbs(km.mod(km.vectors.splat(km.vectors.F32x4, 3.0), km.vectors.splat(km.vectors.F32x4, -2.0)), km.vectors.splat(km.vectors.F32x4, 1.0), 0.0005);
    try std.testing.expect(km.all(km.isNan(km.mod(km.vectors.splat(km.vectors.F32x4, math.inf(f32)), km.vectors.splat(km.vectors.F32x4, 1.0))), 0));
    try std.testing.expect(km.all(km.isNan(km.mod(km.vectors.splat(km.vectors.F32x4, -math.inf(f32)), km.vectors.splat(km.vectors.F32x4, 123.456))), 0));
    try std.testing.expect(km.all(km.isNan(km.mod(km.vectors.splat(km.vectors.F32x4, math.nan(f32)), km.vectors.splat(km.vectors.F32x4, 123.456))), 0));
    try std.testing.expect(km.all(km.isNan(km.mod(km.vectors.splat(km.vectors.F32x4, math.snan(f32)), km.vectors.splat(km.vectors.F32x4, 123.456))), 0));
    try std.testing.expect(km.all(km.isNan(km.mod(km.vectors.splat(km.vectors.F32x4, -math.snan(f32)), km.vectors.splat(km.vectors.F32x4, 123.456))), 0));
    try std.testing.expect(km.all(km.isNan(km.mod(km.vectors.splat(km.vectors.F32x4, 123.456), km.vectors.splat(km.vectors.F32x4, math.inf(f32)))), 0));
    try std.testing.expect(km.all(km.isNan(km.mod(km.vectors.splat(km.vectors.F32x4, 123.456), km.vectors.splat(km.vectors.F32x4, -math.inf(f32)))), 0));
    try std.testing.expect(km.all(km.isNan(km.mod(km.vectors.splat(km.vectors.F32x4, math.inf(f32)), km.vectors.splat(km.vectors.F32x4, math.inf(f32)))), 0));
    try std.testing.expect(km.all(km.isNan(km.mod(km.vectors.splat(km.vectors.F32x4, 123.456), km.vectors.splat(km.vectors.F32x4, math.nan(f32)))), 0));
    try std.testing.expect(km.all(km.isNan(km.mod(km.vectors.splat(km.vectors.F32x4, math.inf(f32)), km.vectors.splat(km.vectors.F32x4, math.nan(f32)))), 0));
}

test "kmath. km.modAngle" {
    try km.expectVecApproxEqAbs(km.modAngle(km.vectors.splat(km.vectors.F32x4, math.tau)), km.vectors.splat(km.vectors.F32x4, 0.0), 0.0005);
    try km.expectVecApproxEqAbs(km.modAngle(km.vectors.splat(km.vectors.F32x4, 0.0)), km.vectors.splat(km.vectors.F32x4, 0.0), 0.0005);
    try km.expectVecApproxEqAbs(km.modAngle(km.vectors.splat(km.vectors.F32x4, math.pi)), km.vectors.splat(km.vectors.F32x4, math.pi), 0.0005);
    try km.expectVecApproxEqAbs(km.modAngle(km.vectors.splat(km.vectors.F32x4, 11 * math.pi)), km.vectors.splat(km.vectors.F32x4, math.pi), 0.0005);
    try km.expectVecApproxEqAbs(km.modAngle(km.vectors.splat(km.vectors.F32x4, 3.5 * math.pi)), km.vectors.splat(km.vectors.F32x4, -0.5 * math.pi), 0.0005);
    try km.expectVecApproxEqAbs(km.modAngle(km.vectors.splat(km.vectors.F32x4, 2.5 * math.pi)), km.vectors.splat(km.vectors.F32x4, 0.5 * math.pi), 0.0005);
}

test "kmath.sin" {
    const epsilon = 0.0001;

    try km.expectVecApproxEqAbs(km.sin(km.vectors.splat(km.vectors.F32x4, 0.5 * math.pi)), km.vectors.splat(km.vectors.F32x4, 1.0), epsilon);
    try km.expectVecApproxEqAbs(km.sin(km.vectors.splat(km.vectors.F32x4, 0.0)), km.vectors.splat(km.vectors.F32x4, 0.0), epsilon);
    try km.expectVecApproxEqAbs(km.sin(km.vectors.splat(km.vectors.F32x4, -0.0)), km.vectors.splat(km.vectors.F32x4, -0.0), epsilon);
    try km.expectVecApproxEqAbs(km.sin(km.vectors.splat(km.vectors.F32x4, 89.123)), km.vectors.splat(km.vectors.F32x4, 0.916166), epsilon);
    try km.expectVecApproxEqAbs(km.sin(km.vectors.splat(km.vectors.F32x8, 89.123)), km.vectors.splat(km.vectors.F32x8, 0.916166), epsilon);
    try km.expectVecApproxEqAbs(km.sin(km.vectors.splat(km.vectors.F32x16, 89.123)), km.vectors.splat(km.vectors.F32x16, 0.916166), epsilon);
    try std.testing.expect(km.all(km.isNan(km.sin(km.vectors.splat(km.vectors.F32x4, math.inf(f32)))), 0) == true);
    try std.testing.expect(km.all(km.isNan(km.sin(km.vectors.splat(km.vectors.F32x4, -math.inf(f32)))), 0) == true);
    try std.testing.expect(km.all(km.isNan(km.sin(km.vectors.splat(km.vectors.F32x4, math.nan(f32)))), 0) == true);
    try std.testing.expect(km.all(km.isNan(km.sin(km.vectors.splat(km.vectors.F32x4, math.snan(f32)))), 0) == true);

    var f: f32 = -100.0;
    var i: u32 = 0;
    while (i < 100) : (i += 1) {
        const vr = km.sin(km.vectors.splat(km.vectors.F32x4, f));
        const fr = @sin(km.vectors.splat(km.vectors.F32x4, f));
        const vr8 = km.sin(km.vectors.splat(km.vectors.F32x8, f));
        const fr8 = @sin(km.vectors.splat(km.vectors.F32x8, f));
        const vr16 = km.sin(km.vectors.splat(km.vectors.F32x16, f));
        const fr16 = @sin(km.vectors.splat(km.vectors.F32x16, f));
        try km.expectVecApproxEqAbs(vr, fr, epsilon);
        try km.expectVecApproxEqAbs(vr8, fr8, epsilon);
        try km.expectVecApproxEqAbs(vr16, fr16, epsilon);
        f += 0.12345 * @as(f32, @floatFromInt(i));
    }
}

test "kmath.cos" {
    const epsilon = 0.0001;

    try km.expectVecApproxEqAbs(km.cos(km.vectors.splat(km.vectors.F32x4, 0.5 * math.pi)), km.vectors.splat(km.vectors.F32x4, 0.0), epsilon);
    try km.expectVecApproxEqAbs(km.cos(km.vectors.splat(km.vectors.F32x4, 0.0)), km.vectors.splat(km.vectors.F32x4, 1.0), epsilon);
    try km.expectVecApproxEqAbs(km.cos(km.vectors.splat(km.vectors.F32x4, -0.0)), km.vectors.splat(km.vectors.F32x4, 1.0), epsilon);
    try std.testing.expect(km.all(km.isNan(km.cos(km.vectors.splat(km.vectors.F32x4, math.inf(f32)))), 0) == true);
    try std.testing.expect(km.all(km.isNan(km.cos(km.vectors.splat(km.vectors.F32x4, -math.inf(f32)))), 0) == true);
    try std.testing.expect(km.all(km.isNan(km.cos(km.vectors.splat(km.vectors.F32x4, math.nan(f32)))), 0) == true);
    try std.testing.expect(km.all(km.isNan(km.cos(km.vectors.splat(km.vectors.F32x4, math.snan(f32)))), 0) == true);

    var f: f32 = -100.0;
    var i: u32 = 0;
    while (i < 100) : (i += 1) {
        const vr = km.cos(km.vectors.splat(km.vectors.F32x4, f));
        const fr = @cos(km.vectors.splat(km.vectors.F32x4, f));
        const vr8 = km.cos(km.vectors.splat(km.vectors.F32x8, f));
        const fr8 = @cos(km.vectors.splat(km.vectors.F32x8, f));
        const vr16 = km.cos(km.vectors.splat(km.vectors.F32x16, f));
        const fr16 = @cos(km.vectors.splat(km.vectors.F32x16, f));
        try km.expectVecApproxEqAbs(vr, fr, epsilon);
        try km.expectVecApproxEqAbs(vr8, fr8, epsilon);
        try km.expectVecApproxEqAbs(vr16, fr16, epsilon);
        f += 0.12345 * @as(f32, @floatFromInt(i));
    }
}

test "kmath.sincos32xN" {
    const epsilon = 0.0001;

    var f: f32 = -100.0;
    var i: u32 = 0;
    while (i < 100) : (i += 1) {
        const sc = km.sincos(km.vectors.splat(km.vectors.F32x4, f));
        const sc8 = km.sincos(km.vectors.splat(km.vectors.F32x8, f));
        const sc16 = km.sincos(km.vectors.splat(km.vectors.F32x16, f));
        const s4 = @sin(km.vectors.splat(km.vectors.F32x4, f));
        const s8 = @sin(km.vectors.splat(km.vectors.F32x8, f));
        const s16 = @sin(km.vectors.splat(km.vectors.F32x16, f));
        const c4 = @cos(km.vectors.splat(km.vectors.F32x4, f));
        const c8 = @cos(km.vectors.splat(km.vectors.F32x8, f));
        const c16 = @cos(km.vectors.splat(km.vectors.F32x16, f));
        try km.expectVecApproxEqAbs(sc[0], s4, epsilon);
        try km.expectVecApproxEqAbs(sc8[0], s8, epsilon);
        try km.expectVecApproxEqAbs(sc16[0], s16, epsilon);
        try km.expectVecApproxEqAbs(sc[1], c4, epsilon);
        try km.expectVecApproxEqAbs(sc8[1], c8, epsilon);
        try km.expectVecApproxEqAbs(sc16[1], c16, epsilon);
        f += 0.12345 * @as(f32, @floatFromInt(i));
    }
}

test "kmath.atan" {
    const epsilon = 0.0001;
    {
        const v = km.vectors.f32x4(0.25, 0.5, 1.0, 1.25);
        const e = km.vectors.f32x4(math.atan(v[0]), math.atan(v[1]), math.atan(v[2]), math.atan(v[3]));
        try km.expectVecApproxEqAbs(e, km.atan(v), epsilon);
    }
    {
        const v = km.vectors.f32x8(-0.25, 0.5, -1.0, 1.25, 100.0, -200.0, 300.0, 400.0);
        // zig fmt: off
        const e = km.vectors.f32x8(
            math.atan(v[0]), math.atan(v[1]), math.atan(v[2]), math.atan(v[3]),
            math.atan(v[4]), math.atan(v[5]), math.atan(v[6]), math.atan(v[7]),
        );
        // zig fmt: on
        try km.expectVecApproxEqAbs(e, km.atan(v), epsilon);
    }
    {
        // zig fmt: off
        const v =  km.vectors.f32x16(
            -0.25, 0.5, -1.0, 0.0, 0.1, -0.2, 30.0, 400.0,
            -0.25, 0.5, -1.0, -0.0, -0.05, -0.125, 0.0625, 4000.0
        );
        const e =  km.vectors.f32x16(
            math.atan(v[0]), math.atan(v[1]), math.atan(v[2]), math.atan(v[3]),
            math.atan(v[4]), math.atan(v[5]), math.atan(v[6]), math.atan(v[7]),
            math.atan(v[8]), math.atan(v[9]), math.atan(v[10]), math.atan(v[11]),
            math.atan(v[12]), math.atan(v[13]), math.atan(v[14]), math.atan(v[15]),
        );
        // zig fmt: on
        try km.expectVecApproxEqAbs(e, km.atan(v), epsilon);
    }
    {
        try km.expectVecApproxEqAbs(km.atan(km.vectors.splat(km.vectors.F32x4, math.inf(f32))), km.vectors.splat(km.vectors.F32x4, 0.5 * math.pi), epsilon);
        try km.expectVecApproxEqAbs(km.atan(km.vectors.splat(km.vectors.F32x4, -math.inf(f32))), km.vectors.splat(km.vectors.F32x4, -0.5 * math.pi), epsilon);
        try std.testing.expect(km.all(km.isNan(km.atan(km.vectors.splat(km.vectors.F32x4, math.nan(f32)))), 0) == true);
        try std.testing.expect(km.all(km.isNan(km.atan(km.vectors.splat(km.vectors.F32x4, -math.nan(f32)))), 0) == true);
    }
}

test "kmath.atan2" {
    // From DirectXMath XMVectorATan2():
    //
    // Return the inverse tangent of Y / X in the range of -Pi to Pi with the following exceptions:

    //     Y == 0 and X is Negative         -> Pi with the sign of Y
    //     y == 0 and x is positive         -> 0 with the sign of y
    //     Y != 0 and X == 0                -> Pi / 2 with the sign of Y
    //     Y != 0 and X is Negative         -> atan(y/x) + (PI with the sign of Y)
    //     X == -Infinity and Finite Y      -> Pi with the sign of Y
    //     X == +Infinity and Finite Y      -> 0 with the sign of Y
    //     Y == Infinity and X is Finite    -> Pi / 2 with the sign of Y
    //     Y == Infinity and X == -Infinity -> 3Pi / 4 with the sign of Y
    //     Y == Infinity and X == +Infinity -> Pi / 4 with the sign of Y

    const epsilon = 0.0001;
    try km.expectVecApproxEqAbs(km.atan2(km.vectors.splat(km.vectors.F32x4, 0.0), km.vectors.splat(km.vectors.F32x4, -1.0)), km.vectors.splat(km.vectors.F32x4, math.pi), epsilon);
    try km.expectVecApproxEqAbs(km.atan2(km.vectors.splat(km.vectors.F32x4, -0.0), km.vectors.splat(km.vectors.F32x4, -1.0)), km.vectors.splat(km.vectors.F32x4, -math.pi), epsilon);
    try km.expectVecApproxEqAbs(km.atan2(km.vectors.splat(km.vectors.F32x4, 1.0), km.vectors.splat(km.vectors.F32x4, 0.0)), km.vectors.splat(km.vectors.F32x4, 0.5 * math.pi), epsilon);
    try km.expectVecApproxEqAbs(km.atan2(km.vectors.splat(km.vectors.F32x4, -1.0), km.vectors.splat(km.vectors.F32x4, 0.0)), km.vectors.splat(km.vectors.F32x4, -0.5 * math.pi), epsilon);
    try km.expectVecApproxEqAbs(
        km.atan2(km.vectors.splat(km.vectors.F32x4, 1.0), km.vectors.splat(km.vectors.F32x4, -1.0)),
        km.vectors.splat(km.vectors.F32x4, math.atan(@as(f32, -1.0)) + math.pi),
        epsilon,
    );
    try km.expectVecApproxEqAbs(
        km.atan2(km.vectors.splat(km.vectors.F32x4, -10.0), km.vectors.splat(km.vectors.F32x4, -2.0)),
        km.vectors.splat(km.vectors.F32x4, math.atan(@as(f32, 5.0)) - math.pi),
        epsilon,
    );
    try km.expectVecApproxEqAbs(km.atan2(km.vectors.splat(km.vectors.F32x4, 1.0), km.vectors.splat(km.vectors.F32x4, -math.inf(f32))), km.vectors.splat(km.vectors.F32x4, math.pi), epsilon);
    try km.expectVecApproxEqAbs(km.atan2(km.vectors.splat(km.vectors.F32x4, -1.0), km.vectors.splat(km.vectors.F32x4, -math.inf(f32))), km.vectors.splat(km.vectors.F32x4, -math.pi), epsilon);
    try km.expectVecApproxEqAbs(km.atan2(km.vectors.splat(km.vectors.F32x4, 1.0), km.vectors.splat(km.vectors.F32x4, math.inf(f32))), km.vectors.splat(km.vectors.F32x4, 0.0), epsilon);
    try km.expectVecApproxEqAbs(km.atan2(km.vectors.splat(km.vectors.F32x4, -1.0), km.vectors.splat(km.vectors.F32x4, math.inf(f32))), km.vectors.splat(km.vectors.F32x4, -0.0), epsilon);
    try km.expectVecApproxEqAbs(
        km.atan2(km.vectors.splat(km.vectors.F32x4, math.inf(f32)), km.vectors.splat(km.vectors.F32x4, 2.0)),
        km.vectors.splat(km.vectors.F32x4, 0.5 * math.pi),
        epsilon,
    );
    try km.expectVecApproxEqAbs(
        km.atan2(km.vectors.splat(km.vectors.F32x4, -math.inf(f32)), km.vectors.splat(km.vectors.F32x4, 2.0)),
        km.vectors.splat(km.vectors.F32x4, -0.5 * math.pi),
        epsilon,
    );
    try km.expectVecApproxEqAbs(
        km.atan2(km.vectors.splat(km.vectors.F32x4, math.inf(f32)), km.vectors.splat(km.vectors.F32x4, -math.inf(f32))),
        km.vectors.splat(km.vectors.F32x4, 0.75 * math.pi),
        epsilon,
    );
    try km.expectVecApproxEqAbs(
        km.atan2(km.vectors.splat(km.vectors.F32x4, -math.inf(f32)), km.vectors.splat(km.vectors.F32x4, -math.inf(f32))),
        km.vectors.splat(km.vectors.F32x4, -0.75 * math.pi),
        epsilon,
    );
    try km.expectVecApproxEqAbs(
        km.atan2(km.vectors.splat(km.vectors.F32x4, math.inf(f32)), km.vectors.splat(km.vectors.F32x4, math.inf(f32))),
        km.vectors.splat(km.vectors.F32x4, 0.25 * math.pi),
        epsilon,
    );
    try km.expectVecApproxEqAbs(
        km.atan2(km.vectors.splat(km.vectors.F32x4, -math.inf(f32)), km.vectors.splat(km.vectors.F32x4, math.inf(f32))),
        km.vectors.splat(km.vectors.F32x4, -0.25 * math.pi),
        epsilon,
    );
    try km.expectVecApproxEqAbs(
        km.atan2(
            km.vectors.f32x8(0.0, -math.inf(f32), -0.0, 2.0, math.inf(f32), math.inf(f32), 1.0, -math.inf(f32)),
            km.vectors.f32x8(-2.0, math.inf(f32), 1.0, 0.0, 10.0, -math.inf(f32), 1.0, -math.inf(f32)),
        ),
        km.vectors.f32x8(
            math.pi,
            -0.25 * math.pi,
            -0.0,
            0.5 * math.pi,
            0.5 * math.pi,
            0.75 * math.pi,
            math.atan(@as(f32, 1.0)),
            -0.75 * math.pi,
        ),
        epsilon,
    );
    try km.expectVecApproxEqAbs(km.atan2(km.vectors.splat(km.vectors.F32x4, 0.0), km.vectors.splat(km.vectors.F32x4, 0.0)), km.vectors.splat(km.vectors.F32x4, 0.0), epsilon);
    try km.expectVecApproxEqAbs(km.atan2(km.vectors.splat(km.vectors.F32x4, -0.0), km.vectors.splat(km.vectors.F32x4, 0.0)), km.vectors.splat(km.vectors.F32x4, 0.0), epsilon);
    try std.testing.expect(km.all(km.isNan(km.atan2(km.vectors.splat(km.vectors.F32x4, 1.0), km.vectors.splat(km.vectors.F32x4, math.nan(f32)))), 0) == true);
    try std.testing.expect(km.all(km.isNan(km.atan2(km.vectors.splat(km.vectors.F32x4, -1.0), km.vectors.splat(km.vectors.F32x4, math.nan(f32)))), 0) == true);
    try std.testing.expect(km.all(km.isNan(km.atan2(km.vectors.splat(km.vectors.F32x4, math.nan(f32)), km.vectors.splat(km.vectors.F32x4, -1.0))), 0) == true);
    try std.testing.expect(km.all(km.isNan(km.atan2(km.vectors.splat(km.vectors.F32x4, -math.nan(f32)), km.vectors.splat(km.vectors.F32x4, 1.0))), 0) == true);
}

test "kmath.dot2" {
    const v0 = km.vectors.f32x4(-1.0, 2.0, 300.0, -2.0);
    const v1 = km.vectors.f32x4(4.0, 5.0, 600.0, 2.0);
    const v = km.dot2(v0, v1);
    try km.expectVecApproxEqAbs(v, km.vectors.splat(km.vectors.F32x4, 6.0), 0.0001);
}

test "kmath.dot3" {
    const v0 = km.vectors.f32x4(-1.0, 2.0, 3.0, 1.0);
    const v1 = km.vectors.f32x4(4.0, 5.0, 6.0, 1.0);
    const v = km.dot3(v0, v1);
    try km.expectVecApproxEqAbs(v, km.vectors.splat(km.vectors.F32x4, 24.0), 0.0001);
}

test "kmath.dot4" {
    const v0 = km.vectors.f32x4(-1.0, 2.0, 3.0, -2.0);
    const v1 = km.vectors.f32x4(4.0, 5.0, 6.0, 2.0);
    const v = km.dot4(v0, v1);
    try km.expectVecApproxEqAbs(v, km.vectors.splat(km.vectors.F32x4, 20.0), 0.0001);
}

test "kmath.cross3" {
    {
        const v0 = km.vectors.f32x4(1.0, 0.0, 0.0, 1.0);
        const v1 = km.vectors.f32x4(0.0, 1.0, 0.0, 1.0);
        const v = km.cross3(v0, v1);
        try km.expectVecApproxEqAbs(v, km.vectors.f32x4(0.0, 0.0, 1.0, 0.0), 0.0001);
    }
    {
        const v0 = km.vectors.f32x4(1.0, 0.0, 0.0, 1.0);
        const v1 = km.vectors.f32x4(0.0, -1.0, 0.0, 1.0);
        const v = km.cross3(v0, v1);
        try km.expectVecApproxEqAbs(v, km.vectors.f32x4(0.0, 0.0, -1.0, 0.0), 0.0001);
    }
    {
        const v0 = km.vectors.f32x4(-3.0, 0, -2.0, 1.0);
        const v1 = km.vectors.f32x4(5.0, -1.0, 2.0, 1.0);
        const v = km.cross3(v0, v1);
        try km.expectVecApproxEqAbs(v, km.vectors.f32x4(-2.0, -4.0, 3.0, 0.0), 0.0001);
    }
}

test "kmath.length3" {
    {
        const v = km.length3(km.vectors.f32x4(1.0, -2.0, 3.0, 1000.0));
        try km.expectVecApproxEqAbs(v, km.vectors.splat(km.vectors.F32x4, math.sqrt(14.0)), 0.001);
    }
    {
        const v = km.length3(km.vectors.f32x4(1.0, math.nan(f32), math.nan(f32), 1000.0));
        try std.testing.expect(km.all(km.isNan(v), 0));
    }
    {
        const v = km.length3(km.vectors.f32x4(1.0, math.inf(f32), 3.0, 1000.0));
        try std.testing.expect(km.all(km.isInf(v), 0));
    }
    {
        const v = km.length3(km.vectors.f32x4(3.0, 2.0, 1.0, math.nan(f32)));
        try km.expectVecApproxEqAbs(v, km.vectors.splat(km.vectors.F32x4, math.sqrt(14.0)), 0.001);
    }
}

test "kmath.normalize3" {
    {
        const v0 = km.vectors.f32x4(1.0, -2.0, 3.0, 1000.0);
        const v = km.normalize3(v0);
        try km.expectVecApproxEqAbs(v, v0 * km.vectors.splat(km.vectors.F32x4, 1.0 / math.sqrt(14.0)), 0.0005);
    }
    {
        try std.testing.expect(km.any(km.isNan(km.normalize3(km.vectors.f32x4(1.0, math.inf(f32), 1.0, 1.0))), 0));
        try std.testing.expect(km.any(km.isNan(km.normalize3(km.vectors.f32x4(-math.inf(f32), math.inf(f32), 0.0, 0.0))), 0));
        try std.testing.expect(km.any(km.isNan(km.normalize3(km.vectors.f32x4(-math.nan(f32), math.snan(f32), 0.0, 0.0))), 0));
        try std.testing.expect(km.any(km.isNan(km.normalize3(km.vectors.f32x4(0, 0, 0, 0))), 0));
    }
}

test "kmath.normalize4" {
    {
        const v0 = km.vectors.f32x4(1.0, -2.0, 3.0, 10.0);
        const v = km.normalize4(v0);
        try km.expectVecApproxEqAbs(v, v0 * km.vectors.splat(km.vectors.F32x4, 1.0 / math.sqrt(114.0)), 0.0005);
    }
    {
        try std.testing.expect(km.any(km.isNan(km.normalize4(km.vectors.f32x4(1.0, math.inf(f32), 1.0, 1.0))), 0));
        try std.testing.expect(km.any(km.isNan(km.normalize4(km.vectors.f32x4(-math.inf(f32), math.inf(f32), 0.0, 0.0))), 0));
        try std.testing.expect(km.any(km.isNan(km.normalize4(km.vectors.f32x4(-math.nan(f32), math.snan(f32), 0.0, 0.0))), 0));
        try std.testing.expect(km.any(km.isNan(km.normalize4(km.vectors.f32x4(0, 0, 0, 0))), 0));
    }
}

test "kmath.vecMulMat" {
    const m = km.Mat{
        km.vectors.f32x4(1.0, 0.0, 0.0, 0.0),
        km.vectors.f32x4(0.0, 1.0, 0.0, 0.0),
        km.vectors.f32x4(0.0, 0.0, 1.0, 0.0),
        km.vectors.f32x4(2.0, 3.0, 4.0, 1.0),
    };
    const vm = km.mul(km.vectors.f32x4(1.0, 2.0, 3.0, 1.0), m);
    const mv = km.mul(m, km.vectors.f32x4(1.0, 2.0, 3.0, 1.0));
    const v = km.mul(km.transpose(m), km.vectors.f32x4(1.0, 2.0, 3.0, 1.0));
    try km.expectVecApproxEqAbs(vm, km.vectors.f32x4(3.0, 5.0, 7.0, 1.0), 0.0001);
    try km.expectVecApproxEqAbs(mv, km.vectors.f32x4(1.0, 2.0, 3.0, 21.0), 0.0001);
    try km.expectVecApproxEqAbs(v, km.vectors.f32x4(3.0, 5.0, 7.0, 1.0), 0.0001);
}

test "kmath.mul" {
    {
        const m = km.Mat{
            km.vectors.f32x4(0.1, 0.2, 0.3, 0.4),
            km.vectors.f32x4(0.5, 0.6, 0.7, 0.8),
            km.vectors.f32x4(0.9, 1.0, 1.1, 1.2),
            km.vectors.f32x4(1.3, 1.4, 1.5, 1.6),
        };
        const ms = km.mul(@as(f32, 2.0), m);
        try km.expectVecApproxEqAbs(ms[0], km.vectors.f32x4(0.2, 0.4, 0.6, 0.8), 0.0001);
        try km.expectVecApproxEqAbs(ms[1], km.vectors.f32x4(1.0, 1.2, 1.4, 1.6), 0.0001);
        try km.expectVecApproxEqAbs(ms[2], km.vectors.f32x4(1.8, 2.0, 2.2, 2.4), 0.0001);
        try km.expectVecApproxEqAbs(ms[3], km.vectors.f32x4(2.6, 2.8, 3.0, 3.2), 0.0001);
    }
}

test "kmath.matrix.mul" {
    const a = km.Mat{
        km.vectors.f32x4(0.1, 0.2, 0.3, 0.4),
        km.vectors.f32x4(0.5, 0.6, 0.7, 0.8),
        km.vectors.f32x4(0.9, 1.0, 1.1, 1.2),
        km.vectors.f32x4(1.3, 1.4, 1.5, 1.6),
    };
    const b = km.Mat{
        km.vectors.f32x4(1.7, 1.8, 1.9, 2.0),
        km.vectors.f32x4(2.1, 2.2, 2.3, 2.4),
        km.vectors.f32x4(2.5, 2.6, 2.7, 2.8),
        km.vectors.f32x4(2.9, 3.0, 3.1, 3.2),
    };
    const c = km.mul(a, b);
    try km.expectVecApproxEqAbs(c[0], km.vectors.f32x4(2.5, 2.6, 2.7, 2.8), 0.0001);
    try km.expectVecApproxEqAbs(c[1], km.vectors.f32x4(6.18, 6.44, 6.7, 6.96), 0.0001);
    try km.expectVecApproxEqAbs(c[2], km.vectors.f32x4(9.86, 10.28, 10.7, 11.12), 0.0001);
    try km.expectVecApproxEqAbs(c[3], km.vectors.f32x4(13.54, 14.12, 14.7, 15.28), 0.0001);
}

test "kmath.matrix.transpose" {
    const m = km.Mat{
        km.vectors.f32x4(1.0, 2.0, 3.0, 4.0),
        km.vectors.f32x4(5.0, 6.0, 7.0, 8.0),
        km.vectors.f32x4(9.0, 10.0, 11.0, 12.0),
        km.vectors.f32x4(13.0, 14.0, 15.0, 16.0),
    };
    const mt = km.transpose(m);
    try km.expectVecApproxEqAbs(mt[0], km.vectors.f32x4(1.0, 5.0, 9.0, 13.0), 0.0001);
    try km.expectVecApproxEqAbs(mt[1], km.vectors.f32x4(2.0, 6.0, 10.0, 14.0), 0.0001);
    try km.expectVecApproxEqAbs(mt[2], km.vectors.f32x4(3.0, 7.0, 11.0, 15.0), 0.0001);
    try km.expectVecApproxEqAbs(mt[3], km.vectors.f32x4(4.0, 8.0, 12.0, 16.0), 0.0001);
}

test "kmath.matrix.determinant" {
    const m = km.Mat{
        km.vectors.f32x4(10.0, -9.0, -12.0, 1.0),
        km.vectors.f32x4(7.0, -12.0, 11.0, 1.0),
        km.vectors.f32x4(-10.0, 10.0, 3.0, 1.0),
        km.vectors.f32x4(1.0, 2.0, 3.0, 4.0),
    };
    try km.expectVecApproxEqAbs(km.determinant(m), km.vectors.splat(km.vectors.F32x4, 2939.0), 0.0001);
}

test "kmath.matrix.inverse" {
    const m = km.Mat{
        km.vectors.f32x4(10.0, -9.0, -12.0, 1.0),
        km.vectors.f32x4(7.0, -12.0, 11.0, 1.0),
        km.vectors.f32x4(-10.0, 10.0, 3.0, 1.0),
        km.vectors.f32x4(1.0, 2.0, 3.0, 4.0),
    };
    var det: km.vectors.F32x4 = undefined;
    const mi = km.inverseDet(m, &det);
    try km.expectVecApproxEqAbs(det, km.vectors.splat(km.vectors.F32x4, 2939.0), 0.0001);

    try km.expectVecApproxEqAbs(mi[0], km.vectors.f32x4(-0.170806, -0.13576, -0.349439, 0.164001), 0.0001);
    try km.expectVecApproxEqAbs(mi[1], km.vectors.f32x4(-0.163661, -0.14801, -0.253147, 0.141204), 0.0001);
    try km.expectVecApproxEqAbs(mi[2], km.vectors.f32x4(-0.0871045, 0.00646478, -0.0785982, 0.0398095), 0.0001);
    try km.expectVecApproxEqAbs(mi[3], km.vectors.f32x4(0.18986, 0.103096, 0.272882, 0.10854), 0.0001);
}

test "kmath.matrix.matFromAxisAngle" {
    {
        const m0 = km.matFromAxisAngle(km.vectors.f32x4(1.0, 0.0, 0.0, 0.0), math.pi * 0.25);
        const m1 = km.rotationX(math.pi * 0.25);
        try km.expectVecApproxEqAbs(m0[0], m1[0], 0.001);
        try km.expectVecApproxEqAbs(m0[1], m1[1], 0.001);
        try km.expectVecApproxEqAbs(m0[2], m1[2], 0.001);
        try km.expectVecApproxEqAbs(m0[3], m1[3], 0.001);
    }
    {
        const m0 = km.matFromAxisAngle(km.vectors.f32x4(0.0, 1.0, 0.0, 0.0), math.pi * 0.125);
        const m1 = km.rotationY(math.pi * 0.125);
        try km.expectVecApproxEqAbs(m0[0], m1[0], 0.001);
        try km.expectVecApproxEqAbs(m0[1], m1[1], 0.001);
        try km.expectVecApproxEqAbs(m0[2], m1[2], 0.001);
        try km.expectVecApproxEqAbs(m0[3], m1[3], 0.001);
    }
    {
        const m0 = km.matFromAxisAngle(km.vectors.f32x4(0.0, 0.0, 1.0, 0.0), math.pi * 0.333);
        const m1 = km.rotationZ(math.pi * 0.333);
        try km.expectVecApproxEqAbs(m0[0], m1[0], 0.001);
        try km.expectVecApproxEqAbs(m0[1], m1[1], 0.001);
        try km.expectVecApproxEqAbs(m0[2], m1[2], 0.001);
        try km.expectVecApproxEqAbs(m0[3], m1[3], 0.001);
    }
}

test "kmath.matrix. km.matFromQuat" {
    {
        const m = km.matFromQuat(km.vectors.f32x4(0.0, 0.0, 0.0, 1.0));
        try km.expectVecApproxEqAbs(m[0], km.vectors.f32x4(1.0, 0.0, 0.0, 0.0), 0.0001);
        try km.expectVecApproxEqAbs(m[1], km.vectors.f32x4(0.0, 1.0, 0.0, 0.0), 0.0001);
        try km.expectVecApproxEqAbs(m[2], km.vectors.f32x4(0.0, 0.0, 1.0, 0.0), 0.0001);
        try km.expectVecApproxEqAbs(m[3], km.vectors.f32x4(0.0, 0.0, 0.0, 1.0), 0.0001);
    }
}

test "kmath.loadMat" {
    const a = [18]f32{
        1.0,  2.0,  3.0,  4.0,
        5.0,  6.0,  7.0,  8.0,
        9.0,  10.0, 11.0, 12.0,
        13.0, 14.0, 15.0, 16.0,
        17.0, 18.0,
    };
    const m = km.loadMat(a[1..]);
    try km.expectVecEqual(m[0], km.vectors.f32x4(2.0, 3.0, 4.0, 5.0));
    try km.expectVecEqual(m[1], km.vectors.f32x4(6.0, 7.0, 8.0, 9.0));
    try km.expectVecEqual(m[2], km.vectors.f32x4(10.0, 11.0, 12.0, 13.0));
    try km.expectVecEqual(m[3], km.vectors.f32x4(14.0, 15.0, 16.0, 17.0));
}

test "kmath.quaternion.mul" {
    {
        const q0 = km.vectors.f32x4(2.0, 3.0, 4.0, 1.0);
        const q1 = km.vectors.f32x4(3.0, 2.0, 1.0, 4.0);
        try km.expectVecApproxEqAbs(km.qmul(q0, q1), km.vectors.f32x4(16.0, 4.0, 22.0, -12.0), 0.0001);
    }
}

test "kmath.quaternion.quatToAxisAngle" {
    {
        const q0 = km.quatFromNormAxisAngle(km.vectors.f32x4(1.0, 0.0, 0.0, 0.0), 0.25 * math.pi);
        var axis: km.vectors.Vec = km.vectors.f32x4(4.0, 3.0, 2.0, 1.0);
        var angle: f32 = 10.0;
        km.quatToAxisAngle(q0, &axis, &angle);
        try std.testing.expect(math.approxEqAbs(f32, axis[0], @sin(@as(f32, 0.25) * math.pi * 0.5), 0.0001));
        try std.testing.expect(axis[1] == 0.0);
        try std.testing.expect(axis[2] == 0.0);
        try std.testing.expect(math.approxEqAbs(f32, angle, 0.25 * math.pi, 0.0001));
    }
}

test "kmath.quatFromMat" {
    {
        const q0 = km.quatFromAxisAngle(km.vectors.f32x4(1.0, 0.0, 0.0, 0.0), 0.25 * math.pi);
        const q1 = km.quatFromMat(km.rotationX(0.25 * math.pi));
        try km.expectVecApproxEqAbs(q0, q1, 0.0001);
    }
    {
        const q0 = km.quatFromAxisAngle(km.vectors.f32x4(1.0, 2.0, 0.5, 0.0), 0.25 * math.pi);
        const q1 = km.quatFromMat(km.matFromAxisAngle(km.vectors.f32x4(1.0, 2.0, 0.5, 0.0), 0.25 * math.pi));
        try km.expectVecApproxEqAbs(q0, q1, 0.0001);
    }
    {
        const q0 = km.quatFromRollPitchYaw(0.1 * math.pi, -0.2 * math.pi, 0.3 * math.pi);
        const q1 = km.quatFromMat(km.matFromRollPitchYaw(0.1 * math.pi, -0.2 * math.pi, 0.3 * math.pi));
        try km.expectVecApproxEqAbs(q0, q1, 0.0001);
    }
}

test "kmath.quaternion.quatFromNormAxisAngle" {
    {
        const q0 = km.quatFromAxisAngle(km.vectors.f32x4(1.0, 0.0, 0.0, 0.0), 0.25 * math.pi);
        const q1 = km.quatFromAxisAngle(km.vectors.f32x4(0.0, 1.0, 0.0, 0.0), 0.125 * math.pi);
        const m0 = km.rotationX(0.25 * math.pi);
        const m1 = km.rotationY(0.125 * math.pi);
        const mr0 = km.quatToMat(km.qmul(q0, q1));
        const mr1 = km.mul(m0, m1);
        try km.expectVecApproxEqAbs(mr0[0], mr1[0], 0.0001);
        try km.expectVecApproxEqAbs(mr0[1], mr1[1], 0.0001);
        try km.expectVecApproxEqAbs(mr0[2], mr1[2], 0.0001);
        try km.expectVecApproxEqAbs(mr0[3], mr1[3], 0.0001);
    }
    {
        const m0 = km.quatToMat(km.quatFromAxisAngle(km.vectors.f32x4(1.0, 2.0, 0.5, 0.0), 0.25 * math.pi));
        const m1 = km.matFromAxisAngle(km.vectors.f32x4(1.0, 2.0, 0.5, 0.0), 0.25 * math.pi);
        try km.expectVecApproxEqAbs(m0[0], m1[0], 0.0001);
        try km.expectVecApproxEqAbs(m0[1], m1[1], 0.0001);
        try km.expectVecApproxEqAbs(m0[2], m1[2], 0.0001);
        try km.expectVecApproxEqAbs(m0[3], m1[3], 0.0001);
    }
}

test "kmath.quaternion.inverseQuat" {
    try km.expectVecApproxEqAbs(
        km.inverse(km.vectors.f32x4(2.0, 3.0, 4.0, 1.0)),
        km.vectors.f32x4(-1.0 / 15.0, -1.0 / 10.0, -2.0 / 15.0, 1.0 / 30.0),
        0.0001,
    );
    try km.expectVecApproxEqAbs(km.inverse(km.qidentity()), km.qidentity(), 0.0001);
}

test "kmath.quaternion. km.rotate" {
    const quat = km.quatFromRollPitchYaw(0.1 * math.pi, 0.2 * math.pi, 0.3 * math.pi);
    const mat = km.matFromQuat(quat);
    const forward = km.vectors.f32x4(0.0, 0.0, -1.0, 0.0);
    const up = km.vectors.f32x4(0.0, 1.0, 0.0, 0.0);
    const right = km.vectors.f32x4(1.0, 0.0, 0.0, 0.0);
    try km.expectVecApproxEqAbs(km.rotate(quat, forward), km.mul(forward, mat), 0.0001);
    try km.expectVecApproxEqAbs(km.rotate(quat, up), km.mul(up, mat), 0.0001);
    try km.expectVecApproxEqAbs(km.rotate(quat, right), km.mul(right, mat), 0.0001);
}

test "kmath.quaternion. km.quatToRollPitchYaw" {
    {
        const expected = km.vectors.f32x4(0.1 * math.pi, 0.2 * math.pi, 0.3 * math.pi, 0.0);
        const quat = km.quatFromRollPitchYaw(expected[0], expected[1], expected[2]);
        const result = km.quatToRollPitchYaw(quat);
        try km.expectVecApproxEqAbs(km.vectors.loadArr3(result), expected, 0.0001);
    }

    {
        const expected = km.vectors.f32x4(0.3 * math.pi, 0.1 * math.pi, 0.2 * math.pi, 0.0);
        const quat = km.quatFromRollPitchYaw(expected[0], expected[1], expected[2]);
        const result = km.quatToRollPitchYaw(quat);
        try km.expectVecApproxEqAbs(km.vectors.loadArr3(result), expected, 0.0001);
    }

    // North pole singularity
    {
        const angle = km.vectors.f32x4(0.5 * math.pi, 0.2 * math.pi, 0.3 * math.pi, 0.0);
        const expected = km.vectors.f32x4(0.5 * math.pi, -0.1 * math.pi, 0.0, 0.0);
        const quat = km.quatFromRollPitchYaw(angle[0], angle[1], angle[2]);
        const result = km.quatToRollPitchYaw(quat);
        try km.expectVecApproxEqAbs(km.vectors.loadArr3(result), expected, 0.0001);
    }

    // South pole singularity
    {
        const angle = km.vectors.f32x4(-0.5 * math.pi, 0.2 * math.pi, 0.3 * math.pi, 0.0);
        const expected = km.vectors.f32x4(-0.5 * math.pi, 0.5 * math.pi, 0.0, 0.0);
        const quat = km.quatFromRollPitchYaw(angle[0], angle[1], angle[2]);
        const result = km.quatToRollPitchYaw(quat);
        try km.expectVecApproxEqAbs(km.vectors.loadArr3(result), expected, 0.0001);
    }
}

test "kmath.quaternion. km.quatFromRollPitchYawV" {
    {
        const m0 = km.quatToMat(km.quatFromRollPitchYawV(km.vectors.f32x4(0.25 * math.pi, 0.0, 0.0, 0.0)));
        const m1 = km.rotationX(0.25 * math.pi);
        try km.expectVecApproxEqAbs(m0[0], m1[0], 0.0001);
        try km.expectVecApproxEqAbs(m0[1], m1[1], 0.0001);
        try km.expectVecApproxEqAbs(m0[2], m1[2], 0.0001);
        try km.expectVecApproxEqAbs(m0[3], m1[3], 0.0001);
    }
    {
        const m0 = km.quatToMat(km.quatFromRollPitchYaw(0.1 * math.pi, 0.2 * math.pi, 0.3 * math.pi));
        const m1 = km.mul(
            km.rotationZ(0.3 * math.pi),
            km.mul(km.rotationX(0.1 * math.pi), km.rotationY(0.2 * math.pi)),
        );
        try km.expectVecApproxEqAbs(m0[0], m1[0], 0.0001);
        try km.expectVecApproxEqAbs(m0[1], m1[1], 0.0001);
        try km.expectVecApproxEqAbs(m0[2], m1[2], 0.0001);
        try km.expectVecApproxEqAbs(m0[3], m1[3], 0.0001);
    }
}

test "kmath.color.  km.rgbToHsl" {
    try km.expectVecApproxEqAbs(km.rgbToHsl(km.vectors.f32x4(0.2, 0.4, 0.8, 1.0)), km.vectors.f32x4(0.6111, 0.6, 0.5, 1.0), 0.0001);
    try km.expectVecApproxEqAbs(km.rgbToHsl(km.vectors.f32x4(1.0, 0.0, 0.0, 0.5)), km.vectors.f32x4(0.0, 1.0, 0.5, 0.5), 0.0001);
    try km.expectVecApproxEqAbs(km.rgbToHsl(km.vectors.f32x4(0.0, 1.0, 0.0, 0.25)), km.vectors.f32x4(0.3333, 1.0, 0.5, 0.25), 0.0001);
    try km.expectVecApproxEqAbs(km.rgbToHsl(km.vectors.f32x4(0.0, 0.0, 1.0, 1.0)), km.vectors.f32x4(0.6666, 1.0, 0.5, 1.0), 0.0001);
    try km.expectVecApproxEqAbs(km.rgbToHsl(km.vectors.f32x4(0.0, 0.0, 0.0, 1.0)), km.vectors.f32x4(0.0, 0.0, 0.0, 1.0), 0.0001);
    try km.expectVecApproxEqAbs(km.rgbToHsl(km.vectors.f32x4(1.0, 1.0, 1.0, 1.0)), km.vectors.f32x4(0.0, 0.0, 1.0, 1.0), 0.0001);
}

test "kmath.color.  km.hslToRgb" {
    try km.expectVecApproxEqAbs(km.vectors.f32x4(0.2, 0.4, 0.8, 1.0), km.hslToRgb(km.vectors.f32x4(0.6111, 0.6, 0.5, 1.0)), 0.0001);
    try km.expectVecApproxEqAbs(km.vectors.f32x4(1.0, 0.0, 0.0, 0.5), km.hslToRgb(km.vectors.f32x4(0.0, 1.0, 0.5, 0.5)), 0.0001);
    try km.expectVecApproxEqAbs(km.vectors.f32x4(0.0, 1.0, 0.0, 0.25), km.hslToRgb(km.vectors.f32x4(0.3333, 1.0, 0.5, 0.25)), 0.0005);
    try km.expectVecApproxEqAbs(km.vectors.f32x4(0.0, 0.0, 1.0, 1.0), km.hslToRgb(km.vectors.f32x4(0.6666, 1.0, 0.5, 1.0)), 0.0005);
    try km.expectVecApproxEqAbs(km.vectors.f32x4(0.0, 0.0, 0.0, 1.0), km.hslToRgb(km.vectors.f32x4(0.0, 0.0, 0.0, 1.0)), 0.0001);
    try km.expectVecApproxEqAbs(km.vectors.f32x4(1.0, 1.0, 1.0, 1.0), km.hslToRgb(km.vectors.f32x4(0.0, 0.0, 1.0, 1.0)), 0.0001);
    try km.expectVecApproxEqAbs(km.hslToRgb(km.rgbToHsl(km.vectors.f32x4(1.0, 1.0, 1.0, 1.0))), km.vectors.f32x4(1.0, 1.0, 1.0, 1.0), 0.0005);
    try km.expectVecApproxEqAbs(
        km.hslToRgb(km.rgbToHsl(km.vectors.f32x4(0.82198, 0.1839, 0.632, 1.0))),
        km.vectors.f32x4(0.82198, 0.1839, 0.632, 1.0),
        0.0005,
    );
    try km.expectVecApproxEqAbs(
        km.rgbToHsl(km.hslToRgb(km.vectors.f32x4(0.82198, 0.1839, 0.632, 1.0))),
        km.vectors.f32x4(0.82198, 0.1839, 0.632, 1.0),
        0.0005,
    );
    try km.expectVecApproxEqAbs(
        km.rgbToHsl(km.hslToRgb(km.vectors.f32x4(0.1839, 0.82198, 0.632, 1.0))),
        km.vectors.f32x4(0.1839, 0.82198, 0.632, 1.0),
        0.0005,
    );
    try km.expectVecApproxEqAbs(
        km.hslToRgb(km.rgbToHsl(km.vectors.f32x4(0.1839, 0.632, 0.82198, 1.0))),
        km.vectors.f32x4(0.1839, 0.632, 0.82198, 1.0),
        0.0005,
    );
}

test "kmath.color.  km.rgbToHsv" {
    try km.expectVecApproxEqAbs(km.rgbToHsv(km.vectors.f32x4(0.2, 0.4, 0.8, 1.0)), km.vectors.f32x4(0.6111, 0.75, 0.8, 1.0), 0.0001);
    try km.expectVecApproxEqAbs(km.rgbToHsv(km.vectors.f32x4(0.4, 0.2, 0.8, 1.0)), km.vectors.f32x4(0.7222, 0.75, 0.8, 1.0), 0.0001);
    try km.expectVecApproxEqAbs(km.rgbToHsv(km.vectors.f32x4(0.4, 0.8, 0.2, 1.0)), km.vectors.f32x4(0.2777, 0.75, 0.8, 1.0), 0.0001);
    try km.expectVecApproxEqAbs(km.rgbToHsv(km.vectors.f32x4(1.0, 0.0, 0.0, 0.5)), km.vectors.f32x4(0.0, 1.0, 1.0, 0.5), 0.0001);
    try km.expectVecApproxEqAbs(km.rgbToHsv(km.vectors.f32x4(0.0, 1.0, 0.0, 0.25)), km.vectors.f32x4(0.3333, 1.0, 1.0, 0.25), 0.0001);
    try km.expectVecApproxEqAbs(km.rgbToHsv(km.vectors.f32x4(0.0, 0.0, 1.0, 1.0)), km.vectors.f32x4(0.6666, 1.0, 1.0, 1.0), 0.0001);
    try km.expectVecApproxEqAbs(km.rgbToHsv(km.vectors.f32x4(0.0, 0.0, 0.0, 1.0)), km.vectors.f32x4(0.0, 0.0, 0.0, 1.0), 0.0001);
    try km.expectVecApproxEqAbs(km.rgbToHsv(km.vectors.f32x4(1.0, 1.0, 1.0, 1.0)), km.vectors.f32x4(0.0, 0.0, 1.0, 1.0), 0.0001);
}

test "kmath.color.  km.hsvToRgb" {
    const epsilon = 0.0005;
    try km.expectVecApproxEqAbs(km.vectors.f32x4(0.2, 0.4, 0.8, 1.0), km.hsvToRgb(km.vectors.f32x4(0.6111, 0.75, 0.8, 1.0)), epsilon);
    try km.expectVecApproxEqAbs(km.vectors.f32x4(0.4, 0.2, 0.8, 1.0), km.hsvToRgb(km.vectors.f32x4(0.7222, 0.75, 0.8, 1.0)), epsilon);
    try km.expectVecApproxEqAbs(km.vectors.f32x4(0.4, 0.8, 0.2, 1.0), km.hsvToRgb(km.vectors.f32x4(0.2777, 0.75, 0.8, 1.0)), epsilon);
    try km.expectVecApproxEqAbs(km.vectors.f32x4(1.0, 0.0, 0.0, 0.5), km.hsvToRgb(km.vectors.f32x4(0.0, 1.0, 1.0, 0.5)), epsilon);
    try km.expectVecApproxEqAbs(km.vectors.f32x4(0.0, 1.0, 0.0, 0.25), km.hsvToRgb(km.vectors.f32x4(0.3333, 1.0, 1.0, 0.25)), epsilon);
    try km.expectVecApproxEqAbs(km.vectors.f32x4(0.0, 0.0, 1.0, 1.0), km.hsvToRgb(km.vectors.f32x4(0.6666, 1.0, 1.0, 1.0)), epsilon);
    try km.expectVecApproxEqAbs(km.vectors.f32x4(0.0, 0.0, 0.0, 1.0), km.hsvToRgb(km.vectors.f32x4(0.0, 0.0, 0.0, 1.0)), epsilon);
    try km.expectVecApproxEqAbs(km.vectors.f32x4(1.0, 1.0, 1.0, 1.0), km.hsvToRgb(km.vectors.f32x4(0.0, 0.0, 1.0, 1.0)), epsilon);
    try km.expectVecApproxEqAbs(
        km.hsvToRgb(km.rgbToHsv(km.vectors.f32x4(0.1839, 0.632, 0.82198, 1.0))),
        km.vectors.f32x4(0.1839, 0.632, 0.82198, 1.0),
        epsilon,
    );
    try km.expectVecApproxEqAbs(
        km.hsvToRgb(km.rgbToHsv(km.vectors.f32x4(0.82198, 0.1839, 0.632, 1.0))),
        km.vectors.f32x4(0.82198, 0.1839, 0.632, 1.0),
        epsilon,
    );
    try km.expectVecApproxEqAbs(
        km.rgbToHsv(km.hsvToRgb(km.vectors.f32x4(0.82198, 0.1839, 0.632, 1.0))),
        km.vectors.f32x4(0.82198, 0.1839, 0.632, 1.0),
        epsilon,
    );
    try km.expectVecApproxEqAbs(
        km.rgbToHsv(km.hsvToRgb(km.vectors.f32x4(0.1839, 0.82198, 0.632, 1.0))),
        km.vectors.f32x4(0.1839, 0.82198, 0.632, 1.0),
        epsilon,
    );
}

test "kmath.color.  km.rgbToSrgb" {
    const epsilon = 0.001;
    try km.expectVecApproxEqAbs(km.rgbToSrgb(km.vectors.f32x4(0.2, 0.4, 0.8, 1.0)), km.vectors.f32x4(0.484, 0.665, 0.906, 1.0), epsilon);
}

test "kmath.color.  km.srgbToRgb" {
    const epsilon = 0.0007;
    try km.expectVecApproxEqAbs(km.vectors.f32x4(0.2, 0.4, 0.8, 1.0), km.srgbToRgb(km.vectors.f32x4(0.484, 0.665, 0.906, 1.0)), epsilon);
    try km.expectVecApproxEqAbs(
        km.rgbToSrgb(km.srgbToRgb(km.vectors.f32x4(0.1839, 0.82198, 0.632, 1.0))),
        km.vectors.f32x4(0.1839, 0.82198, 0.632, 1.0),
        epsilon,
    );
}

test "kmath.  km.linePointDistance" {
    {
        const linept0 = km.vectors.f32x4(-1.0, -2.0, -3.0, 1.0);
        const linept1 = km.vectors.f32x4(1.0, 2.0, 3.0, 1.0);
        const pt = km.vectors.f32x4(1.0, 1.0, 1.0, 1.0);
        const v = km.linePointDistance(linept0, linept1, pt);
        try km.expectVecApproxEqAbs(v, km.vectors.splat(km.vectors.F32x4, 0.654), 0.001);
    }
}

test "kmath.sincos32" {
    const epsilon = 0.0001;

    try std.testing.expect(math.isNan(km.sincos32(math.inf(f32))[0]));
    try std.testing.expect(math.isNan(km.sincos32(math.inf(f32))[1]));
    try std.testing.expect(math.isNan(km.sincos32(-math.inf(f32))[0]));
    try std.testing.expect(math.isNan(km.sincos32(-math.inf(f32))[1]));
    try std.testing.expect(math.isNan(km.sincos32(math.nan(f32))[0]));
    try std.testing.expect(math.isNan(km.sincos32(-math.nan(f32))[1]));

    try std.testing.expect(math.isNan(km.sin32(math.inf(f32))));
    try std.testing.expect(math.isNan(km.cos32(math.inf(f32))));
    try std.testing.expect(math.isNan(km.sin32(-math.inf(f32))));
    try std.testing.expect(math.isNan(km.cos32(-math.inf(f32))));
    try std.testing.expect(math.isNan(km.sin32(math.nan(f32))));
    try std.testing.expect(math.isNan(km.cos32(-math.nan(f32))));

    var f: f32 = -100.0;
    var i: u32 = 0;
    while (i < 100) : (i += 1) {
        const sc = km.sincos32(f);
        const s0 = km.sin32(f);
        const c0 = km.cos32(f);
        const s = @sin(f);
        const c = @cos(f);
        try std.testing.expect(math.approxEqAbs(f32, sc[0], s, epsilon));
        try std.testing.expect(math.approxEqAbs(f32, sc[1], c, epsilon));
        try std.testing.expect(math.approxEqAbs(f32, s0, s, epsilon));
        try std.testing.expect(math.approxEqAbs(f32, c0, c, epsilon));
        f += 0.12345 * @as(f32, @floatFromInt(i));
    }
}

test "kmath.asin32" {
    const epsilon = 0.0001;

    try std.testing.expect(math.approxEqAbs(f32, km.asin(@as(f32, -1.1)), -0.5 * math.pi, epsilon));
    try std.testing.expect(math.approxEqAbs(f32, km.asin(@as(f32, 1.1)), 0.5 * math.pi, epsilon));
    try std.testing.expect(math.approxEqAbs(f32, km.asin(@as(f32, -1000.1)), -0.5 * math.pi, epsilon));
    try std.testing.expect(math.approxEqAbs(f32, km.asin(@as(f32, 100000.1)), 0.5 * math.pi, epsilon));
    try std.testing.expect(math.isNan(km.asin(math.inf(f32))));
    try std.testing.expect(math.isNan(km.asin(-math.inf(f32))));
    try std.testing.expect(math.isNan(km.asin(math.nan(f32))));
    try std.testing.expect(math.isNan(km.asin(-math.nan(f32))));

    try km.expectVecApproxEqAbs(km.asin(km.vectors.splat(km.vectors.F32x8, -100.0)), km.vectors.splat(km.vectors.F32x8, -0.5 * math.pi), epsilon);
    try km.expectVecApproxEqAbs(km.asin(km.vectors.splat(km.vectors.F32x16, 100.0)), km.vectors.splat(km.vectors.F32x16, 0.5 * math.pi), epsilon);
    try std.testing.expect(km.all(km.isNan(km.asin(km.vectors.splat(km.vectors.F32x4, math.inf(f32)))), 0) == true);
    try std.testing.expect(km.all(km.isNan(km.asin(km.vectors.splat(km.vectors.F32x4, -math.inf(f32)))), 0) == true);
    try std.testing.expect(km.all(km.isNan(km.asin(km.vectors.splat(km.vectors.F32x4, math.nan(f32)))), 0) == true);
    try std.testing.expect(km.all(km.isNan(km.asin(km.vectors.splat(km.vectors.F32x4, math.snan(f32)))), 0) == true);

    var f: f32 = -1.0;
    var i: u32 = 0;
    while (i < 8) : (i += 1) {
        const r0 = km.asin32(f);
        const r1 = math.asin(f);
        const r4 = km.asin(km.vectors.splat(km.vectors.F32x4, f));
        const r8 = km.asin(km.vectors.splat(km.vectors.F32x8, f));
        const r16 = km.asin(km.vectors.splat(km.vectors.F32x16, f));
        try std.testing.expect(math.approxEqAbs(f32, r0, r1, epsilon));
        try km.expectVecApproxEqAbs(r4, km.vectors.splat(km.vectors.F32x4, r1), epsilon);
        try km.expectVecApproxEqAbs(r8, km.vectors.splat(km.vectors.F32x8, r1), epsilon);
        try km.expectVecApproxEqAbs(r16, km.vectors.splat(km.vectors.F32x16, r1), epsilon);
        f += 0.09 * @as(f32, @floatFromInt(i));
    }
}

test "kmath.acos32" {
    const epsilon = 0.1;

    try std.testing.expect(math.approxEqAbs(f32, km.acos(@as(f32, -1.1)), math.pi, epsilon));
    try std.testing.expect(math.approxEqAbs(f32, km.acos(@as(f32, -10000.1)), math.pi, epsilon));
    try std.testing.expect(math.approxEqAbs(f32, km.acos(@as(f32, 1.1)), 0.0, epsilon));
    try std.testing.expect(math.approxEqAbs(f32, km.acos(@as(f32, 1000.1)), 0.0, epsilon));
    try std.testing.expect(math.isNan(km.acos(math.inf(f32))));
    try std.testing.expect(math.isNan(km.acos(-math.inf(f32))));
    try std.testing.expect(math.isNan(km.acos(math.nan(f32))));
    try std.testing.expect(math.isNan(km.acos(-math.nan(f32))));

    try km.expectVecApproxEqAbs(km.acos(km.vectors.splat(km.vectors.F32x8, -100.0)), km.vectors.splat(km.vectors.F32x8, math.pi), epsilon);
    try km.expectVecApproxEqAbs(km.acos(km.vectors.splat(km.vectors.F32x16, 100.0)), km.vectors.splat(km.vectors.F32x16, 0.0), epsilon);
    try std.testing.expect(km.all(km.isNan(km.acos(km.vectors.splat(km.vectors.F32x4, math.inf(f32)))), 0) == true);
    try std.testing.expect(km.all(km.isNan(km.acos(km.vectors.splat(km.vectors.F32x4, -math.inf(f32)))), 0) == true);
    try std.testing.expect(km.all(km.isNan(km.acos(km.vectors.splat(km.vectors.F32x4, math.nan(f32)))), 0) == true);
    try std.testing.expect(km.all(km.isNan(km.acos(km.vectors.splat(km.vectors.F32x4, math.snan(f32)))), 0) == true);

    var f: f32 = -1.0;
    var i: u32 = 0;
    while (i < 8) : (i += 1) {
        const r0 = km.acos32(f);
        const r1 = math.acos(f);
        const r4 = km.acos(km.vectors.splat(km.vectors.F32x4, f));
        const r8 = km.acos(km.vectors.splat(km.vectors.F32x8, f));
        const r16 = km.acos(km.vectors.splat(km.vectors.F32x16, f));
        try std.testing.expect(math.approxEqAbs(f32, r0, r1, epsilon));
        try km.expectVecApproxEqAbs(r4, km.vectors.splat(km.vectors.F32x4, r1), epsilon);
        try km.expectVecApproxEqAbs(r8, km.vectors.splat(km.vectors.F32x8, r1), epsilon);
        try km.expectVecApproxEqAbs(r16, km.vectors.splat(km.vectors.F32x16, r1), epsilon);
        f += 0.09 * @as(f32, @floatFromInt(i));
    }
}

test "kmath. km.fft4" {
    const epsilon = 0.0001;
    var re = [_]km.vectors.F32x4{km.vectors.f32x4(1.0, 2.0, 3.0, 4.0)};
    var im = [_]km.vectors.F32x4{km.vectors.f32x4s(0.0)};
    km.fft4(re[0..], im[0..], 1);

    var re_uns: [1]km.vectors.F32x4 = undefined;
    var im_uns: [1]km.vectors.F32x4 = undefined;
    km.fftUnswizzle(re[0..], re_uns[0..]);
    km.fftUnswizzle(im[0..], im_uns[0..]);

    try km.expectVecApproxEqAbs(re_uns[0], km.vectors.f32x4(10.0, -2.0, -2.0, -2.0), epsilon);
    try km.expectVecApproxEqAbs(im_uns[0], km.vectors.f32x4(0.0, 2.0, 0.0, -2.0), epsilon);
}

test "kmath. km.fft8" {
    const epsilon = 0.0001;
    var re = [_]km.vectors.F32x4{ km.vectors.f32x4(1.0, 2.0, 3.0, 4.0), km.vectors.f32x4(5.0, 6.0, 7.0, 8.0) };
    var im = [_]km.vectors.F32x4{ km.vectors.f32x4s(0.0), km.vectors.f32x4s(0.0) };
    km.fft8(re[0..], im[0..], 1);

    var re_uns: [2]km.vectors.F32x4 = undefined;
    var im_uns: [2]km.vectors.F32x4 = undefined;
    km.fftUnswizzle(re[0..], re_uns[0..]);
    km.fftUnswizzle(im[0..], im_uns[0..]);

    try km.expectVecApproxEqAbs(re_uns[0], km.vectors.f32x4(36.0, -4.0, -4.0, -4.0), epsilon);
    try km.expectVecApproxEqAbs(re_uns[1], km.vectors.f32x4(-4.0, -4.0, -4.0, -4.0), epsilon);
    try km.expectVecApproxEqAbs(im_uns[0], km.vectors.f32x4(0.0, 9.656854, 4.0, 1.656854), epsilon);
    try km.expectVecApproxEqAbs(im_uns[1], km.vectors.f32x4(0.0, -1.656854, -4.0, -9.656854), epsilon);
}

test "kmath. km.fft16" {
    const epsilon = 0.0001;
    var re = [_]km.vectors.F32x4{
        km.vectors.f32x4(1.0, 2.0, 3.0, 4.0),
        km.vectors.f32x4(5.0, 6.0, 7.0, 8.0),
        km.vectors.f32x4(9.0, 10.0, 11.0, 12.0),
        km.vectors.f32x4(13.0, 14.0, 15.0, 16.0),
    };
    var im = [_]km.vectors.F32x4{ km.vectors.f32x4s(0.0), km.vectors.f32x4s(0.0), km.vectors.f32x4s(0.0), km.vectors.f32x4s(0.0) };
    km.fft16(re[0..], im[0..], 1);

    var re_uns: [4]km.vectors.F32x4 = undefined;
    var im_uns: [4]km.vectors.F32x4 = undefined;
    km.fftUnswizzle(re[0..], re_uns[0..]);
    km.fftUnswizzle(im[0..], im_uns[0..]);

    try km.expectVecApproxEqAbs(re_uns[0], km.vectors.f32x4(136.0, -8.0, -8.0, -8.0), epsilon);
    try km.expectVecApproxEqAbs(re_uns[1], km.vectors.f32x4(-8.0, -8.0, -8.0, -8.0), epsilon);
    try km.expectVecApproxEqAbs(re_uns[2], km.vectors.f32x4(-8.0, -8.0, -8.0, -8.0), epsilon);
    try km.expectVecApproxEqAbs(re_uns[3], km.vectors.f32x4(-8.0, -8.0, -8.0, -8.0), epsilon);
    try km.expectVecApproxEqAbs(im_uns[0], km.vectors.f32x4(0.0, 40.218716, 19.313708, 11.972846), epsilon);
    try km.expectVecApproxEqAbs(im_uns[1], km.vectors.f32x4(8.0, 5.345429, 3.313708, 1.591299), epsilon);
    try km.expectVecApproxEqAbs(im_uns[2], km.vectors.f32x4(0.0, -1.591299, -3.313708, -5.345429), epsilon);
    try km.expectVecApproxEqAbs(im_uns[3], km.vectors.f32x4(-8.0, -11.972846, -19.313708, -40.218716), epsilon);
}

test "kmath.fftN" {
    var unity_table: [128]km.vectors.F32x4 = undefined;
    const epsilon = 0.0001;

    // 32 samples
    {
        var re = [_]km.vectors.F32x4{
            km.vectors.f32x4(1.0, 2.0, 3.0, 4.0),     km.vectors.f32x4(5.0, 6.0, 7.0, 8.0),
            km.vectors.f32x4(9.0, 10.0, 11.0, 12.0),  km.vectors.f32x4(13.0, 14.0, 15.0, 16.0),
            km.vectors.f32x4(17.0, 18.0, 19.0, 20.0), km.vectors.f32x4(21.0, 22.0, 23.0, 24.0),
            km.vectors.f32x4(25.0, 26.0, 27.0, 28.0), km.vectors.f32x4(29.0, 30.0, 31.0, 32.0),
        };
        var im = [_]km.vectors.F32x4{
            km.vectors.f32x4s(0.0), km.vectors.f32x4s(0.0), km.vectors.f32x4s(0.0), km.vectors.f32x4s(0.0),
            km.vectors.f32x4s(0.0), km.vectors.f32x4s(0.0), km.vectors.f32x4s(0.0), km.vectors.f32x4s(0.0),
        };

        fftInitUnityTable(unity_table[0..32]);
        km.fft(re[0..], im[0..], unity_table[0..32]);

        try km.expectVecApproxEqAbs(re[0], km.vectors.f32x4(528.0, -16.0, -16.0, -16.0), epsilon);
        try km.expectVecApproxEqAbs(re[1], km.vectors.f32x4(-16.0, -16.0, -16.0, -16.0), epsilon);
        try km.expectVecApproxEqAbs(re[2], km.vectors.f32x4(-16.0, -16.0, -16.0, -16.0), epsilon);
        try km.expectVecApproxEqAbs(re[3], km.vectors.f32x4(-16.0, -16.0, -16.0, -16.0), epsilon);
        try km.expectVecApproxEqAbs(re[4], km.vectors.f32x4(-16.0, -16.0, -16.0, -16.0), epsilon);
        try km.expectVecApproxEqAbs(re[5], km.vectors.f32x4(-16.0, -16.0, -16.0, -16.0), epsilon);
        try km.expectVecApproxEqAbs(re[6], km.vectors.f32x4(-16.0, -16.0, -16.0, -16.0), epsilon);
        try km.expectVecApproxEqAbs(re[7], km.vectors.f32x4(-16.0, -16.0, -16.0, -16.0), epsilon);
        try km.expectVecApproxEqAbs(im[0], km.vectors.f32x4(0.0, 162.450726, 80.437432, 52.744931), epsilon);
        try km.expectVecApproxEqAbs(im[1], km.vectors.f32x4(38.627417, 29.933895, 23.945692, 19.496056), epsilon);
        try km.expectVecApproxEqAbs(im[2], km.vectors.f32x4(16.0, 13.130861, 10.690858, 8.552178), epsilon);
        try km.expectVecApproxEqAbs(im[3], km.vectors.f32x4(6.627417, 4.853547, 3.182598, 1.575862), epsilon);
        try km.expectVecApproxEqAbs(im[4], km.vectors.f32x4(0.0, -1.575862, -3.182598, -4.853547), epsilon);
        try km.expectVecApproxEqAbs(im[5], km.vectors.f32x4(-6.627417, -8.552178, -10.690858, -13.130861), epsilon);
        try km.expectVecApproxEqAbs(im[6], km.vectors.f32x4(-16.0, -19.496056, -23.945692, -29.933895), epsilon);
        try km.expectVecApproxEqAbs(im[7], km.vectors.f32x4(-38.627417, -52.744931, -80.437432, -162.450726), epsilon);
    }

    // 64 samples
    {
        var re = [_]km.vectors.F32x4{
            km.vectors.f32x4(1.0, 2.0, 3.0, 4.0),     km.vectors.f32x4(5.0, 6.0, 7.0, 8.0),
            km.vectors.f32x4(9.0, 10.0, 11.0, 12.0),  km.vectors.f32x4(13.0, 14.0, 15.0, 16.0),
            km.vectors.f32x4(17.0, 18.0, 19.0, 20.0), km.vectors.f32x4(21.0, 22.0, 23.0, 24.0),
            km.vectors.f32x4(25.0, 26.0, 27.0, 28.0), km.vectors.f32x4(29.0, 30.0, 31.0, 32.0),
            km.vectors.f32x4(1.0, 2.0, 3.0, 4.0),     km.vectors.f32x4(5.0, 6.0, 7.0, 8.0),
            km.vectors.f32x4(9.0, 10.0, 11.0, 12.0),  km.vectors.f32x4(13.0, 14.0, 15.0, 16.0),
            km.vectors.f32x4(17.0, 18.0, 19.0, 20.0), km.vectors.f32x4(21.0, 22.0, 23.0, 24.0),
            km.vectors.f32x4(25.0, 26.0, 27.0, 28.0), km.vectors.f32x4(29.0, 30.0, 31.0, 32.0),
        };
        var im = [_]km.vectors.F32x4{
            km.vectors.f32x4s(0.0), km.vectors.f32x4s(0.0), km.vectors.f32x4s(0.0), km.vectors.f32x4s(0.0),
            km.vectors.f32x4s(0.0), km.vectors.f32x4s(0.0), km.vectors.f32x4s(0.0), km.vectors.f32x4s(0.0),
            km.vectors.f32x4s(0.0), km.vectors.f32x4s(0.0), km.vectors.f32x4s(0.0), km.vectors.f32x4s(0.0),
            km.vectors.f32x4s(0.0), km.vectors.f32x4s(0.0), km.vectors.f32x4s(0.0), km.vectors.f32x4s(0.0),
        };

        fftInitUnityTable(unity_table[0..64]);
        km.fft(re[0..], im[0..], unity_table[0..64]);

        try km.expectVecApproxEqAbs(re[0], km.vectors.f32x4(1056.0, 0.0, -32.0, 0.0), epsilon);
        var i: u32 = 1;
        while (i < 16) : (i += 1) {
            try km.expectVecApproxEqAbs(re[i], km.vectors.f32x4(-32.0, 0.0, -32.0, 0.0), epsilon);
        }

        const expected = [_]f32{
            0.0,        0.0,      324.901452,  0.000000, 160.874864,  0.0,      105.489863,  0.000000,
            77.254834,  0.0,      59.867789,   0.0,      47.891384,   0.0,      38.992113,   0.0,
            32.000000,  0.000000, 26.261721,   0.000000, 21.381716,   0.000000, 17.104356,   0.000000,
            13.254834,  0.000000, 9.707094,    0.000000, 6.365196,    0.000000, 3.151725,    0.000000,
            0.000000,   0.000000, -3.151725,   0.000000, -6.365196,   0.000000, -9.707094,   0.000000,
            -13.254834, 0.000000, -17.104356,  0.000000, -21.381716,  0.000000, -26.261721,  0.000000,
            -32.000000, 0.000000, -38.992113,  0.000000, -47.891384,  0.000000, -59.867789,  0.000000,
            -77.254834, 0.000000, -105.489863, 0.000000, -160.874864, 0.000000, -324.901452, 0.000000,
        };
        for (expected, 0..) |e, ie| {
            try std.testing.expect(math.approxEqAbs(f32, e, im[(ie / 4)][ie % 4], epsilon));
        }
    }

    // 128 samples
    {
        var re = [_]km.vectors.F32x4{
            km.vectors.f32x4(1.0, 2.0, 3.0, 4.0),     km.vectors.f32x4(5.0, 6.0, 7.0, 8.0),
            km.vectors.f32x4(9.0, 10.0, 11.0, 12.0),  km.vectors.f32x4(13.0, 14.0, 15.0, 16.0),
            km.vectors.f32x4(17.0, 18.0, 19.0, 20.0), km.vectors.f32x4(21.0, 22.0, 23.0, 24.0),
            km.vectors.f32x4(25.0, 26.0, 27.0, 28.0), km.vectors.f32x4(29.0, 30.0, 31.0, 32.0),
            km.vectors.f32x4(1.0, 2.0, 3.0, 4.0),     km.vectors.f32x4(5.0, 6.0, 7.0, 8.0),
            km.vectors.f32x4(9.0, 10.0, 11.0, 12.0),  km.vectors.f32x4(13.0, 14.0, 15.0, 16.0),
            km.vectors.f32x4(17.0, 18.0, 19.0, 20.0), km.vectors.f32x4(21.0, 22.0, 23.0, 24.0),
            km.vectors.f32x4(25.0, 26.0, 27.0, 28.0), km.vectors.f32x4(29.0, 30.0, 31.0, 32.0),
            km.vectors.f32x4(1.0, 2.0, 3.0, 4.0),     km.vectors.f32x4(5.0, 6.0, 7.0, 8.0),
            km.vectors.f32x4(9.0, 10.0, 11.0, 12.0),  km.vectors.f32x4(13.0, 14.0, 15.0, 16.0),
            km.vectors.f32x4(17.0, 18.0, 19.0, 20.0), km.vectors.f32x4(21.0, 22.0, 23.0, 24.0),
            km.vectors.f32x4(25.0, 26.0, 27.0, 28.0), km.vectors.f32x4(29.0, 30.0, 31.0, 32.0),
            km.vectors.f32x4(1.0, 2.0, 3.0, 4.0),     km.vectors.f32x4(5.0, 6.0, 7.0, 8.0),
            km.vectors.f32x4(9.0, 10.0, 11.0, 12.0),  km.vectors.f32x4(13.0, 14.0, 15.0, 16.0),
            km.vectors.f32x4(17.0, 18.0, 19.0, 20.0), km.vectors.f32x4(21.0, 22.0, 23.0, 24.0),
            km.vectors.f32x4(25.0, 26.0, 27.0, 28.0), km.vectors.f32x4(29.0, 30.0, 31.0, 32.0),
        };
        var im = [_]km.vectors.F32x4{
            km.vectors.f32x4s(0.0), km.vectors.f32x4s(0.0), km.vectors.f32x4s(0.0), km.vectors.f32x4s(0.0),
            km.vectors.f32x4s(0.0), km.vectors.f32x4s(0.0), km.vectors.f32x4s(0.0), km.vectors.f32x4s(0.0),
            km.vectors.f32x4s(0.0), km.vectors.f32x4s(0.0), km.vectors.f32x4s(0.0), km.vectors.f32x4s(0.0),
            km.vectors.f32x4s(0.0), km.vectors.f32x4s(0.0), km.vectors.f32x4s(0.0), km.vectors.f32x4s(0.0),
            km.vectors.f32x4s(0.0), km.vectors.f32x4s(0.0), km.vectors.f32x4s(0.0), km.vectors.f32x4s(0.0),
            km.vectors.f32x4s(0.0), km.vectors.f32x4s(0.0), km.vectors.f32x4s(0.0), km.vectors.f32x4s(0.0),
            km.vectors.f32x4s(0.0), km.vectors.f32x4s(0.0), km.vectors.f32x4s(0.0), km.vectors.f32x4s(0.0),
            km.vectors.f32x4s(0.0), km.vectors.f32x4s(0.0), km.vectors.f32x4s(0.0), km.vectors.f32x4s(0.0),
        };

        fftInitUnityTable(unity_table[0..128]);
        km.fft(re[0..], im[0..], unity_table[0..128]);

        try km.expectVecApproxEqAbs(re[0], km.vectors.f32x4(2112.0, 0.0, 0.0, 0.0), epsilon);
        var i: u32 = 1;
        while (i < 32) : (i += 1) {
            try km.expectVecApproxEqAbs(re[i], km.vectors.f32x4(-64.0, 0.0, 0.0, 0.0), epsilon);
        }

        const expected = [_]f32{
            0.000000,    0.000000, 0.000000, 0.000000, 649.802905,  0.000000, 0.000000, 0.000000,
            321.749727,  0.000000, 0.000000, 0.000000, 210.979725,  0.000000, 0.000000, 0.000000,
            154.509668,  0.000000, 0.000000, 0.000000, 119.735578,  0.000000, 0.000000, 0.000000,
            95.782769,   0.000000, 0.000000, 0.000000, 77.984226,   0.000000, 0.000000, 0.000000,
            64.000000,   0.000000, 0.000000, 0.000000, 52.523443,   0.000000, 0.000000, 0.000000,
            42.763433,   0.000000, 0.000000, 0.000000, 34.208713,   0.000000, 0.000000, 0.000000,
            26.509668,   0.000000, 0.000000, 0.000000, 19.414188,   0.000000, 0.000000, 0.000000,
            12.730392,   0.000000, 0.000000, 0.000000, 6.303450,    0.000000, 0.000000, 0.000000,
            0.000000,    0.000000, 0.000000, 0.000000, -6.303450,   0.000000, 0.000000, 0.000000,
            -12.730392,  0.000000, 0.000000, 0.000000, -19.414188,  0.000000, 0.000000, 0.000000,
            -26.509668,  0.000000, 0.000000, 0.000000, -34.208713,  0.000000, 0.000000, 0.000000,
            -42.763433,  0.000000, 0.000000, 0.000000, -52.523443,  0.000000, 0.000000, 0.000000,
            -64.000000,  0.000000, 0.000000, 0.000000, -77.984226,  0.000000, 0.000000, 0.000000,
            -95.782769,  0.000000, 0.000000, 0.000000, -119.735578, 0.000000, 0.000000, 0.000000,
            -154.509668, 0.000000, 0.000000, 0.000000, -210.979725, 0.000000, 0.000000, 0.000000,
            -321.749727, 0.000000, 0.000000, 0.000000, -649.802905, 0.000000, 0.000000, 0.000000,
        };
        for (expected, 0..) |e, ie| {
            try std.testing.expect(math.approxEqAbs(f32, e, im[(ie / 4)][ie % 4], epsilon));
        }
    }
}

pub fn fftInitUnityTable(out_unity_table: []km.vectors.F32x4) void {
    std.debug.assert(std.math.isPowerOfTwo(out_unity_table.len));
    std.debug.assert(out_unity_table.len >= 32 and out_unity_table.len <= 512);

    var unity_table = out_unity_table;

    const v0123 = km.vectors.f32x4(0.0, 1.0, 2.0, 3.0);
    var length = out_unity_table.len / 4;
    var vlstep = km.vectors.f32x4s(0.5 * math.pi / @as(f32, @floatFromInt(length)));

    while (true) {
        length /= 4;
        var vjp = v0123;

        var j: u32 = 0;
        while (j < length) : (j += 1) {
            unity_table[j] = km.vectors.f32x4s(1.0);
            unity_table[j + length * 4] = km.vectors.f32x4s(0.0);

            var vls = vjp * vlstep;
            var sin_cos = km.sincos(vls);
            unity_table[j + length] = sin_cos[1];
            unity_table[j + length * 5] = sin_cos[0] * km.vectors.f32x4s(-1.0);

            var vijp = vjp + vjp;
            vls = vijp * vlstep;
            sin_cos = km.sincos(vls);
            unity_table[j + length * 2] = sin_cos[1];
            unity_table[j + length * 6] = sin_cos[0] * km.vectors.f32x4s(-1.0);

            vijp = vijp + vjp;
            vls = vijp * vlstep;
            sin_cos = km.sincos(vls);
            unity_table[j + length * 3] = sin_cos[1];
            unity_table[j + length * 7] = sin_cos[0] * km.vectors.f32x4s(-1.0);

            vjp += km.vectors.f32x4s(4.0);
        }
        vlstep *= km.vectors.f32x4s(4.0);
        unity_table = unity_table[8 * length ..];

        if (length <= 4)
            break;
    }
}

test "kmath.ifft" {
    var unity_table: [512]km.vectors.F32x4 = undefined;
    const epsilon = 0.0001;

    // 64 samples
    {
        var re = [_]km.vectors.F32x4{
            km.vectors.f32x4(1.0, 2.0, 3.0, 4.0),     km.vectors.f32x4(5.0, 6.0, 7.0, 8.0),
            km.vectors.f32x4(9.0, 10.0, 11.0, 12.0),  km.vectors.f32x4(13.0, 14.0, 15.0, 16.0),
            km.vectors.f32x4(17.0, 18.0, 19.0, 20.0), km.vectors.f32x4(21.0, 22.0, 23.0, 24.0),
            km.vectors.f32x4(25.0, 26.0, 27.0, 28.0), km.vectors.f32x4(29.0, 30.0, 31.0, 32.0),
            km.vectors.f32x4(1.0, 2.0, 3.0, 4.0),     km.vectors.f32x4(5.0, 6.0, 7.0, 8.0),
            km.vectors.f32x4(9.0, 10.0, 11.0, 12.0),  km.vectors.f32x4(13.0, 14.0, 15.0, 16.0),
            km.vectors.f32x4(17.0, 18.0, 19.0, 20.0), km.vectors.f32x4(21.0, 22.0, 23.0, 24.0),
            km.vectors.f32x4(25.0, 26.0, 27.0, 28.0), km.vectors.f32x4(29.0, 30.0, 31.0, 32.0),
        };
        var im = [_]km.vectors.F32x4{
            km.vectors.f32x4s(0.0), km.vectors.f32x4s(0.0), km.vectors.f32x4s(0.0), km.vectors.f32x4s(0.0),
            km.vectors.f32x4s(0.0), km.vectors.f32x4s(0.0), km.vectors.f32x4s(0.0), km.vectors.f32x4s(0.0),
            km.vectors.f32x4s(0.0), km.vectors.f32x4s(0.0), km.vectors.f32x4s(0.0), km.vectors.f32x4s(0.0),
            km.vectors.f32x4s(0.0), km.vectors.f32x4s(0.0), km.vectors.f32x4s(0.0), km.vectors.f32x4s(0.0),
        };

        fftInitUnityTable(unity_table[0..64]);
        km.fft(re[0..], im[0..], unity_table[0..64]);

        try km.expectVecApproxEqAbs(re[0], km.vectors.f32x4(1056.0, 0.0, -32.0, 0.0), epsilon);
        var i: u32 = 1;
        while (i < 16) : (i += 1) {
            try km.expectVecApproxEqAbs(re[i], km.vectors.f32x4(-32.0, 0.0, -32.0, 0.0), epsilon);
        }

        km.ifft(re[0..], im[0..], unity_table[0..64]);

        try km.expectVecApproxEqAbs(re[0], km.vectors.f32x4(1.0, 2.0, 3.0, 4.0), epsilon);
        try km.expectVecApproxEqAbs(re[1], km.vectors.f32x4(5.0, 6.0, 7.0, 8.0), epsilon);
        try km.expectVecApproxEqAbs(re[2], km.vectors.f32x4(9.0, 10.0, 11.0, 12.0), epsilon);
        try km.expectVecApproxEqAbs(re[3], km.vectors.f32x4(13.0, 14.0, 15.0, 16.0), epsilon);
        try km.expectVecApproxEqAbs(re[4], km.vectors.f32x4(17.0, 18.0, 19.0, 20.0), epsilon);
        try km.expectVecApproxEqAbs(re[5], km.vectors.f32x4(21.0, 22.0, 23.0, 24.0), epsilon);
        try km.expectVecApproxEqAbs(re[6], km.vectors.f32x4(25.0, 26.0, 27.0, 28.0), epsilon);
        try km.expectVecApproxEqAbs(re[7], km.vectors.f32x4(29.0, 30.0, 31.0, 32.0), epsilon);
    }

    // 512 samples
    {
        var re: [128]km.vectors.F32x4 = undefined;
        var im = [_]km.vectors.F32x4{km.vectors.f32x4s(0.0)} ** 128;

        for (&re, 0..) |*v, i| {
            const f = @as(f32, @floatFromInt(i * 4));
            v.* = km.vectors.f32x4(f + 1.0, f + 2.0, f + 3.0, f + 4.0);
        }

        fftInitUnityTable(unity_table[0..512]);
        km.fft(re[0..], im[0..], unity_table[0..512]);

        for (re, 0..) |v, i| {
            const f = @as(f32, @floatFromInt(i * 4));
            try std.testing.expect(!km.approxEqAbs(v, km.vectors.f32x4(f + 1.0, f + 2.0, f + 3.0, f + 4.0), epsilon));
        }

        km.ifft(re[0..], im[0..], unity_table[0..512]);

        for (re, 0..) |v, i| {
            const f = @as(f32, @floatFromInt(i * 4));
            try km.expectVecApproxEqAbs(v, km.vectors.f32x4(f + 1.0, f + 2.0, f + 3.0, f + 4.0), epsilon);
        }
    }
}

test "kmath.km.floatToIntAndBack" {
    {
        const v = km.floatToIntAndBack(km.vectors.f32x4(1.1, 2.9, 3.0, -4.5));
        try km.expectVecEqual(v, km.vectors.f32x4(1.0, 2.0, 3.0, -4.0));
    }
    {
        const v = km.floatToIntAndBack(km.vectors.f32x8(1.1, 2.9, 3.0, -4.5, 2.5, -2.5, 1.1, -100.2));
        try km.expectVecEqual(v, km.vectors.f32x8(1.0, 2.0, 3.0, -4.0, 2.0, -2.0, 1.0, -100.0));
    }
    {
        const v = km.floatToIntAndBack(km.vectors.f32x4(math.inf(f32), 2.9, math.nan(f32), math.snan(f32)));
        try std.testing.expect(v[1] == 2.0);
    }
}

test "kmath.util.mat.scale" {
    const mat = km.mul(km.scaling(3, 4, 5), km.translation(6, 7, 8));
    const scale = util.getScaleVec(mat);
    try km.expectVecApproxEqAbs(scale, vectors.f32x4(3.0, 4.0, 5.0, 0.0), 0.0001);
}

test "kmath.util.mat.rotation" {
    const rotate_origin = km.matFromRollPitchYaw(0.1, 1.2, 2.3);
    const mat = km.mul(km.mul(rotate_origin, km.scaling(3, 4, 5)), km.translation(6, 7, 8));
    const rotate_get = util.getRotationQuat(mat);
    const v0 = km.mul(vectors.f32x4s(1), rotate_origin);
    const v1 = km.mul(vectors.f32x4s(1), km.quatToMat(rotate_get));
    try km.expectVecApproxEqAbs(v0, v1, 0.0001);
}

test "kmath.util.mat.z_vec" {
    const degToRad = std.math.degreesToRadians;
    var identity = km.identity();
    var z_vec = util.getAxisZ(identity);
    try km.expectVecApproxEqAbs(z_vec, vectors.f32x4(0.0, 0.0, 1.0, 0), 0.0001);
    const rot_yaw = km.rotationY(degToRad(90));
    identity = km.mul(identity, rot_yaw);
    z_vec = util.getAxisZ(identity);
    try km.expectVecApproxEqAbs(z_vec, vectors.f32x4(1.0, 0.0, 0.0, 0), 0.0001);
}

test "kmath.util.mat.y_vec" {
    const degToRad = std.math.degreesToRadians;
    var identity = km.identity();
    var y_vec = util.getAxisY(identity);
    try km.expectVecApproxEqAbs(y_vec, vectors.f32x4(0.0, 1.0, 0.0, 0), 0.01);
    const rot_yaw = km.rotationY(degToRad(90));
    identity = km.mul(identity, rot_yaw);
    y_vec = util.getAxisY(identity);
    try km.expectVecApproxEqAbs(y_vec, vectors.f32x4(0.0, 1.0, 0.0, 0), 0.01);
    const rot_pitch = km.rotationX(degToRad(90));
    identity = km.mul(identity, rot_pitch);
    y_vec = util.getAxisY(identity);
    try km.expectVecApproxEqAbs(y_vec, vectors.f32x4(0.0, 0.0, 1.0, 0), 0.01);
}

test "kmath.util.mat.right" {
    const degToRad = std.math.degreesToRadians;
    var identity = km.identity();
    var right = util.getAxisX(identity);
    try km.expectVecApproxEqAbs(right, vectors.f32x4(1.0, 0.0, 0.0, 0), 0.01);
    const rot_yaw = km.rotationY(degToRad(90));
    identity = km.mul(identity, rot_yaw);
    right = util.getAxisX(identity);
    try km.expectVecApproxEqAbs(right, vectors.f32x4(0.0, 0.0, -1.0, 0), 0.01);
    const rot_pitch = km.rotationX(degToRad(90));
    identity = km.mul(identity, rot_pitch);
    right = util.getAxisX(identity);
    try km.expectVecApproxEqAbs(right, vectors.f32x4(0.0, 1.0, 0.0, 0), 0.01);
}

// ------------------------------------------------------------------------------
// This software is available under 2 licenses -- choose whichever you prefer.
// ------------------------------------------------------------------------------
// ALTERNATIVE A - MIT License
// Copyright (c) 2022 Michal Ziulek and Contributors
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy,  km.modify, merge, publish, distribute, sublicense, and/or sell copies
// of the Software, and to permit persons to whom the Software is furnished to do
// so, subject to the following conditions:
// The above copyright notice and this permission notice shkm.all be included in km.all
// copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHkm.all THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
// ------------------------------------------------------------------------------
// ALTERNATIVE B - Public Domain (www.unlicense.org)
// This is free and unencumbered software released into the public domain.
// Anyone is free to copy,  km.modify, publish, use, compile, sell, or distribute this
// software, either in source code form or as a compiled binary, for any purpose,
// commercial or non-commercial, and by any means.
// In jurisdictions that recognize copyright laws, the author or authors of this
// software dedicate any and km.all copyright interest in the software to the public
// domain. We make this dedication for the benefit of the public at large and to
// the detriment of our heirs and successors. We intend this dedication to be an
// overt act of relinquishment in perpetuity of km.all present and future rights to
// this software under copyright law.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHkm.all THE
// AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
// ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
// WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
// ------------------------------------------------------------------------------
