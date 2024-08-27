//--------------------------------------------------------------------------------------------------
//
// SIMD math library for game developers
// https://github.com/kiffpuppygames/kiff-math
//
// See kmath.zig for more details.
// See util.zig for additional functionality.
//
//--------------------------------------------------------------------------------------------------

// ==============================================================================
//
// SIMD std.math library for game developers
// hhttps://github.com/kiffpuppygames/kiff-math
//
// Should work on all OSes supported by Zig. Works on x86_64 and ARM.
// Provides ~140 optimized routines and ~70 extensive tests.
// Can be used with any graphics API.
//
// kmath uses row-major matrices, row vectors (each row vector is stored in a SIMD register).
// Handedness is determined by which function version is used (Rh vs. Lh),
// otherwise the function works with either left-handed or right-handed view coordinates.
//
// const va = vectors.f32x4(1.0, 2.0, 3.0, 1.0);
// const vb = vectors.f32x4(-1.0, 1.0, -1.0, 1.0);
// const v0 = va + vb - vectors.f32x4(0.0, 1.0, 0.0, 1.0) * vectors.f32x4s(3.0);
// const v1 = cross3(va, vb) + vectors.f32x4(1.0, 1.0, 1.0, 1.0);
// const v2 = va + dot3(va, vb) / v1; // dotN() returns scalar replicated on all vector components
//
// const m = rotationX(std.math.pi * 0.25);
// const v = vectors.f32x4(...);
// const v0 = mul(v, m); // 'v' treated as a row vector
// const v1 = mul(m, v); // 'v' treated as a column vector
// const f = m[row][column];
//
// const b = va < vb;
// if (all(b, 0)) { ... } // '0' means check all vector components; if all are 'true'
// if (all(b, 3)) { ... } // '3' means check first three vector components; if all first three are 'true'
// if (any(b, 0)) { ... } // '0' means check all vector components; if any is 'true'
// if (any(b, 3)) { ... } // '3' means check first three vector components; if any from first three is 'true'
//
// var v4 = load(mem[0..],  vectors.F32x4, 0);
// var v8 = load(mem[100..],  vectors.F32x8, 0);
// var v16 = load(mem[200..],  vectors.F32x16, 0);
//
// var camera_position = [3]f32{ 1.0, 2.0, 3.0 };
// var cam_pos = loadArr3(camera_position);
// ...
// storeArr3(&camera_position, cam_pos);
//
// v4 = sin(v4); // SIMDx4
// v8 = cos(v8); // .x86_64 -> 2 x SIMDx4, .x86_64+avx+fma -> SIMDx8
// v16 = atan(v16); // .x86_64 -> 4 x SIMDx4, .x86_64+avx+fma -> 2 x SIMDx8, .x86_64+avx512f -> SIMDx16
//
// store(mem[0..], v4, 0);
// store(mem[100..], v8, 0);
// store(mem[200..], v16, 0);
//
// ------------------------------------------------------------------------------
// 1. Initialization functions
// ------------------------------------------------------------------------------
//
// vectors.f32x4(e0: f32, e1: f32, e2: f32, e3: f32)  vectors.F32x4
// f32x8(e0: f32, e1: f32, e2: f32, e3: f32, e4: f32, e5: f32, e6: f32, e7: f32)  vectors.F32x8
// f32x16(e0: f32, e1: f32, e2: f32, e3: f32, e4: f32, e5: f32, e6: f32, e7: f32,
//        e8: f32, e9: f32, ea: f32, eb: f32, ec: f32, ed: f32, ee: f32, ef: f32)  vectors.F32x16
//
// vectors.f32x4s(e0: f32)  vectors.F32x4
// f32x8s(e0: f32)  vectors.F32x8
// f32x16s(e0: f32)  vectors.F32x16
//
// vectors.boolx4(e0: bool, e1: bool, e2: bool, e3: bool) Boolx4
// boolx8(e0: bool, e1: bool, e2: bool, e3: bool, e4: bool, e5: bool, e6: bool, e7: bool) Boolx8
// boolx16(e0: bool, e1: bool, e2: bool, e3: bool, e4: bool, e5: bool, e6: bool, e7: bool,
//         e8: bool, e9: bool, ea: bool, eb: bool, ec: bool, ed: bool, ee: bool, ef: bool) Boolx16
//
// load(mem: []const f32, comptime T: type, comptime len: u32) T
// store(mem: []f32, v: anytype, comptime len: u32) void
//
// loadArr2(arr: [2]f32)  vectors.F32x4
// loadArr2zw(arr: [2]f32, z: f32, w: f32)  vectors.F32x4
// loadArr3(arr: [3]f32)  vectors.F32x4
// loadArr3w(arr: [3]f32, w: f32)  vectors.F32x4
// loadArr4(arr: [4]f32)  vectors.F32x4
//
// storeArr2(arr: *[2]f32, v:  vectors.F32x4) void
// storeArr3(arr: *[3]f32, v:  vectors.F32x4) void
// storeArr4(arr: *[4]f32, v:  vectors.F32x4) void
//
// arr3Ptr(ptr: anytype) *const [3]f32
// arrNPtr(ptr: anytype) [*]const f32
//
// vectors.splat(comptime T: type, value: f32) T
//  vectors.splatInt(comptime T: type, value: u32) T
//
// ------------------------------------------------------------------------------
// 2. Functions that work on all vector components (F32xN =  vectors.F32x4 or  vectors.F32x8 or  vectors.F32x16)
// ------------------------------------------------------------------------------
//
// all(vb: anytype, comptime len: u32) bool
// any(vb: anytype, comptime len: u32) bool
//
// isNearEqual(v0: F32xN, v1: F32xN, epsilon: F32xN) BoolxN
// isNan(v: F32xN) BoolxN
// isInf(v: F32xN) BoolxN
// isInBounds(v: F32xN, bounds: F32xN) BoolxN
//
// andInt(v0: F32xN, v1: F32xN) F32xN
// andNotInt(v0: F32xN, v1: F32xN) F32xN
// orInt(v0: F32xN, v1: F32xN) F32xN
// norInt(v0: F32xN, v1: F32xN) F32xN
// xorInt(v0: F32xN, v1: F32xN) F32xN
//
// minFast(v0: F32xN, v1: F32xN) F32xN
// maxFast(v0: F32xN, v1: F32xN) F32xN
// min(v0: F32xN, v1: F32xN) F32xN
// max(v0: F32xN, v1: F32xN) F32xN
// round(v: F32xN) F32xN
// floor(v: F32xN) F32xN
// trunc(v: F32xN) F32xN
// ceil(v: F32xN) F32xN
// clamp(v0: F32xN, v1: F32xN) F32xN
// clampFast(v0: F32xN, v1: F32xN) F32xN
// saturate(v: F32xN) F32xN
// saturateFast(v: F32xN) F32xN
// lerp(v0: F32xN, v1: F32xN, t: f32) F32xN
// lerpV(v0: F32xN, v1: F32xN, t: F32xN) F32xN
// lerpInverse(v0: F32xN, v1: F32xN, t: f32) F32xN
// lerpInverseV(v0: F32xN, v1: F32xN, t: F32xN) F32xN
// mapLinear(v: F32xN, min1: f32, max1: f32, min2: f32, max2: f32) F32xN
// mapLinearV(v: F32xN, min1: F32xN, max1: F32xN, min2: F32xN, max2: F32xN) F32xN
// sqrt(v: F32xN) F32xN
// abs(v: F32xN) F32xN
// mod(v0: F32xN, v1: F32xN) F32xN
// modAngle(v: F32xN) F32xN
// mulAdd(v0: F32xN, v1: F32xN, v2: F32xN) F32xN
// select(mask: BoolxN, v0: F32xN, v1: F32xN)
// sin(v: F32xN) F32xN
// cos(v: F32xN) F32xN
// sincos(v: F32xN) [2]F32xN
// asin(v: F32xN) F32xN
// acos(v: F32xN) F32xN
// atan(v: F32xN) F32xN
// atan2(vy: F32xN, vx: F32xN) F32xN
// cmulSoa(re0: F32xN, im0: F32xN, re1: F32xN, im1: F32xN) [2]F32xN
//
// ------------------------------------------------------------------------------
// 3. 2D, 3D, 4D vector functions
// ------------------------------------------------------------------------------
//
// swizzle(v: vectors.Vec, c, c, c, c) vectors.Vec (comptime c = .x | .y | .z | .w)
// dot2(v0: vectors.Vec, v1: vectors.Vec)  vectors.F32x4
// dot3(v0: vectors.Vec, v1: vectors.Vec)  vectors.F32x4
// dot4(v0: vectors.Vec, v1: vectors.Vec)  vectors.F32x4
// cross3(v0: vectors.Vec, v1: vectors.Vec) vectors.Vec
// lengthSq2(v: vectors.Vec)  vectors.F32x4
// lengthSq3(v: vectors.Vec)  vectors.F32x4
// lengthSq4(v: vectors.Vec)  vectors.F32x4
// length2(v: vectors.Vec)  vectors.F32x4
// length3(v: vectors.Vec)  vectors.F32x4
// length4(v: vectors.Vec)  vectors.F32x4
// normalize2(v: vectors.Vec) vectors.Vec
// normalize3(v: vectors.Vec) vectors.Vec
// normalize4(v: vectors.Vec) vectors.Vec
//
// vecToArr2(v: vectors.Vec) [2]f32
// vecToArr3(v: vectors.Vec) [3]f32
// vecToArr4(v: vectors.Vec) [4]f32
//
// ------------------------------------------------------------------------------
// 4. Matrix functions
// ------------------------------------------------------------------------------
//
// identity() Mat
// mul(m0: Mat, m1: Mat) Mat
// mul(s: f32, m: Mat) Mat
// mul(m: Mat, s: f32) Mat
// mul(v: vectors.Vec, m: Mat) vectors.Vec
// mul(m: Mat, v: vectors.Vec) vectors.Vec
// transpose(m: Mat) Mat
// rotationX(angle: f32) Mat
// rotationY(angle: f32) Mat
// rotationZ(angle: f32) Mat
// translation(x: f32, y: f32, z: f32) Mat
// translationV(v: vectors.Vec) Mat
// scaling(x: f32, y: f32, z: f32) Mat
// scalingV(v: vectors.Vec) Mat
// lookToLh(eyepos: vectors.Vec, eyedir: vectors.Vec, updir: vectors.Vec) Mat
// lookAtLh(eyepos: vectors.Vec, focuspos: vectors.Vec, updir: vectors.Vec) Mat
// lookToRh(eyepos: vectors.Vec, eyedir: vectors.Vec, updir: vectors.Vec) Mat
// lookAtRh(eyepos: vectors.Vec, focuspos: vectors.Vec, updir: vectors.Vec) Mat
// perspectiveFovLh(fovy: f32, aspect: f32, near: f32, far: f32) Mat
// perspectiveFovRh(fovy: f32, aspect: f32, near: f32, far: f32) Mat
// perspectiveFovLhGl(fovy: f32, aspect: f32, near: f32, far: f32) Mat
// perspectiveFovRhGl(fovy: f32, aspect: f32, near: f32, far: f32) Mat
// orthographicLh(w: f32, h: f32, near: f32, far: f32) Mat
// orthographicRh(w: f32, h: f32, near: f32, far: f32) Mat
// orthographicLhGl(w: f32, h: f32, near: f32, far: f32) Mat
// orthographicRhGl(w: f32, h: f32, near: f32, far: f32) Mat
// orthographicOffCenterLh(left: f32, right: f32, top: f32, bottom: f32, near: f32, far: f32) Mat
// orthographicOffCenterRh(left: f32, right: f32, top: f32, bottom: f32, near: f32, far: f32) Mat
// orthographicOffCenterLhGl(left: f32, right: f32, top: f32, bottom: f32, near: f32, far: f32) Mat
// orthographicOffCenterRhGl(left: f32, right: f32, top: f32, bottom: f32, near: f32, far: f32) Mat
// determinant(m: Mat)  vectors.F32x4
// inverse(m: Mat) Mat
// inverseDet(m: Mat, det: ?* vectors.F32x4) Mat
// matToQuat(m: Mat) Quat
// matFromAxisAngle(axis: vectors.Vec, angle: f32) Mat
// matFromNormAxisAngle(axis: vectors.Vec, angle: f32) Mat
// matFromQuat(quat: Quat) Mat
// matFromRollPitchYaw(pitch: f32, yaw: f32, roll: f32) Mat
// matFromRollPitchYawV(angles: vectors.Vec) Mat
// matFromArr(arr: [16]f32) Mat
//
// loadMat(mem: []const f32) Mat
// loadMat43(mem: []const f32) Mat
// loadMat34(mem: []const f32) Mat
// storeMat(mem: []f32, m: Mat) void
// storeMat43(mem: []f32, m: Mat) void
// storeMat34(mem: []f32, m: Mat) void
//
// matToArr(m: Mat) [16]f32
// matToArr43(m: Mat) [12]f32
// matToArr34(m: Mat) [12]f32
//
// ------------------------------------------------------------------------------
// 5. Quaternion functions
// ------------------------------------------------------------------------------
//
// qmul(q0: Quat, q1: Quat) Quat
// qidentity() Quat
// conjugate(quat: Quat) Quat
// inverse(q: Quat) Quat
// rotate(q: Quat, v: vectors.Vec) vectors.Vec
// slerp(q0: Quat, q1: Quat, t: f32) Quat
// slerpV(q0: Quat, q1: Quat, t:  vectors.F32x4) Quat
// quatToMat(quat: Quat) Mat
// quatToAxisAngle(quat: Quat, axis: *vectors.Vec, angle: *f32) void
// quatFromMat(m: Mat) Quat
// quatFromAxisAngle(axis: vectors.Vec, angle: f32) Quat
// quatFromNormAxisAngle(axis: vectors.Vec, angle: f32) Quat
// quatFromRollPitchYaw(pitch: f32, yaw: f32, roll: f32) Quat
// quatFromRollPitchYawV(angles: vectors.Vec) Quat
//
// ------------------------------------------------------------------------------
// 6. Color functions
// ------------------------------------------------------------------------------
//
// adjustSaturation(color:  vectors.F32x4, saturation: f32)  vectors.F32x4
// adjustContrast(color:  vectors.F32x4, contrast: f32)  vectors.F32x4
// rgbToHsl(rgb:  vectors.F32x4)  vectors.F32x4
// hslToRgb(hsl:  vectors.F32x4)  vectors.F32x4
// rgbToHsv(rgb:  vectors.F32x4)  vectors.F32x4
// hsvToRgb(hsv:  vectors.F32x4)  vectors.F32x4
// rgbToSrgb(rgb:  vectors.F32x4)  vectors.F32x4
// srgbToRgb(srgb:  vectors.F32x4)  vectors.F32x4
//
// ------------------------------------------------------------------------------
// X. Misc functions
// ------------------------------------------------------------------------------
//
// linePointDistance(linept0: vectors.Vec, linept1: vectors.Vec, pt: vectors.Vec)  vectors.F32x4
// sin(v: f32) f32
// cos(v: f32) f32
// sincos(v: f32) [2]f32
// asin(v: f32) f32
// acos(v: f32) f32
//
// fftInitUnityTable(unitytable: [] vectors.F32x4) void
// fft(re: [] vectors.F32x4, im: [] vectors.F32x4, unitytable: []const  vectors.F32x4) void
// ifft(re: [] vectors.F32x4, im: []const  vectors.F32x4, unitytable: []const  vectors.F32x4) void
//
// ==============================================================================

const builtin = @import("builtin");
const std = @import("std");

pub const vectors = @import("vectors.zig");

// "Higher-level" aliases
pub const Mat = [4]vectors.F32x4;
pub const Quat = vectors.F32x4;

const cpu_arch = builtin.cpu.arch;
const has_avx = if (cpu_arch == .x86_64) std.Target.x86.featureSetHas(builtin.cpu.features, .avx) else false;
const has_avx512f = if (cpu_arch == .x86_64) std.Target.x86.featureSetHas(builtin.cpu.features, .avx512f) else false;
const has_fma = if (cpu_arch == .x86_64) std.Target.x86.featureSetHas(builtin.cpu.features, .fma) else false;

pub inline fn arrNPtr(ptr: anytype) [*]const f32 {
    comptime std.debug.assert(@typeInfo(@TypeOf(ptr)) == .Pointer);
    const T = std.meta.Child(@TypeOf(ptr));
    comptime std.debug.assert(T == Mat or T == vectors.F32x4 or T == vectors.F32x8 or T == vectors.F32x16);
    return @as([*]const f32, @ptrCast(ptr));
}

// ------------------------------------------------------------------------------
//
// 2. Functions that work on all vector components (F32xN =  vectors.F32x4 or  vectors.F32x8 or  vectors.F32x16)
//
// ------------------------------------------------------------------------------
pub fn all(vb: anytype, comptime len: u32) bool {
    const T = @TypeOf(vb);
    if (len > vectors.veclen(T)) {
        @compileError("kmath.all(): 'len' is greater than vector len of type " ++ @typeName(T));
    }
    const loop_len = if (len == 0) vectors.veclen(T) else len;
    const ab: [vectors.veclen(T)]bool = vb;
    comptime var i: u32 = 0;
    var result = true;
    inline while (i < loop_len) : (i += 1) {
        result = result and ab[i];
    }
    return result;
}

pub fn any(vb: anytype, comptime len: u32) bool {
    const T = @TypeOf(vb);
    if (len > vectors.veclen(T)) {
        @compileError("kmath.any(): 'len' is greater than vector len of type " ++ @typeName(T));
    }
    const loop_len = if (len == 0) vectors.veclen(T) else len;
    const ab: [vectors.veclen(T)]bool = vb;
    comptime var i: u32 = 0;
    var result = false;
    inline while (i < loop_len) : (i += 1) {
        result = result or ab[i];
    }
    return result;
}
test "kmath.any" {
    try std.testing.expect(any(vectors.boolx8(true, true, true, true, true, false, true, false), 0) == true);
    try std.testing.expect(any(vectors.boolx8(false, false, false, true, true, false, true, false), 3) == false);
    try std.testing.expect(any(vectors.boolx8(false, false, false, false, false, true, false, false), 4) == false);
}

pub inline fn isNearEqual(
    v0: anytype,
    v1: anytype,
    epsilon: anytype,
) @Vector(vectors.veclen(@TypeOf(v0)), bool) {
    const T = @TypeOf(v0, v1, epsilon);
    const delta = v0 - v1;
    const temp = maxFast(delta, vectors.splat(T, 0.0) - delta);
    return temp <= epsilon;
}

pub inline fn isNan(
    v: anytype,
) @Vector(vectors.veclen(@TypeOf(v)), bool) {
    return v != v;
}
test "kmath.isNan" {
    {
        const v0 = vectors.f32x4(std.math.inf(f32), std.math.nan(f32), std.math.nan(f32), 7.0);
        const b = isNan(v0);
        try std.testing.expect(@reduce(.And, b == vectors.boolx4(false, true, true, false)));
    }
    {
        const v0 = vectors.f32x8(0, std.math.nan(f32), 0, 0, std.math.inf(f32), std.math.nan(f32), std.math.snan(f32), 7.0);
        const b = isNan(v0);
        try std.testing.expect(@reduce(.And, b == vectors.boolx8(false, true, false, false, false, true, true, false)));
    }
}

pub inline fn isInf(
    v: anytype,
) @Vector(vectors.veclen(@TypeOf(v)), bool) {
    const T = @TypeOf(v);
    return abs(v) == vectors.splat(T, std.math.inf(f32));
}

pub inline fn isInBounds(
    v: anytype,
    bounds: anytype,
) @Vector(vectors.veclen(@TypeOf(v)), bool) {
    const T = @TypeOf(v, bounds);
    const Tu = @Vector(vectors.veclen(T), u1);
    const Tr = @Vector(vectors.veclen(T), bool);

    // 2 x cmpleps, xorps, load, andps
    const b0 = v <= bounds;
    const b1 = (bounds * vectors.splat(T, -1.0)) <= v;
    const b0u = @as(Tu, @bitCast(b0));
    const b1u = @as(Tu, @bitCast(b1));
    return @as(Tr, @bitCast(b0u & b1u));
}

pub inline fn andInt(v0: anytype, v1: anytype) @TypeOf(v0, v1) {
    const T = @TypeOf(v0, v1);
    const Tu = @Vector(vectors.veclen(T), u32);
    const v0u = @as(Tu, @bitCast(v0));
    const v1u = @as(Tu, @bitCast(v1));
    return @as(T, @bitCast(v0u & v1u)); // andps
}

pub inline fn andNotInt(v0: anytype, v1: anytype) @TypeOf(v0, v1) {
    const T = @TypeOf(v0, v1);
    const Tu = @Vector(vectors.veclen(T), u32);
    const v0u = @as(Tu, @bitCast(v0));
    const v1u = @as(Tu, @bitCast(v1));
    return @as(T, @bitCast(~v0u & v1u)); // andnps
}

pub inline fn orInt(v0: anytype, v1: anytype) @TypeOf(v0, v1) {
    const T = @TypeOf(v0, v1);
    const Tu = @Vector(vectors.veclen(T), u32);
    const v0u = @as(Tu, @bitCast(v0));
    const v1u = @as(Tu, @bitCast(v1));
    return @as(T, @bitCast(v0u | v1u)); // orps
}

pub inline fn norInt(v0: anytype, v1: anytype) @TypeOf(v0, v1) {
    const T = @TypeOf(v0, v1);
    const Tu = @Vector(vectors.veclen(T), u32);
    const v0u = @as(Tu, @bitCast(v0));
    const v1u = @as(Tu, @bitCast(v1));
    return @as(T, @bitCast(~(v0u | v1u))); // por, pcmpeqd, pxor
}

pub inline fn xorInt(v0: anytype, v1: anytype) @TypeOf(v0, v1) {
    const T = @TypeOf(v0, v1);
    const Tu = @Vector(vectors.veclen(T), u32);
    const v0u = @as(Tu, @bitCast(v0));
    const v1u = @as(Tu, @bitCast(v1));
    return @as(T, @bitCast(v0u ^ v1u)); // xorps
}

pub inline fn minFast(v0: anytype, v1: anytype) @TypeOf(v0, v1) {
    return select(v0 < v1, v0, v1); // minps
}

pub inline fn maxFast(v0: anytype, v1: anytype) @TypeOf(v0, v1) {
    return select(v0 > v1, v0, v1); // maxps
}

pub inline fn min(v0: anytype, v1: anytype) @TypeOf(v0, v1) {
    // This will handle inf & nan
    return @min(v0, v1); // minps, cmpunordps, andps, andnps, orps
}

pub inline fn max(v0: anytype, v1: anytype) @TypeOf(v0, v1) {
    // This will handle inf & nan
    return @max(v0, v1); // maxps, cmpunordps, andps, andnps, orps
}

pub fn round(v: anytype) @TypeOf(v) {
    const T = @TypeOf(v);
    if (cpu_arch == .x86_64 and has_avx) {
        if (T == vectors.F32x4) {
            return asm ("vroundps $0, %%xmm0, %%xmm0"
                : [ret] "={xmm0}" (-> T),
                : [v] "{xmm0}" (v),
            );
        } else if (T == vectors.F32x8) {
            return asm ("vroundps $0, %%ymm0, %%ymm0"
                : [ret] "={ymm0}" (-> T),
                : [v] "{ymm0}" (v),
            );
        } else if (T == vectors.F32x16 and has_avx512f) {
            return asm ("vrndscaleps $0, %%zmm0, %%zmm0"
                : [ret] "={zmm0}" (-> T),
                : [v] "{zmm0}" (v),
            );
        } else if (T == vectors.F32x16 and !has_avx512f) {
            const arr: [16]f32 = v;
            var ymm0 = @as(vectors.F32x8, arr[0..8].*);
            var ymm1 = @as(vectors.F32x8, arr[8..16].*);
            ymm0 = asm ("vroundps $0, %%ymm0, %%ymm0"
                : [ret] "={ymm0}" (-> vectors.F32x8),
                : [v] "{ymm0}" (ymm0),
            );
            ymm1 = asm ("vroundps $0, %%ymm1, %%ymm1"
                : [ret] "={ymm1}" (-> vectors.F32x8),
                : [v] "{ymm1}" (ymm1),
            );
            return @shuffle(f32, ymm0, ymm1, [16]i32{ 0, 1, 2, 3, 4, 5, 6, 7, -1, -2, -3, -4, -5, -6, -7, -8 });
        }
    } else {
        const sign = andInt(v, splatNegativeZero(T));
        const magic = orInt(splatNoFraction(T), sign);
        var r1 = v + magic;
        r1 = r1 - magic;
        const r2 = abs(v);
        const mask = r2 <= splatNoFraction(T);
        return select(mask, r1, v);
    }
}

pub fn trunc(v: anytype) @TypeOf(v) {
    const T = @TypeOf(v);
    if (cpu_arch == .x86_64 and has_avx) {
        if (T == vectors.F32x4) {
            return asm ("vroundps $3, %%xmm0, %%xmm0"
                : [ret] "={xmm0}" (-> T),
                : [v] "{xmm0}" (v),
            );
        } else if (T == vectors.F32x8) {
            return asm ("vroundps $3, %%ymm0, %%ymm0"
                : [ret] "={ymm0}" (-> T),
                : [v] "{ymm0}" (v),
            );
        } else if (T == vectors.F32x16 and has_avx512f) {
            return asm ("vrndscaleps $3, %%zmm0, %%zmm0"
                : [ret] "={zmm0}" (-> T),
                : [v] "{zmm0}" (v),
            );
        } else if (T == vectors.F32x16 and !has_avx512f) {
            const arr: [16]f32 = v;
            var ymm0 = @as(vectors.F32x8, arr[0..8].*);
            var ymm1 = @as(vectors.F32x8, arr[8..16].*);
            ymm0 = asm ("vroundps $3, %%ymm0, %%ymm0"
                : [ret] "={ymm0}" (-> vectors.F32x8),
                : [v] "{ymm0}" (ymm0),
            );
            ymm1 = asm ("vroundps $3, %%ymm1, %%ymm1"
                : [ret] "={ymm1}" (-> vectors.F32x8),
                : [v] "{ymm1}" (ymm1),
            );
            return @shuffle(f32, ymm0, ymm1, [16]i32{ 0, 1, 2, 3, 4, 5, 6, 7, -1, -2, -3, -4, -5, -6, -7, -8 });
        }
    } else {
        const mask = abs(v) < splatNoFraction(T);
        const result = floatToIntAndBack(v);
        return select(mask, result, v);
    }
}

pub fn floor(v: anytype) @TypeOf(v) {
    const T = @TypeOf(v);
    if (cpu_arch == .x86_64 and has_avx) {
        if (T == vectors.F32x4) {
            return asm ("vroundps $1, %%xmm0, %%xmm0"
                : [ret] "={xmm0}" (-> T),
                : [v] "{xmm0}" (v),
            );
        } else if (T == vectors.F32x8) {
            return asm ("vroundps $1, %%ymm0, %%ymm0"
                : [ret] "={ymm0}" (-> T),
                : [v] "{ymm0}" (v),
            );
        } else if (T == vectors.F32x16 and has_avx512f) {
            return asm ("vrndscaleps $1, %%zmm0, %%zmm0"
                : [ret] "={zmm0}" (-> T),
                : [v] "{zmm0}" (v),
            );
        } else if (T == vectors.F32x16 and !has_avx512f) {
            const arr: [16]f32 = v;
            var ymm0 = @as(vectors.F32x8, arr[0..8].*);
            var ymm1 = @as(vectors.F32x8, arr[8..16].*);
            ymm0 = asm ("vroundps $1, %%ymm0, %%ymm0"
                : [ret] "={ymm0}" (-> vectors.F32x8),
                : [v] "{ymm0}" (ymm0),
            );
            ymm1 = asm ("vroundps $1, %%ymm1, %%ymm1"
                : [ret] "={ymm1}" (-> vectors.F32x8),
                : [v] "{ymm1}" (ymm1),
            );
            return @shuffle(f32, ymm0, ymm1, [16]i32{ 0, 1, 2, 3, 4, 5, 6, 7, -1, -2, -3, -4, -5, -6, -7, -8 });
        }
    } else {
        const mask = abs(v) < splatNoFraction(T);
        var result = floatToIntAndBack(v);
        const larger_mask = result > v;
        const larger = select(larger_mask, vectors.splat(T, -1.0), vectors.splat(T, 0.0));
        result = result + larger;
        return select(mask, result, v);
    }
}

pub fn ceil(v: anytype) @TypeOf(v) {
    const T = @TypeOf(v);
    if (cpu_arch == .x86_64 and has_avx) {
        if (T == vectors.F32x4) {
            return asm ("vroundps $2, %%xmm0, %%xmm0"
                : [ret] "={xmm0}" (-> T),
                : [v] "{xmm0}" (v),
            );
        } else if (T == vectors.F32x8) {
            return asm ("vroundps $2, %%ymm0, %%ymm0"
                : [ret] "={ymm0}" (-> T),
                : [v] "{ymm0}" (v),
            );
        } else if (T == vectors.F32x16 and has_avx512f) {
            return asm ("vrndscaleps $2, %%zmm0, %%zmm0"
                : [ret] "={zmm0}" (-> T),
                : [v] "{zmm0}" (v),
            );
        } else if (T == vectors.F32x16 and !has_avx512f) {
            const arr: [16]f32 = v;
            var ymm0 = @as(vectors.F32x8, arr[0..8].*);
            var ymm1 = @as(vectors.F32x8, arr[8..16].*);
            ymm0 = asm ("vroundps $2, %%ymm0, %%ymm0"
                : [ret] "={ymm0}" (-> vectors.F32x8),
                : [v] "{ymm0}" (ymm0),
            );
            ymm1 = asm ("vroundps $2, %%ymm1, %%ymm1"
                : [ret] "={ymm1}" (-> vectors.F32x8),
                : [v] "{ymm1}" (ymm1),
            );
            return @shuffle(f32, ymm0, ymm1, [16]i32{ 0, 1, 2, 3, 4, 5, 6, 7, -1, -2, -3, -4, -5, -6, -7, -8 });
        }
    } else {
        const mask = abs(v) < splatNoFraction(T);
        var result = floatToIntAndBack(v);
        const smaller_mask = result < v;
        const smaller = select(smaller_mask, vectors.splat(T, -1.0), vectors.splat(T, 0.0));
        result = result - smaller;
        return select(mask, result, v);
    }
}

pub inline fn clamp(v: anytype, vmin: anytype, vmax: anytype) @TypeOf(v, vmin, vmax) {
    var result = max(vmin, v);
    result = min(vmax, result);
    return result;
}

pub inline fn clampFast(v: anytype, vmin: anytype, vmax: anytype) @TypeOf(v, vmin, vmax) {
    var result = maxFast(vmin, v);
    result = minFast(vmax, result);
    return result;
}

pub inline fn saturate(v: anytype) @TypeOf(v) {
    const T = @TypeOf(v);
    var result = max(v, vectors.splat(T, 0.0));
    result = min(result, vectors.splat(T, 1.0));
    return result;
}

pub inline fn saturateFast(v: anytype) @TypeOf(v) {
    const T = @TypeOf(v);
    var result = maxFast(v, vectors.splat(T, 0.0));
    result = minFast(result, vectors.splat(T, 1.0));
    return result;
}

pub inline fn sqrt(v: anytype) @TypeOf(v) {
    return @sqrt(v); // sqrtps
}

pub inline fn abs(v: anytype) @TypeOf(v) {
    return @abs(v); // load, andps
}

pub inline fn select(mask: anytype, v0: anytype, v1: anytype) @TypeOf(v0, v1) {
    return @select(f32, mask, v0, v1);
}

pub inline fn lerp(v0: anytype, v1: anytype, t: f32) @TypeOf(v0, v1) {
    const T = @TypeOf(v0, v1);
    return v0 + (v1 - v0) * vectors.splat(T, t); // subps, shufps, addps, mulps
}

pub inline fn lerpV(v0: anytype, v1: anytype, t: anytype) @TypeOf(v0, v1, t) {
    return v0 + (v1 - v0) * t; // subps, addps, mulps
}

pub inline fn lerpInverse(v0: anytype, v1: anytype, t: anytype) @TypeOf(v0, v1) {
    const T = @TypeOf(v0, v1);
    return (vectors.splat(T, t) - v0) / (v1 - v0);
}

pub inline fn lerpInverseV(v0: anytype, v1: anytype, t: anytype) @TypeOf(v0, v1, t) {
    return (t - v0) / (v1 - v0);
}

// Frame rate independent lerp (or "damp"), for approaching things over time.
// Reference: https://www.gamedeveloper.com/programming/improved-lerp-smoothing-
pub inline fn lerpOverTime(v0: anytype, v1: anytype, rate: anytype, dt: anytype) @TypeOf(v0, v1) {
    const t = std.math.exp2(-rate * dt);
    return lerp(v0, v1, t);
}

pub inline fn lerpVOverTime(v0: anytype, v1: anytype, rate: anytype, dt: anytype) @TypeOf(v0, v1, rate, dt) {
    const t = std.math.exp2(-rate * dt);
    return lerpV(v0, v1, t);
}

/// To transform a vector of values from one range to another.
pub inline fn mapLinear(v: anytype, min1: anytype, max1: anytype, min2: anytype, max2: anytype) @TypeOf(v) {
    const T = @TypeOf(v);
    const min1V = vectors.splat(T, min1);
    const max1V = vectors.splat(T, max1);
    const min2V = vectors.splat(T, min2);
    const max2V = vectors.splat(T, max2);
    const dV = max1V - min1V;
    return min2V + (v - min1V) * (max2V - min2V) / dV;
}

pub inline fn mapLinearV(v: anytype, min1: anytype, max1: anytype, min2: anytype, max2: anytype) @TypeOf(v, min1, max1, min2, max2) {
    const d = max1 - min1;
    return min2 + (v - min1) * (max2 - min2) / d;
}

pub inline fn swizzle(
    v: vectors.F32x4,
    comptime x: vectors.F32x4Component,
    comptime y: vectors.F32x4Component,
    comptime z: vectors.F32x4Component,
    comptime w: vectors.F32x4Component,
) vectors.F32x4 {
    return @shuffle(f32, v, undefined, [4]i32{ @intFromEnum(x), @intFromEnum(y), @intFromEnum(z), @intFromEnum(w) });
}

pub inline fn mod(v0: anytype, v1: anytype) @TypeOf(v0, v1) {
    // vdivps, vroundps, vmulps, vsubps
    return v0 - v1 * trunc(v0 / v1);
}

pub fn modAngle(v: anytype) @TypeOf(v) {
    const T = @TypeOf(v);
    return switch (T) {
        f32 => modAngle32(v),
        vectors.F32x4, vectors.F32x8, vectors.F32x16 => modAngle32xN(v),
        else => @compileError("kmath.modAngle() not implemented for " ++ @typeName(T)),
    };
}

pub inline fn modAngle32xN(v: anytype) @TypeOf(v) {
    const T = @TypeOf(v);
    return v - vectors.splat(T, std.math.tau) * round(v * vectors.splat(T, 1.0 / std.math.tau)); // 2 x vmulps, 2 x load, vroundps, vaddps
}

pub inline fn mulAdd(v0: anytype, v1: anytype, v2: anytype) @TypeOf(v0, v1, v2) {
    const T = @TypeOf(v0, v1, v2);
    if (@import("kmath_options").enable_cross_platform_determinism) {
        return v0 * v1 + v2; // Compiler will generate mul, add sequence (no fma even if the target supports it).
    } else {
        if (cpu_arch == .x86_64 and has_avx and has_fma) {
            return @mulAdd(T, v0, v1, v2);
        } else {
            // NOTE(mziulek): On .x86_64 without HW fma instructions @mulAdd maps to really slow code!
            return v0 * v1 + v2;
        }
    }
}

fn sin32xN(v: anytype) @TypeOf(v) {
    // 11-degree minimax approximation
    const T = @TypeOf(v);

    var x = modAngle(v);
    const sign = andInt(x, splatNegativeZero(T));
    const c = orInt(sign, vectors.splat(T, std.math.pi));
    const absx = andNotInt(sign, x);
    const rflx = c - x;
    const comp = absx <= vectors.splat(T, 0.5 * std.math.pi);
    x = select(comp, x, rflx);
    const x2 = x * x;

    var result = mulAdd(vectors.splat(T, -2.3889859e-08), x2, vectors.splat(T, 2.7525562e-06));
    result = mulAdd(result, x2, vectors.splat(T, -0.00019840874));
    result = mulAdd(result, x2, vectors.splat(T, 0.0083333310));
    result = mulAdd(result, x2, vectors.splat(T, -0.16666667));
    result = mulAdd(result, x2, vectors.splat(T, 1.0));
    return x * result;
}

fn cos32xN(v: anytype) @TypeOf(v) {
    // 10-degree minimax approximation
    const T = @TypeOf(v);

    var x = modAngle(v);
    var sign = andInt(x, splatNegativeZero(T));
    const c = orInt(sign, vectors.splat(T, std.math.pi));
    const absx = andNotInt(sign, x);
    const rflx = c - x;
    const comp = absx <= vectors.splat(T, 0.5 * std.math.pi);
    x = select(comp, x, rflx);
    sign = select(comp, vectors.splat(T, 1.0), vectors.splat(T, -1.0));
    const x2 = x * x;

    var result = mulAdd(vectors.splat(T, -2.6051615e-07), x2, vectors.splat(T, 2.4760495e-05));
    result = mulAdd(result, x2, vectors.splat(T, -0.0013888378));
    result = mulAdd(result, x2, vectors.splat(T, 0.041666638));
    result = mulAdd(result, x2, vectors.splat(T, -0.5));
    result = mulAdd(result, x2, vectors.splat(T, 1.0));
    return sign * result;
}

pub fn sin(v: anytype) @TypeOf(v) {
    const T = @TypeOf(v);
    return switch (T) {
        f32 => sin32(v),
        vectors.F32x4, vectors.F32x8, vectors.F32x16 => sin32xN(v),
        else => @compileError("kmath.sin() not implemented for " ++ @typeName(T)),
    };
}

pub fn cos(v: anytype) @TypeOf(v) {
    const T = @TypeOf(v);
    return switch (T) {
        f32 => cos32(v),
        vectors.F32x4, vectors.F32x8, vectors.F32x16 => cos32xN(v),
        else => @compileError("kmath.cos() not implemented for " ++ @typeName(T)),
    };
}

pub fn sincos(v: anytype) [2]@TypeOf(v) {
    const T = @TypeOf(v);
    return switch (T) {
        f32 => sincos32(v),
        vectors.F32x4, vectors.F32x8, vectors.F32x16 => sincos32xN(v),
        else => @compileError("kmath.sincos() not implemented for " ++ @typeName(T)),
    };
}

pub fn asin(v: anytype) @TypeOf(v) {
    const T = @TypeOf(v);
    return switch (T) {
        f32 => asin32(v),
        vectors.F32x4, vectors.F32x8, vectors.F32x16 => asin32xN(v),
        else => @compileError("kmath.asin() not implemented for " ++ @typeName(T)),
    };
}

pub fn acos(v: anytype) @TypeOf(v) {
    const T = @TypeOf(v);
    return switch (T) {
        f32 => acos32(v),
        vectors.F32x4, vectors.F32x8, vectors.F32x16 => acos32xN(v),
        else => @compileError("kmath.acos() not implemented for " ++ @typeName(T)),
    };
}

fn sincos32xN(v: anytype) [2]@TypeOf(v) {
    const T = @TypeOf(v);

    var x = modAngle(v);
    var sign = andInt(x, splatNegativeZero(T));
    const c = orInt(sign, vectors.splat(T, std.math.pi));
    const absx = andNotInt(sign, x);
    const rflx = c - x;
    const comp = absx <= vectors.splat(T, 0.5 * std.math.pi);
    x = select(comp, x, rflx);
    sign = select(comp, vectors.splat(T, 1.0), vectors.splat(T, -1.0));
    const x2 = x * x;

    var sresult = mulAdd(vectors.splat(T, -2.3889859e-08), x2, vectors.splat(T, 2.7525562e-06));
    sresult = mulAdd(sresult, x2, vectors.splat(T, -0.00019840874));
    sresult = mulAdd(sresult, x2, vectors.splat(T, 0.0083333310));
    sresult = mulAdd(sresult, x2, vectors.splat(T, -0.16666667));
    sresult = x * mulAdd(sresult, x2, vectors.splat(T, 1.0));

    var cresult = mulAdd(vectors.splat(T, -2.6051615e-07), x2, vectors.splat(T, 2.4760495e-05));
    cresult = mulAdd(cresult, x2, vectors.splat(T, -0.0013888378));
    cresult = mulAdd(cresult, x2, vectors.splat(T, 0.041666638));
    cresult = mulAdd(cresult, x2, vectors.splat(T, -0.5));
    cresult = sign * mulAdd(cresult, x2, vectors.splat(T, 1.0));

    return .{ sresult, cresult };
}

fn asin32xN(v: anytype) @TypeOf(v) {
    // 7-degree minimax approximation
    const T = @TypeOf(v);

    const x = abs(v);
    const root = sqrt(maxFast(vectors.splat(T, 0.0), vectors.splat(T, 1.0) - x));

    var t0 = mulAdd(vectors.splat(T, -0.0012624911), x, vectors.splat(T, 0.0066700901));
    t0 = mulAdd(t0, x, vectors.splat(T, -0.0170881256));
    t0 = mulAdd(t0, x, vectors.splat(T, 0.0308918810));
    t0 = mulAdd(t0, x, vectors.splat(T, -0.0501743046));
    t0 = mulAdd(t0, x, vectors.splat(T, 0.0889789874));
    t0 = mulAdd(t0, x, vectors.splat(T, -0.2145988016));
    t0 = root * mulAdd(t0, x, vectors.splat(T, 1.5707963050));

    const t1 = vectors.splat(T, std.math.pi) - t0;
    return vectors.splat(T, 0.5 * std.math.pi) - select(v >= vectors.splat(T, 0.0), t0, t1);
}

fn acos32xN(v: anytype) @TypeOf(v) {
    // 7-degree minimax approximation
    const T = @TypeOf(v);

    const x = abs(v);
    const root = sqrt(maxFast(vectors.splat(T, 0.0), vectors.splat(T, 1.0) - x));

    var t0 = mulAdd(vectors.splat(T, -0.0012624911), x, vectors.splat(T, 0.0066700901));
    t0 = mulAdd(t0, x, vectors.splat(T, -0.0170881256));
    t0 = mulAdd(t0, x, vectors.splat(T, 0.0308918810));
    t0 = mulAdd(t0, x, vectors.splat(T, -0.0501743046));
    t0 = mulAdd(t0, x, vectors.splat(T, 0.0889789874));
    t0 = mulAdd(t0, x, vectors.splat(T, -0.2145988016));
    t0 = root * mulAdd(t0, x, vectors.splat(T, 1.5707963050));

    const t1 = vectors.splat(T, std.math.pi) - t0;
    return select(v >= vectors.splat(T, 0.0), t0, t1);
}

pub fn atan(v: anytype) @TypeOf(v) {
    // 17-degree minimax approximation
    const T = @TypeOf(v);

    const vabs = abs(v);
    const vinv = vectors.splat(T, 1.0) / v;
    var sign = select(v > vectors.splat(T, 1.0), vectors.splat(T, 1.0), vectors.splat(T, -1.0));
    const comp = vabs <= vectors.splat(T, 1.0);
    sign = select(comp, vectors.splat(T, 0.0), sign);
    const x = select(comp, v, vinv);
    const x2 = x * x;

    var result = mulAdd(vectors.splat(T, 0.0028662257), x2, vectors.splat(T, -0.0161657367));
    result = mulAdd(result, x2, vectors.splat(T, 0.0429096138));
    result = mulAdd(result, x2, vectors.splat(T, -0.0752896400));
    result = mulAdd(result, x2, vectors.splat(T, 0.1065626393));
    result = mulAdd(result, x2, vectors.splat(T, -0.1420889944));
    result = mulAdd(result, x2, vectors.splat(T, 0.1999355085));
    result = mulAdd(result, x2, vectors.splat(T, -0.3333314528));
    result = x * mulAdd(result, x2, vectors.splat(T, 1.0));

    const result1 = sign * vectors.splat(T, 0.5 * std.math.pi) - result;
    return select(sign == vectors.splat(T, 0.0), result, result1);
}

pub fn atan2(vy: anytype, vx: anytype) @TypeOf(vx, vy) {
    const T = @TypeOf(vx, vy);
    const Tu = @Vector(vectors.veclen(T), u32);

    const vx_is_positive =
        (@as(Tu, @bitCast(vx)) & @as(Tu, @splat(0x8000_0000))) == @as(Tu, @splat(0));

    const vy_sign = andInt(vy, splatNegativeZero(T));
    const c0_25pi = orInt(vy_sign, @as(T, @splat(0.25 * std.math.pi)));
    const c0_50pi = orInt(vy_sign, @as(T, @splat(0.50 * std.math.pi)));
    const c0_75pi = orInt(vy_sign, @as(T, @splat(0.75 * std.math.pi)));
    const c1_00pi = orInt(vy_sign, @as(T, @splat(1.00 * std.math.pi)));

    var r1 = select(vx_is_positive, vy_sign, c1_00pi);
    var r2 = select(vx == vectors.splat(T, 0.0), c0_50pi, vectors.splatInt(T, 0xffff_ffff));
    const r3 = select(vy == vectors.splat(T, 0.0), r1, r2);
    const r4 = select(vx_is_positive, c0_25pi, c0_75pi);
    const r5 = select(isInf(vx), r4, c0_50pi);
    const result = select(isInf(vy), r5, r3);
    const result_valid = @as(Tu, @bitCast(result)) == @as(Tu, @splat(0xffff_ffff));

    const v = vy / vx;
    const r0 = atan(v);

    r1 = select(vx_is_positive, splatNegativeZero(T), c1_00pi);
    r2 = r0 + r1;

    return select(result_valid, r2, result);
}

// ------------------------------------------------------------------------------
//
// 3. 2D, 3D, 4D vector functions
//
// ------------------------------------------------------------------------------
pub inline fn dot2(v0: vectors.Vec, v1: vectors.Vec) vectors.F32x4 {
    var xmm0 = v0 * v1; // | x0*x1 | y0*y1 | -- | -- |
    const xmm1 = swizzle(xmm0, .y, .x, .x, .x); // | y0*y1 | -- | -- | -- |
    xmm0 = vectors.f32x4(xmm0[0] + xmm1[0], xmm0[1], xmm0[2], xmm0[3]); // | x0*x1 + y0*y1 | -- | -- | -- |
    return swizzle(xmm0, .x, .x, .x, .x);
}

pub inline fn dot3(v0: vectors.Vec, v1: vectors.Vec) vectors.F32x4 {
    const dot = v0 * v1;
    return vectors.f32x4s(dot[0] + dot[1] + dot[2]);
}

pub inline fn dot4(v0: vectors.Vec, v1: vectors.Vec) vectors.F32x4 {
    var xmm0 = v0 * v1; // | x0*x1 | y0*y1 | z0*z1 | w0*w1 |
    var xmm1 = swizzle(xmm0, .y, .x, .w, .x); // | y0*y1 | -- | w0*w1 | -- |
    xmm1 = xmm0 + xmm1; // | x0*x1 + y0*y1 | -- | z0*z1 + w0*w1 | -- |
    xmm0 = swizzle(xmm1, .z, .x, .x, .x); // | z0*z1 + w0*w1 | -- | -- | -- |
    xmm0 = vectors.f32x4(xmm0[0] + xmm1[0], xmm0[1], xmm0[2], xmm0[2]); // addss
    return swizzle(xmm0, .x, .x, .x, .x);
}

pub inline fn cross3(v0: vectors.Vec, v1: vectors.Vec) vectors.Vec {
    var xmm0 = swizzle(v0, .y, .z, .x, .w);
    var xmm1 = swizzle(v1, .z, .x, .y, .w);
    var result = xmm0 * xmm1;
    xmm0 = swizzle(xmm0, .y, .z, .x, .w);
    xmm1 = swizzle(xmm1, .z, .x, .y, .w);
    result = result - xmm0 * xmm1;
    return andInt(result, f32x4_mask3);
}

pub inline fn lengthSq2(v: vectors.Vec) vectors.F32x4 {
    return dot2(v, v);
}
pub inline fn lengthSq3(v: vectors.Vec) vectors.F32x4 {
    return dot3(v, v);
}
pub inline fn lengthSq4(v: vectors.Vec) vectors.F32x4 {
    return dot4(v, v);
}

pub inline fn length2(v: vectors.Vec) vectors.F32x4 {
    return sqrt(dot2(v, v));
}
pub inline fn length3(v: vectors.Vec) vectors.F32x4 {
    return sqrt(dot3(v, v));
}
pub inline fn length4(v: vectors.Vec) vectors.F32x4 {
    return sqrt(dot4(v, v));
}

pub inline fn normalize2(v: vectors.Vec) vectors.Vec {
    return v * vectors.splat(vectors.F32x4, 1.0) / sqrt(dot2(v, v));
}
pub inline fn normalize3(v: vectors.Vec) vectors.Vec {
    return v * vectors.splat(vectors.F32x4, 1.0) / sqrt(dot3(v, v));
}
pub inline fn normalize4(v: vectors.Vec) vectors.Vec {
    return v * vectors.splat(vectors.F32x4, 1.0) / sqrt(dot4(v, v));
}

fn vecMulMat(v: vectors.Vec, m: Mat) vectors.Vec {
    const vx = @shuffle(f32, v, undefined, [4]i32{ 0, 0, 0, 0 });
    const vy = @shuffle(f32, v, undefined, [4]i32{ 1, 1, 1, 1 });
    const vz = @shuffle(f32, v, undefined, [4]i32{ 2, 2, 2, 2 });
    const vw = @shuffle(f32, v, undefined, [4]i32{ 3, 3, 3, 3 });
    return vx * m[0] + vy * m[1] + vz * m[2] + vw * m[3];
}
fn matMulVec(m: Mat, v: vectors.Vec) vectors.Vec {
    return .{ dot4(m[0], v)[0], dot4(m[1], v)[0], dot4(m[2], v)[0], dot4(m[3], v)[0] };
}

// ------------------------------------------------------------------------------
//
// 4. Matrix functions
//
// ------------------------------------------------------------------------------
pub fn identity() Mat {
    const static = struct {
        const identity = Mat{
            vectors.f32x4(1.0, 0.0, 0.0, 0.0),
            vectors.f32x4(0.0, 1.0, 0.0, 0.0),
            vectors.f32x4(0.0, 0.0, 1.0, 0.0),
            vectors.f32x4(0.0, 0.0, 0.0, 1.0),
        };
    };
    return static.identity;
}

pub fn matFromArr(arr: [16]f32) Mat {
    return Mat{
        vectors.f32x4(arr[0], arr[1], arr[2], arr[3]),
        vectors.f32x4(arr[4], arr[5], arr[6], arr[7]),
        vectors.f32x4(arr[8], arr[9], arr[10], arr[11]),
        vectors.f32x4(arr[12], arr[13], arr[14], arr[15]),
    };
}

fn mulRetType(comptime Ta: type, comptime Tb: type) type {
    if (Ta == Mat and Tb == Mat) {
        return Mat;
    } else if ((Ta == f32 and Tb == Mat) or (Ta == Mat and Tb == f32)) {
        return Mat;
    } else if ((Ta == vectors.Vec and Tb == Mat) or (Ta == Mat and Tb == vectors.Vec)) {
        return vectors.Vec;
    }
    @compileError("kmath.mul() not implemented for types: " ++ @typeName(Ta) ++ @typeName(Tb));
}

pub fn mul(a: anytype, b: anytype) mulRetType(@TypeOf(a), @TypeOf(b)) {
    const Ta = @TypeOf(a);
    const Tb = @TypeOf(b);
    if (Ta == Mat and Tb == Mat) {
        return mulMat(a, b);
    } else if (Ta == f32 and Tb == Mat) {
        const va = vectors.splat(vectors.F32x4, a);
        return Mat{ va * b[0], va * b[1], va * b[2], va * b[3] };
    } else if (Ta == Mat and Tb == f32) {
        const vb = vectors.splat(vectors.F32x4, b);
        return Mat{ a[0] * vb, a[1] * vb, a[2] * vb, a[3] * vb };
    } else if (Ta == vectors.Vec and Tb == Mat) {
        return vecMulMat(a, b);
    } else if (Ta == Mat and Tb == vectors.Vec) {
        return matMulVec(a, b);
    } else {
        @compileError("kmath.mul() not implemented for types: " ++ @typeName(Ta) ++ ", " ++ @typeName(Tb));
    }
}

fn mulMat(m0: Mat, m1: Mat) Mat {
    var result: Mat = undefined;
    comptime var row: u32 = 0;
    inline while (row < 4) : (row += 1) {
        const vx = swizzle(m0[row], .x, .x, .x, .x);
        const vy = swizzle(m0[row], .y, .y, .y, .y);
        const vz = swizzle(m0[row], .z, .z, .z, .z);
        const vw = swizzle(m0[row], .w, .w, .w, .w);
        result[row] = mulAdd(vx, m1[0], vz * m1[2]) + mulAdd(vy, m1[1], vw * m1[3]);
    }
    return result;
}

pub fn transpose(m: Mat) Mat {
    const temp1 = @shuffle(f32, m[0], m[1], [4]i32{ 0, 1, ~@as(i32, 0), ~@as(i32, 1) });
    const temp3 = @shuffle(f32, m[0], m[1], [4]i32{ 2, 3, ~@as(i32, 2), ~@as(i32, 3) });
    const temp2 = @shuffle(f32, m[2], m[3], [4]i32{ 0, 1, ~@as(i32, 0), ~@as(i32, 1) });
    const temp4 = @shuffle(f32, m[2], m[3], [4]i32{ 2, 3, ~@as(i32, 2), ~@as(i32, 3) });
    return .{
        @shuffle(f32, temp1, temp2, [4]i32{ 0, 2, ~@as(i32, 0), ~@as(i32, 2) }),
        @shuffle(f32, temp1, temp2, [4]i32{ 1, 3, ~@as(i32, 1), ~@as(i32, 3) }),
        @shuffle(f32, temp3, temp4, [4]i32{ 0, 2, ~@as(i32, 0), ~@as(i32, 2) }),
        @shuffle(f32, temp3, temp4, [4]i32{ 1, 3, ~@as(i32, 1), ~@as(i32, 3) }),
    };
}

pub fn rotationX(angle: f32) Mat {
    const sc = sincos(angle);
    return .{
        vectors.f32x4(1.0, 0.0, 0.0, 0.0),
        vectors.f32x4(0.0, sc[1], sc[0], 0.0),
        vectors.f32x4(0.0, -sc[0], sc[1], 0.0),
        vectors.f32x4(0.0, 0.0, 0.0, 1.0),
    };
}

pub fn rotationY(angle: f32) Mat {
    const sc = sincos(angle);
    return .{
        vectors.f32x4(sc[1], 0.0, -sc[0], 0.0),
        vectors.f32x4(0.0, 1.0, 0.0, 0.0),
        vectors.f32x4(sc[0], 0.0, sc[1], 0.0),
        vectors.f32x4(0.0, 0.0, 0.0, 1.0),
    };
}

pub fn rotationZ(angle: f32) Mat {
    const sc = sincos(angle);
    return .{
        vectors.f32x4(sc[1], sc[0], 0.0, 0.0),
        vectors.f32x4(-sc[0], sc[1], 0.0, 0.0),
        vectors.f32x4(0.0, 0.0, 1.0, 0.0),
        vectors.f32x4(0.0, 0.0, 0.0, 1.0),
    };
}

pub fn translation(x: f32, y: f32, z: f32) Mat {
    return .{
        vectors.f32x4(1.0, 0.0, 0.0, 0.0),
        vectors.f32x4(0.0, 1.0, 0.0, 0.0),
        vectors.f32x4(0.0, 0.0, 1.0, 0.0),
        vectors.f32x4(x, y, z, 1.0),
    };
}
pub fn translationV(v: vectors.Vec) Mat {
    return translation(v[0], v[1], v[2]);
}

pub fn scaling(x: f32, y: f32, z: f32) Mat {
    return .{
        vectors.f32x4(x, 0.0, 0.0, 0.0),
        vectors.f32x4(0.0, y, 0.0, 0.0),
        vectors.f32x4(0.0, 0.0, z, 0.0),
        vectors.f32x4(0.0, 0.0, 0.0, 1.0),
    };
}
pub fn scalingV(v: vectors.Vec) Mat {
    return scaling(v[0], v[1], v[2]);
}

pub fn lookToLh(eyepos: vectors.Vec, eyedir: vectors.Vec, updir: vectors.Vec) Mat {
    const az = normalize3(eyedir);
    const ax = normalize3(cross3(updir, az));
    const ay = normalize3(cross3(az, ax));
    return .{
        vectors.f32x4(ax[0], ay[0], az[0], 0),
        vectors.f32x4(ax[1], ay[1], az[1], 0),
        vectors.f32x4(ax[2], ay[2], az[2], 0),
        vectors.f32x4(-dot3(ax, eyepos)[0], -dot3(ay, eyepos)[0], -dot3(az, eyepos)[0], 1.0),
    };
}
pub fn lookToRh(eyepos: vectors.Vec, eyedir: vectors.Vec, updir: vectors.Vec) Mat {
    return lookToLh(eyepos, -eyedir, updir);
}
pub fn lookAtLh(eyepos: vectors.Vec, focuspos: vectors.Vec, updir: vectors.Vec) Mat {
    return lookToLh(eyepos, focuspos - eyepos, updir);
}
pub fn lookAtRh(eyepos: vectors.Vec, focuspos: vectors.Vec, updir: vectors.Vec) Mat {
    return lookToLh(eyepos, eyepos - focuspos, updir);
}
test "kmath.matrix.lookToLh" {
    const m = lookToLh(vectors.f32x4(0.0, 0.0, -3.0, 1.0), vectors.f32x4(0.0, 0.0, 1.0, 0.0), vectors.f32x4(0.0, 1.0, 0.0, 0.0));
    try expectVecApproxEqAbs(m[0], vectors.f32x4(1.0, 0.0, 0.0, 0.0), 0.001);
    try expectVecApproxEqAbs(m[1], vectors.f32x4(0.0, 1.0, 0.0, 0.0), 0.001);
    try expectVecApproxEqAbs(m[2], vectors.f32x4(0.0, 0.0, 1.0, 0.0), 0.001);
    try expectVecApproxEqAbs(m[3], vectors.f32x4(0.0, 0.0, 3.0, 1.0), 0.001);
}

pub fn perspectiveFovLh(fovy: f32, aspect: f32, near: f32, far: f32) Mat {
    const scfov = sincos(0.5 * fovy);

    std.debug.assert(near > 0.0 and far > 0.0);
    std.debug.assert(!std.math.approxEqAbs(f32, scfov[0], 0.0, 0.001));
    std.debug.assert(!std.math.approxEqAbs(f32, far, near, 0.001));
    std.debug.assert(!std.math.approxEqAbs(f32, aspect, 0.0, 0.01));

    const h = scfov[1] / scfov[0];
    const w = h / aspect;
    const r = far / (far - near);
    return .{
        vectors.f32x4(w, 0.0, 0.0, 0.0),
        vectors.f32x4(0.0, h, 0.0, 0.0),
        vectors.f32x4(0.0, 0.0, r, 1.0),
        vectors.f32x4(0.0, 0.0, -r * near, 0.0),
    };
}
pub fn perspectiveFovRh(fovy: f32, aspect: f32, near: f32, far: f32) Mat {
    const scfov = sincos(0.5 * fovy);

    std.debug.assert(near > 0.0 and far > 0.0);
    std.debug.assert(!std.math.approxEqAbs(f32, scfov[0], 0.0, 0.001));
    std.debug.assert(!std.math.approxEqAbs(f32, far, near, 0.001));
    std.debug.assert(!std.math.approxEqAbs(f32, aspect, 0.0, 0.01));

    const h = scfov[1] / scfov[0];
    const w = h / aspect;
    const r = far / (near - far);
    return .{
        vectors.f32x4(w, 0.0, 0.0, 0.0),
        vectors.f32x4(0.0, h, 0.0, 0.0),
        vectors.f32x4(0.0, 0.0, r, -1.0),
        vectors.f32x4(0.0, 0.0, r * near, 0.0),
    };
}

// Produces Z values in [-1.0, 1.0] range (OpenGL defaults)
pub fn perspectiveFovLhGl(fovy: f32, aspect: f32, near: f32, far: f32) Mat {
    const scfov = sincos(0.5 * fovy);

    std.debug.assert(near > 0.0 and far > 0.0);
    std.debug.assert(!std.math.approxEqAbs(f32, scfov[0], 0.0, 0.001));
    std.debug.assert(!std.math.approxEqAbs(f32, far, near, 0.001));
    std.debug.assert(!std.math.approxEqAbs(f32, aspect, 0.0, 0.01));

    const h = scfov[1] / scfov[0];
    const w = h / aspect;
    const r = far - near;
    return .{
        vectors.f32x4(w, 0.0, 0.0, 0.0),
        vectors.f32x4(0.0, h, 0.0, 0.0),
        vectors.f32x4(0.0, 0.0, (near + far) / r, 1.0),
        vectors.f32x4(0.0, 0.0, 2.0 * near * far / -r, 0.0),
    };
}

// Produces Z values in [-1.0, 1.0] range (OpenGL defaults)
pub fn perspectiveFovRhGl(fovy: f32, aspect: f32, near: f32, far: f32) Mat {
    const scfov = sincos(0.5 * fovy);

    std.debug.assert(near > 0.0 and far > 0.0);
    std.debug.assert(!std.math.approxEqAbs(f32, scfov[0], 0.0, 0.001));
    std.debug.assert(!std.math.approxEqAbs(f32, far, near, 0.001));
    std.debug.assert(!std.math.approxEqAbs(f32, aspect, 0.0, 0.01));

    const h = scfov[1] / scfov[0];
    const w = h / aspect;
    const r = near - far;
    return .{
        vectors.f32x4(w, 0.0, 0.0, 0.0),
        vectors.f32x4(0.0, h, 0.0, 0.0),
        vectors.f32x4(0.0, 0.0, (near + far) / r, -1.0),
        vectors.f32x4(0.0, 0.0, 2.0 * near * far / r, 0.0),
    };
}

pub fn orthographicLh(w: f32, h: f32, near: f32, far: f32) Mat {
    std.debug.assert(!std.math.approxEqAbs(f32, w, 0.0, 0.001));
    std.debug.assert(!std.math.approxEqAbs(f32, h, 0.0, 0.001));
    std.debug.assert(!std.math.approxEqAbs(f32, far, near, 0.001));

    const r = 1 / (far - near);
    return .{
        vectors.f32x4(2 / w, 0.0, 0.0, 0.0),
        vectors.f32x4(0.0, 2 / h, 0.0, 0.0),
        vectors.f32x4(0.0, 0.0, r, 0.0),
        vectors.f32x4(0.0, 0.0, -r * near, 1.0),
    };
}

pub fn orthographicRh(w: f32, h: f32, near: f32, far: f32) Mat {
    std.debug.assert(!std.math.approxEqAbs(f32, w, 0.0, 0.001));
    std.debug.assert(!std.math.approxEqAbs(f32, h, 0.0, 0.001));
    std.debug.assert(!std.math.approxEqAbs(f32, far, near, 0.001));

    const r = 1 / (near - far);
    return .{
        vectors.f32x4(2 / w, 0.0, 0.0, 0.0),
        vectors.f32x4(0.0, 2 / h, 0.0, 0.0),
        vectors.f32x4(0.0, 0.0, r, 0.0),
        vectors.f32x4(0.0, 0.0, r * near, 1.0),
    };
}

// Produces Z values in [-1.0, 1.0] range (OpenGL defaults)
pub fn orthographicLhGl(w: f32, h: f32, near: f32, far: f32) Mat {
    std.debug.assert(!std.math.approxEqAbs(f32, w, 0.0, 0.001));
    std.debug.assert(!std.math.approxEqAbs(f32, h, 0.0, 0.001));
    std.debug.assert(!std.math.approxEqAbs(f32, far, near, 0.001));

    const r = far - near;
    return .{
        vectors.f32x4(2 / w, 0.0, 0.0, 0.0),
        vectors.f32x4(0.0, 2 / h, 0.0, 0.0),
        vectors.f32x4(0.0, 0.0, 2 / r, 0.0),
        vectors.f32x4(0.0, 0.0, (near + far) / -r, 1.0),
    };
}

// Produces Z values in [-1.0, 1.0] range (OpenGL defaults)
pub fn orthographicRhGl(w: f32, h: f32, near: f32, far: f32) Mat {
    std.debug.assert(!std.math.approxEqAbs(f32, w, 0.0, 0.001));
    std.debug.assert(!std.math.approxEqAbs(f32, h, 0.0, 0.001));
    std.debug.assert(!std.math.approxEqAbs(f32, far, near, 0.001));

    const r = near - far;
    return .{
        vectors.f32x4(2 / w, 0.0, 0.0, 0.0),
        vectors.f32x4(0.0, 2 / h, 0.0, 0.0),
        vectors.f32x4(0.0, 0.0, 2 / r, 0.0),
        vectors.f32x4(0.0, 0.0, (near + far) / r, 1.0),
    };
}

pub fn orthographicOffCenterLh(left: f32, right: f32, top: f32, bottom: f32, near: f32, far: f32) Mat {
    std.debug.assert(!std.math.approxEqAbs(f32, far, near, 0.001));

    const r = 1 / (far - near);
    return .{
        vectors.f32x4(2 / (right - left), 0.0, 0.0, 0.0),
        vectors.f32x4(0.0, 2 / (top - bottom), 0.0, 0.0),
        vectors.f32x4(0.0, 0.0, r, 0.0),
        vectors.f32x4(-(right + left) / (right - left), -(top + bottom) / (top - bottom), -r * near, 1.0),
    };
}

pub fn orthographicOffCenterRh(left: f32, right: f32, top: f32, bottom: f32, near: f32, far: f32) Mat {
    std.debug.assert(!std.math.approxEqAbs(f32, far, near, 0.001));

    const r = 1 / (near - far);
    return .{
        vectors.f32x4(2 / (right - left), 0.0, 0.0, 0.0),
        vectors.f32x4(0.0, 2 / (top - bottom), 0.0, 0.0),
        vectors.f32x4(0.0, 0.0, r, 0.0),
        vectors.f32x4(-(right + left) / (right - left), -(top + bottom) / (top - bottom), r * near, 1.0),
    };
}

// Produces Z values in [-1.0, 1.0] range (OpenGL defaults)
pub fn orthographicOffCenterLhGl(left: f32, right: f32, top: f32, bottom: f32, near: f32, far: f32) Mat {
    std.debug.assert(!std.math.approxEqAbs(f32, far, near, 0.001));

    const r = far - near;
    return .{
        vectors.f32x4(2 / (right - left), 0.0, 0.0, 0.0),
        vectors.f32x4(0.0, 2 / (top - bottom), 0.0, 0.0),
        vectors.f32x4(0.0, 0.0, 2 / r, 0.0),
        vectors.f32x4(-(right + left) / (right - left), -(top + bottom) / (top - bottom), (near + far) / -r, 1.0),
    };
}

// Produces Z values in [-1.0, 1.0] range (OpenGL defaults)
pub fn orthographicOffCenterRhGl(left: f32, right: f32, top: f32, bottom: f32, near: f32, far: f32) Mat {
    std.debug.assert(!std.math.approxEqAbs(f32, far, near, 0.001));

    const r = near - far;
    return .{
        vectors.f32x4(2 / (right - left), 0.0, 0.0, 0.0),
        vectors.f32x4(0.0, 2 / (top - bottom), 0.0, 0.0),
        vectors.f32x4(0.0, 0.0, 2 / r, 0.0),
        vectors.f32x4(-(right + left) / (right - left), -(top + bottom) / (top - bottom), (near + far) / r, 1.0),
    };
}

pub fn determinant(m: Mat) vectors.F32x4 {
    var v0 = swizzle(m[2], .y, .x, .x, .x);
    var v1 = swizzle(m[3], .z, .z, .y, .y);
    var v2 = swizzle(m[2], .y, .x, .x, .x);
    var v3 = swizzle(m[3], .w, .w, .w, .z);
    var v4 = swizzle(m[2], .z, .z, .y, .y);
    var v5 = swizzle(m[3], .w, .w, .w, .z);

    var p0 = v0 * v1;
    var p1 = v2 * v3;
    var p2 = v4 * v5;

    v0 = swizzle(m[2], .z, .z, .y, .y);
    v1 = swizzle(m[3], .y, .x, .x, .x);
    v2 = swizzle(m[2], .w, .w, .w, .z);
    v3 = swizzle(m[3], .y, .x, .x, .x);
    v4 = swizzle(m[2], .w, .w, .w, .z);
    v5 = swizzle(m[3], .z, .z, .y, .y);

    p0 = mulAdd(-v0, v1, p0);
    p1 = mulAdd(-v2, v3, p1);
    p2 = mulAdd(-v4, v5, p2);

    v0 = swizzle(m[1], .w, .w, .w, .z);
    v1 = swizzle(m[1], .z, .z, .y, .y);
    v2 = swizzle(m[1], .y, .x, .x, .x);

    const s = m[0] * vectors.f32x4(1.0, -1.0, 1.0, -1.0);
    var r = v0 * p0;
    r = mulAdd(-v1, p1, r);
    r = mulAdd(v2, p2, r);
    return dot4(s, r);
}

pub fn inverse(a: anytype) @TypeOf(a) {
    const T = @TypeOf(a);
    return switch (T) {
        Mat => inverseMat(a),
        Quat => inverseQuat(a),
        else => @compileError("kmath.inverse() not implemented for " ++ @typeName(T)),
    };
}

fn inverseMat(m: Mat) Mat {
    return inverseDet(m, null);
}

pub fn inverseDet(m: Mat, out_det: ?*vectors.F32x4) Mat {
    const mt = transpose(m);
    var v0: [4]vectors.F32x4 = undefined;
    var v1: [4]vectors.F32x4 = undefined;

    v0[0] = swizzle(mt[2], .x, .x, .y, .y);
    v1[0] = swizzle(mt[3], .z, .w, .z, .w);
    v0[1] = swizzle(mt[0], .x, .x, .y, .y);
    v1[1] = swizzle(mt[1], .z, .w, .z, .w);
    v0[2] = @shuffle(f32, mt[2], mt[0], [4]i32{ 0, 2, ~@as(i32, 0), ~@as(i32, 2) });
    v1[2] = @shuffle(f32, mt[3], mt[1], [4]i32{ 1, 3, ~@as(i32, 1), ~@as(i32, 3) });

    var d0 = v0[0] * v1[0];
    var d1 = v0[1] * v1[1];
    var d2 = v0[2] * v1[2];

    v0[0] = swizzle(mt[2], .z, .w, .z, .w);
    v1[0] = swizzle(mt[3], .x, .x, .y, .y);
    v0[1] = swizzle(mt[0], .z, .w, .z, .w);
    v1[1] = swizzle(mt[1], .x, .x, .y, .y);
    v0[2] = @shuffle(f32, mt[2], mt[0], [4]i32{ 1, 3, ~@as(i32, 1), ~@as(i32, 3) });
    v1[2] = @shuffle(f32, mt[3], mt[1], [4]i32{ 0, 2, ~@as(i32, 0), ~@as(i32, 2) });

    d0 = mulAdd(-v0[0], v1[0], d0);
    d1 = mulAdd(-v0[1], v1[1], d1);
    d2 = mulAdd(-v0[2], v1[2], d2);

    v0[0] = swizzle(mt[1], .y, .z, .x, .y);
    v1[0] = @shuffle(f32, d0, d2, [4]i32{ ~@as(i32, 1), 1, 3, 0 });
    v0[1] = swizzle(mt[0], .z, .x, .y, .x);
    v1[1] = @shuffle(f32, d0, d2, [4]i32{ 3, ~@as(i32, 1), 1, 2 });
    v0[2] = swizzle(mt[3], .y, .z, .x, .y);
    v1[2] = @shuffle(f32, d1, d2, [4]i32{ ~@as(i32, 3), 1, 3, 0 });
    v0[3] = swizzle(mt[2], .z, .x, .y, .x);
    v1[3] = @shuffle(f32, d1, d2, [4]i32{ 3, ~@as(i32, 3), 1, 2 });

    var c0 = v0[0] * v1[0];
    var c2 = v0[1] * v1[1];
    var c4 = v0[2] * v1[2];
    var c6 = v0[3] * v1[3];

    v0[0] = swizzle(mt[1], .z, .w, .y, .z);
    v1[0] = @shuffle(f32, d0, d2, [4]i32{ 3, 0, 1, ~@as(i32, 0) });
    v0[1] = swizzle(mt[0], .w, .z, .w, .y);
    v1[1] = @shuffle(f32, d0, d2, [4]i32{ 2, 1, ~@as(i32, 0), 0 });
    v0[2] = swizzle(mt[3], .z, .w, .y, .z);
    v1[2] = @shuffle(f32, d1, d2, [4]i32{ 3, 0, 1, ~@as(i32, 2) });
    v0[3] = swizzle(mt[2], .w, .z, .w, .y);
    v1[3] = @shuffle(f32, d1, d2, [4]i32{ 2, 1, ~@as(i32, 2), 0 });

    c0 = mulAdd(-v0[0], v1[0], c0);
    c2 = mulAdd(-v0[1], v1[1], c2);
    c4 = mulAdd(-v0[2], v1[2], c4);
    c6 = mulAdd(-v0[3], v1[3], c6);

    v0[0] = swizzle(mt[1], .w, .x, .w, .x);
    v1[0] = @shuffle(f32, d0, d2, [4]i32{ 2, ~@as(i32, 1), ~@as(i32, 0), 2 });
    v0[1] = swizzle(mt[0], .y, .w, .x, .z);
    v1[1] = @shuffle(f32, d0, d2, [4]i32{ ~@as(i32, 1), 0, 3, ~@as(i32, 0) });
    v0[2] = swizzle(mt[3], .w, .x, .w, .x);
    v1[2] = @shuffle(f32, d1, d2, [4]i32{ 2, ~@as(i32, 3), ~@as(i32, 2), 2 });
    v0[3] = swizzle(mt[2], .y, .w, .x, .z);
    v1[3] = @shuffle(f32, d1, d2, [4]i32{ ~@as(i32, 3), 0, 3, ~@as(i32, 2) });

    const c1 = mulAdd(-v0[0], v1[0], c0);
    const c3 = mulAdd(v0[1], v1[1], c2);
    const c5 = mulAdd(-v0[2], v1[2], c4);
    const c7 = mulAdd(v0[3], v1[3], c6);

    c0 = mulAdd(v0[0], v1[0], c0);
    c2 = mulAdd(-v0[1], v1[1], c2);
    c4 = mulAdd(v0[2], v1[2], c4);
    c6 = mulAdd(-v0[3], v1[3], c6);

    var mr = Mat{
        vectors.f32x4(c0[0], c1[1], c0[2], c1[3]),
        vectors.f32x4(c2[0], c3[1], c2[2], c3[3]),
        vectors.f32x4(c4[0], c5[1], c4[2], c5[3]),
        vectors.f32x4(c6[0], c7[1], c6[2], c7[3]),
    };

    const det = dot4(mr[0], mt[0]);
    if (out_det != null) {
        out_det.?.* = det;
    }

    if (std.math.approxEqAbs(f32, det[0], 0.0, std.math.floatEps(f32))) {
        return .{
            vectors.f32x4(0.0, 0.0, 0.0, 0.0),
            vectors.f32x4(0.0, 0.0, 0.0, 0.0),
            vectors.f32x4(0.0, 0.0, 0.0, 0.0),
            vectors.f32x4(0.0, 0.0, 0.0, 0.0),
        };
    }

    const scale = vectors.splat(vectors.F32x4, 1.0) / det;
    mr[0] *= scale;
    mr[1] *= scale;
    mr[2] *= scale;
    mr[3] *= scale;
    return mr;
}

pub fn matFromNormAxisAngle(axis: vectors.Vec, angle: f32) Mat {
    const sincos_angle = sincos(angle);

    const c2 = vectors.splat(vectors.F32x4, 1.0 - sincos_angle[1]);
    const c1 = vectors.splat(vectors.F32x4, sincos_angle[1]);
    const c0 = vectors.splat(vectors.F32x4, sincos_angle[0]);

    const n0 = swizzle(axis, .y, .z, .x, .w);
    const n1 = swizzle(axis, .z, .x, .y, .w);

    var v0 = c2 * n0 * n1;
    const r0 = c2 * axis * axis + c1;
    const r1 = c0 * axis + v0;
    var r2 = v0 - c0 * axis;

    v0 = andInt(r0, f32x4_mask3);

    var v1 = @shuffle(f32, r1, r2, [4]i32{ 0, 2, ~@as(i32, 1), ~@as(i32, 2) });
    v1 = swizzle(v1, .y, .z, .w, .x);

    var v2 = @shuffle(f32, r1, r2, [4]i32{ 1, 1, ~@as(i32, 0), ~@as(i32, 0) });
    v2 = swizzle(v2, .x, .z, .x, .z);

    r2 = @shuffle(f32, v0, v1, [4]i32{ 0, 3, ~@as(i32, 0), ~@as(i32, 1) });
    r2 = swizzle(r2, .x, .z, .w, .y);

    var m: Mat = undefined;
    m[0] = r2;

    r2 = @shuffle(f32, v0, v1, [4]i32{ 1, 3, ~@as(i32, 2), ~@as(i32, 3) });
    r2 = swizzle(r2, .z, .x, .w, .y);
    m[1] = r2;

    v2 = @shuffle(f32, v2, v0, [4]i32{ 0, 1, ~@as(i32, 2), ~@as(i32, 3) });
    m[2] = v2;
    m[3] = vectors.f32x4(0.0, 0.0, 0.0, 1.0);
    return m;
}
pub fn matFromAxisAngle(axis: vectors.Vec, angle: f32) Mat {
    std.debug.assert(!all(axis == vectors.splat(vectors.F32x4, 0.0), 3));
    std.debug.assert(!all(isInf(axis), 3));
    const normal = normalize3(axis);
    return matFromNormAxisAngle(normal, angle);
}

pub fn matFromQuat(quat: Quat) Mat {
    const q0 = quat + quat;
    var q1 = quat * q0;

    var v0 = swizzle(q1, .y, .x, .x, .w);
    v0 = andInt(v0, f32x4_mask3);

    var v1 = swizzle(q1, .z, .z, .y, .w);
    v1 = andInt(v1, f32x4_mask3);

    const r0 = (vectors.f32x4(1.0, 1.0, 1.0, 0.0) - v0) - v1;

    v0 = swizzle(quat, .x, .x, .y, .w);
    v1 = swizzle(q0, .z, .y, .z, .w);
    v0 = v0 * v1;

    v1 = swizzle(quat, .w, .w, .w, .w);
    const v2 = swizzle(q0, .y, .z, .x, .w);
    v1 = v1 * v2;

    const r1 = v0 + v1;
    const r2 = v0 - v1;

    v0 = @shuffle(f32, r1, r2, [4]i32{ 1, 2, ~@as(i32, 0), ~@as(i32, 1) });
    v0 = swizzle(v0, .x, .z, .w, .y);
    v1 = @shuffle(f32, r1, r2, [4]i32{ 0, 0, ~@as(i32, 2), ~@as(i32, 2) });
    v1 = swizzle(v1, .x, .z, .x, .z);

    q1 = @shuffle(f32, r0, v0, [4]i32{ 0, 3, ~@as(i32, 0), ~@as(i32, 1) });
    q1 = swizzle(q1, .x, .z, .w, .y);

    var m: Mat = undefined;
    m[0] = q1;

    q1 = @shuffle(f32, r0, v0, [4]i32{ 1, 3, ~@as(i32, 2), ~@as(i32, 3) });
    q1 = swizzle(q1, .z, .x, .w, .y);
    m[1] = q1;

    q1 = @shuffle(f32, v1, r0, [4]i32{ 0, 1, ~@as(i32, 2), ~@as(i32, 3) });
    m[2] = q1;
    m[3] = vectors.f32x4(0.0, 0.0, 0.0, 1.0);
    return m;
}

pub fn matFromRollPitchYaw(pitch: f32, yaw: f32, roll: f32) Mat {
    return matFromRollPitchYawV(vectors.f32x4(pitch, yaw, roll, 0.0));
}
pub fn matFromRollPitchYawV(angles: vectors.Vec) Mat {
    return matFromQuat(quatFromRollPitchYawV(angles));
}

pub fn matToQuat(m: Mat) Quat {
    return quatFromMat(m);
}

pub inline fn loadMat(mem: []const f32) Mat {
    return .{
        vectors.load(mem[0..4], vectors.F32x4, 0),
        vectors.load(mem[4..8], vectors.F32x4, 0),
        vectors.load(mem[8..12], vectors.F32x4, 0),
        vectors.load(mem[12..16], vectors.F32x4, 0),
    };
}

pub inline fn storeMat(mem: []f32, m: Mat) void {
    vectors.store(mem[0..4], m[0], 0);
    vectors.store(mem[4..8], m[1], 0);
    vectors.store(mem[8..12], m[2], 0);
    vectors.store(mem[12..16], m[3], 0);
}

pub inline fn loadMat43(mem: []const f32) Mat {
    return .{
        vectors.f32x4(mem[0], mem[1], mem[2], 0.0),
        vectors.f32x4(mem[3], mem[4], mem[5], 0.0),
        vectors.f32x4(mem[6], mem[7], mem[8], 0.0),
        vectors.f32x4(mem[9], mem[10], mem[11], 1.0),
    };
}

pub inline fn storeMat43(mem: []f32, m: Mat) void {
    vectors.store(mem[0..3], m[0], 3);
    vectors.store(mem[3..6], m[1], 3);
    vectors.store(mem[6..9], m[2], 3);
    vectors.store(mem[9..12], m[3], 3);
}

pub inline fn loadMat34(mem: []const f32) Mat {
    return .{
        vectors.load(mem[0..4], vectors.F32x4, 0),
        vectors.load(mem[4..8], vectors.F32x4, 0),
        vectors.load(mem[8..12], vectors.F32x4, 0),
        vectors.f32x4(0.0, 0.0, 0.0, 1.0),
    };
}

pub inline fn storeMat34(mem: []f32, m: Mat) void {
    vectors.store(mem[0..4], m[0], 0);
    vectors.store(mem[4..8], m[1], 0);
    vectors.store(mem[8..12], m[2], 0);
}

pub inline fn matToArr(m: Mat) [16]f32 {
    var array: [16]f32 = undefined;
    storeMat(array[0..], m);
    return array;
}

pub inline fn matToArr43(m: Mat) [12]f32 {
    var array: [12]f32 = undefined;
    storeMat43(array[0..], m);
    return array;
}

pub inline fn matToArr34(m: Mat) [12]f32 {
    var array: [12]f32 = undefined;
    storeMat34(array[0..], m);
    return array;
}
// ------------------------------------------------------------------------------
//
// 5. Quaternion functions
//
// ------------------------------------------------------------------------------
pub fn qmul(q0: Quat, q1: Quat) Quat {
    var result = swizzle(q1, .w, .w, .w, .w);
    var q1x = swizzle(q1, .x, .x, .x, .x);
    var q1y = swizzle(q1, .y, .y, .y, .y);
    var q1z = swizzle(q1, .z, .z, .z, .z);
    result = result * q0;
    var q0_shuf = swizzle(q0, .w, .z, .y, .x);
    q1x = q1x * q0_shuf;
    q0_shuf = swizzle(q0_shuf, .y, .x, .w, .z);
    result = mulAdd(q1x, vectors.f32x4(1.0, -1.0, 1.0, -1.0), result);
    q1y = q1y * q0_shuf;
    q0_shuf = swizzle(q0_shuf, .w, .z, .y, .x);
    q1y = q1y * vectors.f32x4(1.0, 1.0, -1.0, -1.0);
    q1z = q1z * q0_shuf;
    q1y = mulAdd(q1z, vectors.f32x4(-1.0, 1.0, 1.0, -1.0), q1y);
    return result + q1y;
}

pub fn quatToMat(quat: Quat) Mat {
    return matFromQuat(quat);
}

pub fn quatToAxisAngle(quat: Quat, axis: *vectors.Vec, angle: *f32) void {
    axis.* = quat;
    angle.* = 2.0 * acos(quat[3]);
}

pub fn quatFromMat(m: Mat) Quat {
    const r0 = m[0];
    const r1 = m[1];
    const r2 = m[2];
    const r00 = swizzle(r0, .x, .x, .x, .x);
    const r11 = swizzle(r1, .y, .y, .y, .y);
    const r22 = swizzle(r2, .z, .z, .z, .z);

    const x2gey2 = (r11 - r00) <= vectors.splat(vectors.F32x4, 0.0);
    const z2gew2 = (r11 + r00) <= vectors.splat(vectors.F32x4, 0.0);
    const x2py2gez2pw2 = r22 <= vectors.splat(vectors.F32x4, 0.0);

    var t0 = mulAdd(r00, vectors.f32x4(1.0, -1.0, -1.0, 1.0), vectors.splat(vectors.F32x4, 1.0));
    var t1 = r11 * vectors.f32x4(-1.0, 1.0, -1.0, 1.0);
    var t2 = mulAdd(r22, vectors.f32x4(-1.0, -1.0, 1.0, 1.0), t0);
    const x2y2z2w2 = t1 + t2;

    t0 = @shuffle(f32, r0, r1, [4]i32{ 1, 2, ~@as(i32, 2), ~@as(i32, 1) });
    t1 = @shuffle(f32, r1, r2, [4]i32{ 0, 0, ~@as(i32, 0), ~@as(i32, 1) });
    t1 = swizzle(t1, .x, .z, .w, .y);
    const xyxzyz = t0 + t1;

    t0 = @shuffle(f32, r2, r1, [4]i32{ 1, 0, ~@as(i32, 0), ~@as(i32, 0) });
    t1 = @shuffle(f32, r1, r0, [4]i32{ 2, 2, ~@as(i32, 2), ~@as(i32, 1) });
    t1 = swizzle(t1, .x, .z, .w, .y);
    const xwywzw = (t0 - t1) * vectors.f32x4(-1.0, 1.0, -1.0, 1.0);

    t0 = @shuffle(f32, x2y2z2w2, xyxzyz, [4]i32{ 0, 1, ~@as(i32, 0), ~@as(i32, 0) });
    t1 = @shuffle(f32, x2y2z2w2, xwywzw, [4]i32{ 2, 3, ~@as(i32, 2), ~@as(i32, 0) });
    t2 = @shuffle(f32, xyxzyz, xwywzw, [4]i32{ 1, 2, ~@as(i32, 0), ~@as(i32, 1) });

    const tensor0 = @shuffle(f32, t0, t2, [4]i32{ 0, 2, ~@as(i32, 0), ~@as(i32, 2) });
    const tensor1 = @shuffle(f32, t0, t2, [4]i32{ 2, 1, ~@as(i32, 1), ~@as(i32, 3) });
    const tensor2 = @shuffle(f32, t2, t1, [4]i32{ 0, 1, ~@as(i32, 0), ~@as(i32, 2) });
    const tensor3 = @shuffle(f32, t2, t1, [4]i32{ 2, 3, ~@as(i32, 2), ~@as(i32, 1) });

    t0 = select(x2gey2, tensor0, tensor1);
    t1 = select(z2gew2, tensor2, tensor3);
    t2 = select(x2py2gez2pw2, t0, t1);

    return t2 / length4(t2);
}

pub fn quatFromNormAxisAngle(axis: vectors.Vec, angle: f32) Quat {
    const n = vectors.f32x4(axis[0], axis[1], axis[2], 1.0);
    const sc = sincos(0.5 * angle);
    return n * vectors.f32x4(sc[0], sc[0], sc[0], sc[1]);
}
pub fn quatFromAxisAngle(axis: vectors.Vec, angle: f32) Quat {
    std.debug.assert(!all(axis == vectors.splat(vectors.F32x4, 0.0), 3));
    std.debug.assert(!all(isInf(axis), 3));
    const normal = normalize3(axis);
    return quatFromNormAxisAngle(normal, angle);
}

pub inline fn qidentity() Quat {
    return vectors.f32x4(@as(f32, 0.0), @as(f32, 0.0), @as(f32, 0.0), @as(f32, 1.0));
}

pub inline fn conjugate(quat: Quat) Quat {
    return quat * vectors.f32x4(-1.0, -1.0, -1.0, 1.0);
}

fn inverseQuat(quat: Quat) Quat {
    const l = lengthSq4(quat);
    const conj = conjugate(quat);
    return select(l <= vectors.splat(vectors.F32x4, std.math.floatEps(f32)), vectors.splat(vectors.F32x4, 0.0), conj / l);
}

// Algorithm from: https://github.com/g-truc/glm/blob/master/glm/detail/type_quat.inl
pub fn rotate(q: Quat, v: vectors.Vec) vectors.Vec {
    const w = vectors.splat(vectors.F32x4, q[3]);
    const axis = vectors.f32x4(q[0], q[1], q[2], 0.0);
    const uv = cross3(axis, v);
    return v + ((uv * w) + cross3(axis, uv)) * vectors.splat(vectors.F32x4, 2.0);
}

pub fn slerp(q0: Quat, q1: Quat, t: f32) Quat {
    return slerpV(q0, q1, vectors.splat(vectors.F32x4, t));
}
pub fn slerpV(q0: Quat, q1: Quat, t: vectors.F32x4) Quat {
    var cos_omega = dot4(q0, q1);
    const sign = select(cos_omega < vectors.splat(vectors.F32x4, 0.0), vectors.splat(vectors.F32x4, -1.0), vectors.splat(vectors.F32x4, 1.0));

    cos_omega = cos_omega * sign;
    const sin_omega = sqrt(vectors.splat(vectors.F32x4, 1.0) - cos_omega * cos_omega);

    const omega = atan2(sin_omega, cos_omega);

    var v01 = t;
    v01 = xorInt(andInt(v01, f32x4_mask2), f32x4_sign_mask1);
    v01 = vectors.f32x4(1.0, 0.0, 0.0, 0.0) + v01;

    var s0 = sin(v01 * omega) / sin_omega;
    s0 = select(cos_omega < vectors.splat(vectors.F32x4, 1.0 - 0.00001), s0, v01);

    const s1 = swizzle(s0, .y, .y, .y, .y);
    s0 = swizzle(s0, .x, .x, .x, .x);

    return q0 * s0 + sign * q1 * s1;
}
test "kmath.quaternion.slerp" {
    const from = vectors.f32x4(0.0, 0.0, 0.0, 1.0);
    const to = vectors.f32x4(0.5, 0.5, -0.5, 0.5);
    const result = slerp(from, to, 0.5);
    try expectVecApproxEqAbs(result, vectors.f32x4(0.28867513, 0.28867513, -0.28867513, 0.86602540), 0.0001);
}

// Converts q back to euler angles, assuming a YXZ rotation order.
// See: http://www.euclideanspace.com/maths/geometry/rotations/conversions/quaternionToEuler
pub fn quatToRollPitchYaw(q: Quat) [3]f32 {
    var angles: [3]f32 = undefined;

    const p = swizzle(q, .w, .y, .x, .z);
    const sign = -1.0;

    const singularity = p[0] * p[2] + sign * p[1] * p[3];
    if (singularity > 0.499) {
        angles[0] = std.math.pi * 0.5;
        angles[1] = 2.0 * std.math.atan2(p[1], p[0]);
        angles[2] = 0.0;
    } else if (singularity < -0.499) {
        angles[0] = -std.math.pi * 0.5;
        angles[1] = 2.0 * std.math.atan2(p[1], p[0]);
        angles[2] = 0.0;
    } else {
        const sq = p * p;
        const y = vectors.splat(vectors.F32x4, 2.0) * vectors.f32x4(p[0] * p[1] - sign * p[2] * p[3], p[0] * p[3] - sign * p[1] * p[2], 0.0, 0.0);
        const x = vectors.splat(vectors.F32x4, 1.0) - (vectors.splat(vectors.F32x4, 2.0) * vectors.f32x4(sq[1] + sq[2], sq[2] + sq[3], 0.0, 0.0));
        const res = atan2(y, x);
        angles[0] = std.math.asin(2.0 * singularity);
        angles[1] = res[0];
        angles[2] = res[1];
    }

    return angles;
}

pub fn quatFromRollPitchYaw(pitch: f32, yaw: f32, roll: f32) Quat {
    return quatFromRollPitchYawV(vectors.f32x4(pitch, yaw, roll, 0.0));
}
pub fn quatFromRollPitchYawV(angles: vectors.Vec) Quat { // | pitch | yaw | roll | 0 |
    const sc = sincos(vectors.splat(vectors.Vec, 0.5) * angles);
    const p0 = @shuffle(f32, sc[1], sc[0], [4]i32{ ~@as(i32, 0), 0, 0, 0 });
    const p1 = @shuffle(f32, sc[0], sc[1], [4]i32{ ~@as(i32, 0), 0, 0, 0 });
    const y0 = @shuffle(f32, sc[1], sc[0], [4]i32{ 1, ~@as(i32, 1), 1, 1 });
    const y1 = @shuffle(f32, sc[0], sc[1], [4]i32{ 1, ~@as(i32, 1), 1, 1 });
    const r0 = @shuffle(f32, sc[1], sc[0], [4]i32{ 2, 2, ~@as(i32, 2), 2 });
    const r1 = @shuffle(f32, sc[0], sc[1], [4]i32{ 2, 2, ~@as(i32, 2), 2 });
    const q1 = p1 * vectors.f32x4(1.0, -1.0, -1.0, 1.0) * y1;
    const q0 = p0 * y0 * r0;
    return mulAdd(q1, r1, q0);
}

// ------------------------------------------------------------------------------
//
// 6. Color functions
//
// ------------------------------------------------------------------------------
pub fn adjustSaturation(color: vectors.F32x4, saturation: f32) vectors.F32x4 {
    const luminance = dot3(vectors.f32x4(0.2125, 0.7154, 0.0721, 0.0), color);
    var result = mulAdd(color - luminance, vectors.f32x4s(saturation), luminance);
    result[3] = color[3];
    return result;
}

pub fn adjustContrast(color: vectors.F32x4, contrast: f32) vectors.F32x4 {
    var result = mulAdd(color - vectors.f32x4s(0.5), vectors.f32x4s(contrast), vectors.f32x4s(0.5));
    result[3] = color[3];
    return result;
}

pub fn rgbToHsl(rgb: vectors.F32x4) vectors.F32x4 {
    const r = swizzle(rgb, .x, .x, .x, .x);
    const g = swizzle(rgb, .y, .y, .y, .y);
    const b = swizzle(rgb, .z, .z, .z, .z);

    const minv = min(r, min(g, b));
    const maxv = max(r, max(g, b));

    const l = (minv + maxv) * vectors.f32x4s(0.5);
    const d = maxv - minv;
    const la = select(vectors.boolx4(true, true, true, false), l, rgb);

    if (all(d < vectors.f32x4s(std.math.floatEps(f32)), 3)) {
        return select(vectors.boolx4(true, true, false, false), vectors.f32x4s(0.0), la);
    } else {
        var s: vectors.F32x4 = undefined;
        var h: vectors.F32x4 = undefined;

        const d2 = minv + maxv;

        if (all(l > vectors.f32x4s(0.5), 3)) {
            s = d / (vectors.f32x4s(2.0) - d2);
        } else {
            s = d / d2;
        }

        if (all(r == maxv, 3)) {
            h = (g - b) / d;
        } else if (all(g == maxv, 3)) {
            h = vectors.f32x4s(2.0) + (b - r) / d;
        } else {
            h = vectors.f32x4s(4.0) + (r - g) / d;
        }

        h /= vectors.f32x4s(6.0);

        if (all(h < vectors.f32x4s(0.0), 3)) {
            h += vectors.f32x4s(1.0);
        }

        const lha = select(vectors.boolx4(true, true, false, false), h, la);
        return select(vectors.boolx4(true, false, true, true), lha, s);
    }
}

fn hueToClr(p: vectors.F32x4, q: vectors.F32x4, h: vectors.F32x4) vectors.F32x4 {
    var t = h;

    if (all(t < vectors.f32x4s(0.0), 3))
        t += vectors.f32x4s(1.0);

    if (all(t > vectors.f32x4s(1.0), 3))
        t -= vectors.f32x4s(1.0);

    if (all(t < vectors.f32x4s(1.0 / 6.0), 3))
        return mulAdd(q - p, vectors.f32x4s(6.0) * t, p);

    if (all(t < vectors.f32x4s(0.5), 3))
        return q;

    if (all(t < vectors.f32x4s(2.0 / 3.0), 3))
        return mulAdd(q - p, vectors.f32x4s(6.0) * (vectors.f32x4s(2.0 / 3.0) - t), p);

    return p;
}

pub fn hslToRgb(hsl: vectors.F32x4) vectors.F32x4 {
    const s = swizzle(hsl, .y, .y, .y, .y);
    const l = swizzle(hsl, .z, .z, .z, .z);

    if (all(isNearEqual(s, vectors.f32x4s(0.0), vectors.f32x4s(std.math.floatEps(f32))), 3)) {
        return select(vectors.boolx4(true, true, true, false), l, hsl);
    } else {
        const h = swizzle(hsl, .x, .x, .x, .x);
        var q: vectors.F32x4 = undefined;
        if (all(l < vectors.f32x4s(0.5), 3)) {
            q = l * (vectors.f32x4s(1.0) + s);
        } else {
            q = (l + s) - (l * s);
        }

        const p = vectors.f32x4s(2.0) * l - q;

        const r = hueToClr(p, q, h + vectors.f32x4s(1.0 / 3.0));
        const g = hueToClr(p, q, h);
        const b = hueToClr(p, q, h - vectors.f32x4s(1.0 / 3.0));

        const rg = select(vectors.boolx4(true, false, false, false), r, g);
        const ba = select(vectors.boolx4(true, true, true, false), b, hsl);
        return select(vectors.boolx4(true, true, false, false), rg, ba);
    }
}

pub fn rgbToHsv(rgb: vectors.F32x4) vectors.F32x4 {
    const r = swizzle(rgb, .x, .x, .x, .x);
    const g = swizzle(rgb, .y, .y, .y, .y);
    const b = swizzle(rgb, .z, .z, .z, .z);

    const minv = min(r, min(g, b));
    const v = max(r, max(g, b));
    const d = v - minv;
    const s = if (all(isNearEqual(v, vectors.f32x4s(0.0), vectors.f32x4s(std.math.floatEps(f32))), 3)) vectors.f32x4s(0.0) else d / v;

    if (all(d < vectors.f32x4s(std.math.floatEps(f32)), 3)) {
        const hv = select(vectors.boolx4(true, false, false, false), vectors.f32x4s(0.0), v);
        const hva = select(vectors.boolx4(true, true, true, false), hv, rgb);
        return select(vectors.boolx4(true, false, true, true), hva, s);
    } else {
        var h: vectors.F32x4 = undefined;
        if (all(r == v, 3)) {
            h = (g - b) / d;
            if (all(g < b, 3))
                h += vectors.f32x4s(6.0);
        } else if (all(g == v, 3)) {
            h = vectors.f32x4s(2.0) + (b - r) / d;
        } else {
            h = vectors.f32x4s(4.0) + (r - g) / d;
        }

        h /= vectors.f32x4s(6.0);
        const hv = select(vectors.boolx4(true, false, false, false), h, v);
        const hva = select(vectors.boolx4(true, true, true, false), hv, rgb);
        return select(vectors.boolx4(true, false, true, true), hva, s);
    }
}

pub fn hsvToRgb(hsv: vectors.F32x4) vectors.F32x4 {
    const h = swizzle(hsv, .x, .x, .x, .x);
    const s = swizzle(hsv, .y, .y, .y, .y);
    const v = swizzle(hsv, .z, .z, .z, .z);

    const h6 = h * vectors.f32x4s(6.0);
    const i = floor(h6);
    const f = h6 - i;

    const p = v * (vectors.f32x4s(1.0) - s);
    const q = v * (vectors.f32x4s(1.0) - f * s);
    const t = v * (vectors.f32x4s(1.0) - (vectors.f32x4s(1.0) - f) * s);

    const ii = @as(i32, @intFromFloat(mod(i, vectors.f32x4s(6.0))[0]));
    const rgb = switch (ii) {
        0 => blk: {
            const vt = select(vectors.boolx4(true, false, false, false), v, t);
            break :blk select(vectors.boolx4(true, true, false, false), vt, p);
        },
        1 => blk: {
            const qv = select(vectors.boolx4(true, false, false, false), q, v);
            break :blk select(vectors.boolx4(true, true, false, false), qv, p);
        },
        2 => blk: {
            const pv = select(vectors.boolx4(true, false, false, false), p, v);
            break :blk select(vectors.boolx4(true, true, false, false), pv, t);
        },
        3 => blk: {
            const pq = select(vectors.boolx4(true, false, false, false), p, q);
            break :blk select(vectors.boolx4(true, true, false, false), pq, v);
        },
        4 => blk: {
            const tp = select(vectors.boolx4(true, false, false, false), t, p);
            break :blk select(vectors.boolx4(true, true, false, false), tp, v);
        },
        5 => blk: {
            const vp = select(vectors.boolx4(true, false, false, false), v, p);
            break :blk select(vectors.boolx4(true, true, false, false), vp, q);
        },
        else => unreachable,
    };
    return select(vectors.boolx4(true, true, true, false), rgb, hsv);
}

pub fn rgbToSrgb(rgb: vectors.F32x4) vectors.F32x4 {
    const static = struct {
        const cutoff = vectors.f32x4(0.0031308, 0.0031308, 0.0031308, 1.0);
        const linear = vectors.f32x4(12.92, 12.92, 12.92, 1.0);
        const scale = vectors.f32x4(1.055, 1.055, 1.055, 1.0);
        const bias = vectors.f32x4(0.055, 0.055, 0.055, 1.0);
        const rgamma = 1.0 / 2.4;
    };
    var v = saturate(rgb);
    const v0 = v * static.linear;
    const v1 = static.scale * vectors.f32x4(
        std.math.pow(f32, v[0], static.rgamma),
        std.math.pow(f32, v[1], static.rgamma),
        std.math.pow(f32, v[2], static.rgamma),
        v[3],
    ) - static.bias;
    v = select(v < static.cutoff, v0, v1);
    return select(vectors.boolx4(true, true, true, false), v, rgb);
}

pub fn srgbToRgb(srgb: vectors.F32x4) vectors.F32x4 {
    const static = struct {
        const cutoff = vectors.f32x4(0.04045, 0.04045, 0.04045, 1.0);
        const rlinear = vectors.f32x4(1.0 / 12.92, 1.0 / 12.92, 1.0 / 12.92, 1.0);
        const scale = vectors.f32x4(1.0 / 1.055, 1.0 / 1.055, 1.0 / 1.055, 1.0);
        const bias = vectors.f32x4(0.055, 0.055, 0.055, 1.0);
        const gamma = 2.4;
    };
    var v = saturate(srgb);
    const v0 = v * static.rlinear;
    var v1 = static.scale * (v + static.bias);
    v1 = vectors.f32x4(
        std.math.pow(f32, v1[0], static.gamma),
        std.math.pow(f32, v1[1], static.gamma),
        std.math.pow(f32, v1[2], static.gamma),
        v1[3],
    );
    v = select(v > static.cutoff, v1, v0);
    return select(vectors.boolx4(true, true, true, false), v, srgb);
}

// ------------------------------------------------------------------------------
//
// X. Misc functions
//
// ------------------------------------------------------------------------------
pub fn linePointDistance(linept0: vectors.Vec, linept1: vectors.Vec, pt: vectors.Vec) vectors.F32x4 {
    const ptvec = pt - linept0;
    const linevec = linept1 - linept0;
    const scale = dot3(ptvec, linevec) / lengthSq3(linevec);
    return length3(ptvec - linevec * scale);
}

pub fn sin32(v: f32) f32 {
    var y = v - std.math.tau * @round(v * 1.0 / std.math.tau);

    if (y > 0.5 * std.math.pi) {
        y = std.math.pi - y;
    } else if (y < -std.math.pi * 0.5) {
        y = -std.math.pi - y;
    }
    const y2 = y * y;

    // 11-degree minimax approximation
    var sinv = mulAdd(@as(f32, -2.3889859e-08), y2, 2.7525562e-06);
    sinv = mulAdd(sinv, y2, -0.00019840874);
    sinv = mulAdd(sinv, y2, 0.0083333310);
    sinv = mulAdd(sinv, y2, -0.16666667);
    return y * mulAdd(sinv, y2, 1.0);
}
pub fn cos32(v: f32) f32 {
    var y = v - std.math.tau * @round(v * 1.0 / std.math.tau);

    const sign = blk: {
        if (y > 0.5 * std.math.pi) {
            y = std.math.pi - y;
            break :blk @as(f32, -1.0);
        } else if (y < -std.math.pi * 0.5) {
            y = -std.math.pi - y;
            break :blk @as(f32, -1.0);
        } else {
            break :blk @as(f32, 1.0);
        }
    };
    const y2 = y * y;

    // 10-degree minimax approximation
    var cosv = mulAdd(@as(f32, -2.6051615e-07), y2, 2.4760495e-05);
    cosv = mulAdd(cosv, y2, -0.0013888378);
    cosv = mulAdd(cosv, y2, 0.041666638);
    cosv = mulAdd(cosv, y2, -0.5);
    return sign * mulAdd(cosv, y2, 1.0);
}
pub fn sincos32(v: f32) [2]f32 {
    var y = v - std.math.tau * @round(v * 1.0 / std.math.tau);

    const sign = blk: {
        if (y > 0.5 * std.math.pi) {
            y = std.math.pi - y;
            break :blk @as(f32, -1.0);
        } else if (y < -std.math.pi * 0.5) {
            y = -std.math.pi - y;
            break :blk @as(f32, -1.0);
        } else {
            break :blk @as(f32, 1.0);
        }
    };
    const y2 = y * y;

    // 11-degree minimax approximation
    var sinv = mulAdd(@as(f32, -2.3889859e-08), y2, 2.7525562e-06);
    sinv = mulAdd(sinv, y2, -0.00019840874);
    sinv = mulAdd(sinv, y2, 0.0083333310);
    sinv = mulAdd(sinv, y2, -0.16666667);
    sinv = y * mulAdd(sinv, y2, 1.0);

    // 10-degree minimax approximation
    var cosv = mulAdd(@as(f32, -2.6051615e-07), y2, 2.4760495e-05);
    cosv = mulAdd(cosv, y2, -0.0013888378);
    cosv = mulAdd(cosv, y2, 0.041666638);
    cosv = mulAdd(cosv, y2, -0.5);
    cosv = sign * mulAdd(cosv, y2, 1.0);

    return .{ sinv, cosv };
}

pub fn asin32(v: f32) f32 {
    const x = @abs(v);
    var omx = 1.0 - x;
    if (omx < 0.0) {
        omx = 0.0;
    }
    const root = @sqrt(omx);

    // 7-degree minimax approximation
    var result = mulAdd(@as(f32, -0.0012624911), x, 0.0066700901);
    result = mulAdd(result, x, -0.0170881256);
    result = mulAdd(result, x, 0.0308918810);
    result = mulAdd(result, x, -0.0501743046);
    result = mulAdd(result, x, 0.0889789874);
    result = mulAdd(result, x, -0.2145988016);
    result = root * mulAdd(result, x, 1.5707963050);

    return if (v >= 0.0) 0.5 * std.math.pi - result else result - 0.5 * std.math.pi;
}

pub fn acos32(v: f32) f32 {
    const x = @abs(v);
    var omx = 1.0 - x;
    if (omx < 0.0) {
        omx = 0.0;
    }
    const root = @sqrt(omx);

    // 7-degree minimax approximation
    var result = mulAdd(@as(f32, -0.0012624911), x, 0.0066700901);
    result = mulAdd(result, x, -0.0170881256);
    result = mulAdd(result, x, 0.0308918810);
    result = mulAdd(result, x, -0.0501743046);
    result = mulAdd(result, x, 0.0889789874);
    result = mulAdd(result, x, -0.2145988016);
    result = root * mulAdd(result, x, 1.5707963050);

    return if (v >= 0.0) result else std.math.pi - result;
}

pub fn modAngle32(in_angle: f32) f32 {
    const angle = in_angle + std.math.pi;
    var temp: f32 = @abs(angle);
    temp = temp - (2.0 * std.math.pi * @as(f32, @floatFromInt(@as(i32, @intFromFloat(temp / std.math.pi)))));
    temp = temp - std.math.pi;
    if (angle < 0.0) {
        temp = -temp;
    }
    return temp;
}

pub fn cmulSoa(re0: anytype, im0: anytype, re1: anytype, im1: anytype) [2]@TypeOf(re0, im0, re1, im1) {
    const re0_re1 = re0 * re1;
    const re0_im1 = re0 * im1;
    return .{
        mulAdd(-im0, im1, re0_re1), // re
        mulAdd(re1, im0, re0_im1), // im
    };
}
// ------------------------------------------------------------------------------
//
// FFT (implementation based on xdsp.h from DirectXMath)
//
// ------------------------------------------------------------------------------
fn fftButterflyDit4_1(re0: *vectors.F32x4, im0: *vectors.F32x4) void {
    const re0l = swizzle(re0.*, .x, .x, .y, .y);
    const re0h = swizzle(re0.*, .z, .z, .w, .w);

    const im0l = swizzle(im0.*, .x, .x, .y, .y);
    const im0h = swizzle(im0.*, .z, .z, .w, .w);

    const re_temp = mulAdd(re0h, vectors.f32x4(1.0, -1.0, 1.0, -1.0), re0l);
    const im_temp = mulAdd(im0h, vectors.f32x4(1.0, -1.0, 1.0, -1.0), im0l);

    const re_shuf0 = @shuffle(f32, re_temp, im_temp, [4]i32{ 2, 3, ~@as(i32, 2), ~@as(i32, 3) });
    const re_shuf = swizzle(re_shuf0, .x, .w, .x, .w);
    const im_shuf = swizzle(re_shuf0, .z, .y, .z, .y);

    const re_templ = swizzle(re_temp, .x, .y, .x, .y);
    const im_templ = swizzle(im_temp, .x, .y, .x, .y);

    re0.* = mulAdd(re_shuf, vectors.f32x4(1.0, 1.0, -1.0, -1.0), re_templ);
    im0.* = mulAdd(im_shuf, vectors.f32x4(1.0, -1.0, -1.0, 1.0), im_templ);
}

fn fftButterflyDit4_4(
    re0: *vectors.F32x4,
    re1: *vectors.F32x4,
    re2: *vectors.F32x4,
    re3: *vectors.F32x4,
    im0: *vectors.F32x4,
    im1: *vectors.F32x4,
    im2: *vectors.F32x4,
    im3: *vectors.F32x4,
    unity_table_re: []const vectors.F32x4,
    unity_table_im: []const vectors.F32x4,
    stride: u32,
    last: bool,
) void {
    const re_temp0 = re0.* + re2.*;
    const im_temp0 = im0.* + im2.*;

    const re_temp2 = re1.* + re3.*;
    const im_temp2 = im1.* + im3.*;

    const re_temp1 = re0.* - re2.*;
    const im_temp1 = im0.* - im2.*;

    const re_temp3 = re1.* - re3.*;
    const im_temp3 = im1.* - im3.*;

    var re_temp4 = re_temp0 + re_temp2;
    var im_temp4 = im_temp0 + im_temp2;

    var re_temp5 = re_temp1 + im_temp3;
    var im_temp5 = im_temp1 - re_temp3;

    var re_temp6 = re_temp0 - re_temp2;
    var im_temp6 = im_temp0 - im_temp2;

    var re_temp7 = re_temp1 - im_temp3;
    var im_temp7 = im_temp1 + re_temp3;

    {
        const re_im = cmulSoa(re_temp5, im_temp5, unity_table_re[stride], unity_table_im[stride]);
        re_temp5 = re_im[0];
        im_temp5 = re_im[1];
    }
    {
        const re_im = cmulSoa(re_temp6, im_temp6, unity_table_re[stride * 2], unity_table_im[stride * 2]);
        re_temp6 = re_im[0];
        im_temp6 = re_im[1];
    }
    {
        const re_im = cmulSoa(re_temp7, im_temp7, unity_table_re[stride * 3], unity_table_im[stride * 3]);
        re_temp7 = re_im[0];
        im_temp7 = re_im[1];
    }

    if (last) {
        fftButterflyDit4_1(&re_temp4, &im_temp4);
        fftButterflyDit4_1(&re_temp5, &im_temp5);
        fftButterflyDit4_1(&re_temp6, &im_temp6);
        fftButterflyDit4_1(&re_temp7, &im_temp7);
    }

    re0.* = re_temp4;
    im0.* = im_temp4;

    re1.* = re_temp5;
    im1.* = im_temp5;

    re2.* = re_temp6;
    im2.* = im_temp6;

    re3.* = re_temp7;
    im3.* = im_temp7;
}

pub fn fft4(re: []vectors.F32x4, im: []vectors.F32x4, count: u32) void {
    std.debug.assert(std.math.isPowerOfTwo(count));
    std.debug.assert(re.len >= count);
    std.debug.assert(im.len >= count);

    var index: u32 = 0;
    while (index < count) : (index += 1) {
        fftButterflyDit4_1(&re[index], &im[index]);
    }
}

pub fn fft8(re: []vectors.F32x4, im: []vectors.F32x4, count: u32) void {
    std.debug.assert(std.math.isPowerOfTwo(count));
    std.debug.assert(re.len >= 2 * count);
    std.debug.assert(im.len >= 2 * count);

    var index: u32 = 0;
    while (index < count) : (index += 1) {
        var pre = re[index * 2 ..];
        var pim = im[index * 2 ..];

        var odds_re = @shuffle(f32, pre[0], pre[1], [4]i32{ 1, 3, ~@as(i32, 1), ~@as(i32, 3) });
        var evens_re = @shuffle(f32, pre[0], pre[1], [4]i32{ 0, 2, ~@as(i32, 0), ~@as(i32, 2) });
        var odds_im = @shuffle(f32, pim[0], pim[1], [4]i32{ 1, 3, ~@as(i32, 1), ~@as(i32, 3) });
        var evens_im = @shuffle(f32, pim[0], pim[1], [4]i32{ 0, 2, ~@as(i32, 0), ~@as(i32, 2) });
        fftButterflyDit4_1(&odds_re, &odds_im);
        fftButterflyDit4_1(&evens_re, &evens_im);

        {
            const re_im = cmulSoa(
                odds_re,
                odds_im,
                vectors.f32x4(1.0, 0.70710677, 0.0, -0.70710677),
                vectors.f32x4(0.0, -0.70710677, -1.0, -0.70710677),
            );
            pre[0] = evens_re + re_im[0];
            pim[0] = evens_im + re_im[1];
        }
        {
            const re_im = cmulSoa(
                odds_re,
                odds_im,
                vectors.f32x4(-1.0, -0.70710677, 0.0, 0.70710677),
                vectors.f32x4(0.0, 0.70710677, 1.0, 0.70710677),
            );
            pre[1] = evens_re + re_im[0];
            pim[1] = evens_im + re_im[1];
        }
    }
}

pub fn fft16(re: []vectors.F32x4, im: []vectors.F32x4, count: u32) void {
    std.debug.assert(std.math.isPowerOfTwo(count));
    std.debug.assert(re.len >= 4 * count);
    std.debug.assert(im.len >= 4 * count);

    const static = struct {
        const unity_table_re = [4]vectors.F32x4{
            vectors.f32x4(1.0, 1.0, 1.0, 1.0),
            vectors.f32x4(1.0, 0.92387950, 0.70710677, 0.38268343),
            vectors.f32x4(1.0, 0.70710677, -4.3711388e-008, -0.70710677),
            vectors.f32x4(1.0, 0.38268343, -0.70710677, -0.92387950),
        };
        const unity_table_im = [4]vectors.F32x4{
            vectors.f32x4(-0.0, -0.0, -0.0, -0.0),
            vectors.f32x4(-0.0, -0.38268343, -0.70710677, -0.92387950),
            vectors.f32x4(-0.0, -0.70710677, -1.0, -0.70710677),
            vectors.f32x4(-0.0, -0.92387950, -0.70710677, 0.38268343),
        };
    };

    var index: u32 = 0;
    while (index < count) : (index += 1) {
        fftButterflyDit4_4(
            &re[index * 4],
            &re[index * 4 + 1],
            &re[index * 4 + 2],
            &re[index * 4 + 3],
            &im[index * 4],
            &im[index * 4 + 1],
            &im[index * 4 + 2],
            &im[index * 4 + 3],
            static.unity_table_re[0..],
            static.unity_table_im[0..],
            1,
            true,
        );
    }
}

fn fftN(re: []vectors.F32x4, im: []vectors.F32x4, unity_table: []const vectors.F32x4, length: u32, count: u32) void {
    std.debug.assert(length > 16);
    std.debug.assert(std.math.isPowerOfTwo(length));
    std.debug.assert(std.math.isPowerOfTwo(count));
    std.debug.assert(re.len >= length * count / 4);
    std.debug.assert(re.len == im.len);

    const total = count * length;
    const total_vectors = total / 4;
    const stage_vectors = length / 4;
    const stage_vectors_mask = stage_vectors - 1;
    const stride = length / 16;
    const stride_mask = stride - 1;
    const stride_inv_mask = ~stride_mask;

    var unity_table_re = unity_table;
    var unity_table_im = unity_table[length / 4 ..];

    var index: u32 = 0;
    while (index < total_vectors / 4) : (index += 1) {
        const n = (index & stride_inv_mask) * 4 + (index & stride_mask);
        fftButterflyDit4_4(
            &re[n],
            &re[n + stride],
            &re[n + stride * 2],
            &re[n + stride * 3],
            &im[n],
            &im[n + stride],
            &im[n + stride * 2],
            &im[n + stride * 3],
            unity_table_re[(n & stage_vectors_mask)..],
            unity_table_im[(n & stage_vectors_mask)..],
            stride,
            false,
        );
    }

    if (length > 16 * 4) {
        fftN(re, im, unity_table[(length / 2)..], length / 4, count * 4);
    } else if (length == 16 * 4) {
        fft16(re, im, count * 4);
    } else if (length == 8 * 4) {
        fft8(re, im, count * 4);
    } else if (length == 4 * 4) {
        fft4(re, im, count * 4);
    }
}

pub fn fftUnswizzle(input: []const vectors.F32x4, output: []vectors.F32x4) void {
    std.debug.assert(std.math.isPowerOfTwo(input.len));
    std.debug.assert(input.len == output.len);
    std.debug.assert(input.ptr != output.ptr);

    const log2_length = std.math.log2_int(usize, input.len * 4);
    std.debug.assert(log2_length >= 2);

    const length = input.len;

    const f32_output = @as([*]f32, @ptrCast(output.ptr))[0 .. output.len * 4];

    const static = struct {
        const swizzle_table = [256]u8{
            0x00, 0x40, 0x80, 0xC0, 0x10, 0x50, 0x90, 0xD0, 0x20, 0x60, 0xA0, 0xE0, 0x30, 0x70, 0xB0, 0xF0,
            0x04, 0x44, 0x84, 0xC4, 0x14, 0x54, 0x94, 0xD4, 0x24, 0x64, 0xA4, 0xE4, 0x34, 0x74, 0xB4, 0xF4,
            0x08, 0x48, 0x88, 0xC8, 0x18, 0x58, 0x98, 0xD8, 0x28, 0x68, 0xA8, 0xE8, 0x38, 0x78, 0xB8, 0xF8,
            0x0C, 0x4C, 0x8C, 0xCC, 0x1C, 0x5C, 0x9C, 0xDC, 0x2C, 0x6C, 0xAC, 0xEC, 0x3C, 0x7C, 0xBC, 0xFC,
            0x01, 0x41, 0x81, 0xC1, 0x11, 0x51, 0x91, 0xD1, 0x21, 0x61, 0xA1, 0xE1, 0x31, 0x71, 0xB1, 0xF1,
            0x05, 0x45, 0x85, 0xC5, 0x15, 0x55, 0x95, 0xD5, 0x25, 0x65, 0xA5, 0xE5, 0x35, 0x75, 0xB5, 0xF5,
            0x09, 0x49, 0x89, 0xC9, 0x19, 0x59, 0x99, 0xD9, 0x29, 0x69, 0xA9, 0xE9, 0x39, 0x79, 0xB9, 0xF9,
            0x0D, 0x4D, 0x8D, 0xCD, 0x1D, 0x5D, 0x9D, 0xDD, 0x2D, 0x6D, 0xAD, 0xED, 0x3D, 0x7D, 0xBD, 0xFD,
            0x02, 0x42, 0x82, 0xC2, 0x12, 0x52, 0x92, 0xD2, 0x22, 0x62, 0xA2, 0xE2, 0x32, 0x72, 0xB2, 0xF2,
            0x06, 0x46, 0x86, 0xC6, 0x16, 0x56, 0x96, 0xD6, 0x26, 0x66, 0xA6, 0xE6, 0x36, 0x76, 0xB6, 0xF6,
            0x0A, 0x4A, 0x8A, 0xCA, 0x1A, 0x5A, 0x9A, 0xDA, 0x2A, 0x6A, 0xAA, 0xEA, 0x3A, 0x7A, 0xBA, 0xFA,
            0x0E, 0x4E, 0x8E, 0xCE, 0x1E, 0x5E, 0x9E, 0xDE, 0x2E, 0x6E, 0xAE, 0xEE, 0x3E, 0x7E, 0xBE, 0xFE,
            0x03, 0x43, 0x83, 0xC3, 0x13, 0x53, 0x93, 0xD3, 0x23, 0x63, 0xA3, 0xE3, 0x33, 0x73, 0xB3, 0xF3,
            0x07, 0x47, 0x87, 0xC7, 0x17, 0x57, 0x97, 0xD7, 0x27, 0x67, 0xA7, 0xE7, 0x37, 0x77, 0xB7, 0xF7,
            0x0B, 0x4B, 0x8B, 0xCB, 0x1B, 0x5B, 0x9B, 0xDB, 0x2B, 0x6B, 0xAB, 0xEB, 0x3B, 0x7B, 0xBB, 0xFB,
            0x0F, 0x4F, 0x8F, 0xCF, 0x1F, 0x5F, 0x9F, 0xDF, 0x2F, 0x6F, 0xAF, 0xEF, 0x3F, 0x7F, 0xBF, 0xFF,
        };
    };

    if ((log2_length & 1) == 0) {
        const rev32 = @as(u6, @intCast(32 - log2_length));
        var index: usize = 0;
        while (index < length) : (index += 1) {
            const n = index * 4;
            const addr =
                (@as(usize, @intCast(static.swizzle_table[n & 0xff])) << 24) |
                (@as(usize, @intCast(static.swizzle_table[(n >> 8) & 0xff])) << 16) |
                (@as(usize, @intCast(static.swizzle_table[(n >> 16) & 0xff])) << 8) |
                @as(usize, @intCast(static.swizzle_table[(n >> 24) & 0xff]));
            f32_output[addr >> rev32] = input[index][0];
            f32_output[(0x40000000 | addr) >> rev32] = input[index][1];
            f32_output[(0x80000000 | addr) >> rev32] = input[index][2];
            f32_output[(0xC0000000 | addr) >> rev32] = input[index][3];
        }
    } else {
        const rev7 = @as(usize, 1) << @as(u6, @intCast(log2_length - 3));
        const rev32 = @as(u6, @intCast(32 - (log2_length - 3)));
        var index: usize = 0;
        while (index < length) : (index += 1) {
            const n = index / 2;
            var addr =
                (((@as(usize, @intCast(static.swizzle_table[n & 0xff])) << 24) |
                (@as(usize, @intCast(static.swizzle_table[(n >> 8) & 0xff])) << 16) |
                (@as(usize, @intCast(static.swizzle_table[(n >> 16) & 0xff])) << 8) |
                (@as(usize, @intCast(static.swizzle_table[(n >> 24) & 0xff])))) >> rev32) |
                ((index & 1) * rev7 * 4);
            f32_output[addr] = input[index][0];
            addr += rev7;
            f32_output[addr] = input[index][1];
            addr += rev7;
            f32_output[addr] = input[index][2];
            addr += rev7;
            f32_output[addr] = input[index][3];
        }
    }
}

pub fn fft(re: []vectors.F32x4, im: []vectors.F32x4, unity_table: []const vectors.F32x4) void {
    const length = @as(u32, @intCast(re.len * 4));
    std.debug.assert(std.math.isPowerOfTwo(length));
    std.debug.assert(length >= 4 and length <= 512);
    std.debug.assert(re.len == im.len);

    var re_temp_storage: [128]vectors.F32x4 = undefined;
    var im_temp_storage: [128]vectors.F32x4 = undefined;
    const re_temp = re_temp_storage[0..re.len];
    const im_temp = im_temp_storage[0..im.len];

    @memcpy(re_temp, re);
    @memcpy(im_temp, im);

    if (length > 16) {
        std.debug.assert(unity_table.len == length);
        fftN(re_temp, im_temp, unity_table, length, 1);
    } else if (length == 16) {
        fft16(re_temp, im_temp, 1);
    } else if (length == 8) {
        fft8(re_temp, im_temp, 1);
    } else if (length == 4) {
        fft4(re_temp, im_temp, 1);
    }

    fftUnswizzle(re_temp, re);
    fftUnswizzle(im_temp, im);
}

pub fn ifft(re: []vectors.F32x4, im: []const vectors.F32x4, unity_table: []const vectors.F32x4) void {
    const length = @as(u32, @intCast(re.len * 4));
    std.debug.assert(std.math.isPowerOfTwo(length));
    std.debug.assert(length >= 4 and length <= 512);
    std.debug.assert(re.len == im.len);

    var re_temp_storage: [128]vectors.F32x4 = undefined;
    var im_temp_storage: [128]vectors.F32x4 = undefined;
    var re_temp = re_temp_storage[0..re.len];
    var im_temp = im_temp_storage[0..im.len];

    const rnp = vectors.f32x4s(1.0 / @as(f32, @floatFromInt(length)));
    const rnm = vectors.f32x4s(-1.0 / @as(f32, @floatFromInt(length)));

    for (re, 0..) |_, i| {
        re_temp[i] = re[i] * rnp;
        im_temp[i] = im[i] * rnm;
    }

    if (length > 16) {
        std.debug.assert(unity_table.len == length);
        fftN(re_temp, im_temp, unity_table, length, 1);
    } else if (length == 16) {
        fft16(re_temp, im_temp, 1);
    } else if (length == 8) {
        fft8(re_temp, im_temp, 1);
    } else if (length == 4) {
        fft4(re_temp, im_temp, 1);
    }

    fftUnswizzle(re_temp, re);
}

// ------------------------------------------------------------------------------
//
// Private functions and constants
//
// ------------------------------------------------------------------------------
const f32x4_sign_mask1: vectors.F32x4 = vectors.F32x4{ @as(f32, @bitCast(@as(u32, 0x8000_0000))), 0, 0, 0 };
const f32x4_mask2: vectors.F32x4 = vectors.F32x4{
    @as(f32, @bitCast(@as(u32, 0xffff_ffff))),
    @as(f32, @bitCast(@as(u32, 0xffff_ffff))),
    0,
    0,
};
const f32x4_mask3: vectors.F32x4 = vectors.F32x4{
    @as(f32, @bitCast(@as(u32, 0xffff_ffff))),
    @as(f32, @bitCast(@as(u32, 0xffff_ffff))),
    @as(f32, @bitCast(@as(u32, 0xffff_ffff))),
    0,
};

inline fn splatNegativeZero(comptime T: type) T {
    return @splat(@as(f32, @bitCast(@as(u32, 0x8000_0000))));
}
inline fn splatNoFraction(comptime T: type) T {
    return @splat(@as(f32, 8_388_608.0));
}
inline fn splatAbsMask(comptime T: type) T {
    return @splat(@as(f32, @bitCast(@as(u32, 0x7fff_ffff))));
}

pub fn floatToIntAndBack(v: anytype) @TypeOf(v) {
    // This routine won't handle nan, inf and numbers greater than 8_388_608.0 (will generate undefined values).
    @setRuntimeSafety(false);

    const T = @TypeOf(v);
    const len = vectors.veclen(T);

    var vi32: [len]i32 = undefined;
    comptime var i: u32 = 0;
    // vcvttps2dq
    inline while (i < len) : (i += 1) {
        vi32[i] = @as(i32, @intFromFloat(v[i]));
    }

    var vf32: [len]f32 = undefined;
    i = 0;
    // vcvtdq2ps
    inline while (i < len) : (i += 1) {
        vf32[i] = @as(f32, @floatFromInt(vi32[i]));
    }

    return vf32;
}

pub fn expectVecEqual(expected: anytype, actual: anytype) !void {
    const T = @TypeOf(expected, actual);
    inline for (0..vectors.veclen(T)) |i| {
        try std.testing.expectEqual(expected[i], actual[i]);
    }
}

pub fn expectVecApproxEqAbs(expected: anytype, actual: anytype, eps: f32) !void {
    const T = @TypeOf(expected, actual);
    inline for (0..vectors.veclen(T)) |i| {
        try std.testing.expectApproxEqAbs(expected[i], actual[i], eps);
    }
}

pub fn approxEqAbs(v0: anytype, v1: anytype, eps: f32) bool {
    const T = @TypeOf(v0, v1);
    comptime var i: comptime_int = 0;
    inline while (i < vectors.veclen(T)) : (i += 1) {
        if (!std.math.approxEqAbs(f32, v0[i], v1[i], eps)) {
            return false;
        }
    }
    return true;
}

// ------------------------------------------------------------------------------
// This software is available under 2 licenses -- choose whichever you prefer.
// ------------------------------------------------------------------------------
// ALTERNATIVE A - MIT License
// Copyright (c) 2022 Michal Ziulek and Contributors
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
// of the Software, and to permit persons to whom the Software is furnished to do
// so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
// ------------------------------------------------------------------------------
// ALTERNATIVE B - Public Domain (www.unlicense.org)
// This is free and unencumbered software released into the public domain.
// Anyone is free to copy, modify, publish, use, compile, sell, or distribute this
// software, either in source code form or as a compiled binary, for any purpose,
// commercial or non-commercial, and by any means.
// In jurisdictions that recognize copyright laws, the author or authors of this
// software dedicate any and all copyright interest in the software to the public
// domain. We make this dedication for the benefit of the public at large and to
// the detriment of our heirs and successors. We intend this dedication to be an
// overt act of relinquishment in perpetuity of all present and future rights to
// this software under copyright law.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
// ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
// WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
// ------------------------------------------------------------------------------
