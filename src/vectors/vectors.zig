/// This file contains the definition of vectors and their operations. The vectors are defined as structs with a values field that is an array of the vector's components.
/// The components are accessed using the x, y, z, and w fields of the vector struct. The vectors are defined for both floating-point and integer types.
const std = @import("std");
const builtin = @import("builtin");
const bool_vectors = @import("bool_vectors.zig");

const cpu_arch = builtin.cpu.arch;
const has_avx = if (cpu_arch == .x86_64) std.Target.x86.featureSetHas(builtin.cpu.features, .avx) else false;
const has_avx512f = if (cpu_arch == .x86_64) std.Target.x86.featureSetHas(builtin.cpu.features, .avx512f) else false;
const has_fma = if (cpu_arch == .x86_64) std.Target.x86.featureSetHas(builtin.cpu.features, .fma) else false;

// ------------------------------------------------------------------------------
//
// 1. 64-bit vectors
//
// ------------------------------------------------------------------------------

const Vec2 = @import("Vec2.zig");
const Vec3 = @import("Vec3.zig");
const Vec4 = @import("Vec4.zig");
const IVec2 = @import("IVec2.zig");
const IVec3 = @import("IVec3.zig");
const IVec4 = @import("IVec4.zig");

pub const F64x2 = @Vector(2, f64);
pub const F64x3 = @Vector(3, f64);
pub const F64x4 = @Vector(4, f64);

pub const I64x2 = @Vector(2, i64);
pub const I64x3 = @Vector(3, i64);
pub const I64x4 = @Vector(4, i64);

// ------------------------------------------------------------------------------
//
// 2. 32-bit vectors
//
// ------------------------------------------------------------------------------

const F32Vec2 = @import("Vec2.zig");
const F32Vec3 = @import("Vec3.zig");
const F32Vec4 = @import("Vec4.zig");
const I32Vec2 = @import("IVec2.zig");
const I32Vec3 = @import("IVec3.zig");
const I32Vec4 = @import("IVec4.zig");

const F32x2 = @Vector(2, f64);
const F32x3 = @Vector(3, f64);
const F32x4 = @Vector(4, f64);

const I32x2 = @Vector(2, i64);
const I32x3 = @Vector(3, i64);
const I32x4 = @Vector(4, i64);

// ------------------------------------------------------------------------------

/// Enum representing the components of a vector whith each component having a value of 0, 1, 2, or 3 representing the x, y, z, and w components respectively. These values are used to index into the values array of a vector.
pub const AxisComponent = enum(u8) { X = 0, Y = 1, Z = 2, W = 3 };

/// Creates a new vector of any suported type from a slice of values. If the length of the slice is 1, the vector will be initialized with the same value for all components. Otherwise, the vector will be initialized with
/// the values in the slice.
pub fn new(comptime T: type, comptime Te: type, values: [T.len()]Te) T 
{
    if (T != Vec2 and T != Vec3 and T != Vec4 and T != IVec2 and T != IVec3 and T != IVec4 and T != F32Vec2 and T != F32Vec3 and T != F32Vec4 and T != I32Vec2 and T != I32Vec3 and T != I32Vec4) {
        @compileError("new_vec: T must be a type vector");
    }

    const slice: [T.len()]Te = values;
    const vals: @Vector(T.len(), Te) = slice;

    return T{ .values = vals };
}

pub fn splat(comptime T: type, comptime Te: type, val: Te) T
{
    if (T != Vec2 and T != Vec3 and T != Vec4 and T != IVec2 and T != IVec3 and T != IVec4 and T != F32Vec2 and T != F32Vec3 and T != F32Vec4 and T != I32Vec2 and T != I32Vec3 and T != I32Vec4) {
        @compileError("splat: T must be a type vector");
    }

    return T { .values = @splat(val) };
}

pub fn splat_int(val: isize) @Vector(val, @TypeOf(val))
{
    return @splat(val);
}

pub fn splat_negative_zero(comptime T: type) T
{
    if (T != Vec2 and T != Vec3 and T != Vec4 and T != IVec2 and T != IVec3 and T != IVec4 and T != F32Vec2 and T != F32Vec3 and T != F32Vec4 and T != I32Vec2 and T != I32Vec3 and T != I32Vec4) {
        @compileError("splat_negative_zero: T must be a type vector");
    }

    return T { .values = @splat(-0.0) };
}

/// Creates an array of values from a vector, based on the components specified in the component_mask. The component_mask is an array of AxisComponent values that specify which components of the vector to include in the array.
pub inline fn components_to_array(vec: anytype, comptime component_mask: []AxisComponent) [component_mask.len]@typeInfo(vec.values).Vector.elem_type {
    const vec_type = @TypeOf(vec);

    if (vec_type != IVec2 and vec_type != IVec3 and vec_type != IVec4 and vec_type != Vec2 and vec_type != Vec3 and vec_type != Vec4) {
        @compileError("componets_to_array: vec must be a vector type");
    }

    const comp_array: [component_mask.len]@typeInfo(vec.values).Vector.elem_type = .{0} ** component_mask.len;

    inline for (component_mask, 0..) |component, i| {
        comp_array[i] = vec.values[@intFromEnum(component)];
    }

    return comp_array;
}

/// Determines if two vectors are approximately equal within a given epsilon value. The epsilon value is used to determine the maximum difference between the components of the two vectors that is considered equal.
pub inline fn is_approximatly_equal(comptime T: type, a: T, b: T, epsilon: @typeInfo(a.values).Vector.elem_type) bool {
    if (T != Vec2 and T != Vec3 and T != Vec4 and T != IVec2 and T != IVec3 and T != IVec4 and T != F32Vec2 and T != F32Vec3 and T != F32Vec4 and T != I32Vec2 and T != I32Vec3 and T != I32Vec4) {
        @compileError("is_approximatly_equal: T must be a type vector");
    }

    const E = @TypeOf(a.values, b.values, epsilon);
    const delta = a.values - b.values;
    const temp = max_fast(delta, new(T, E, a.len(), .{0.0}).values - delta);
    return temp <= epsilon;
}

inline fn max_fast(v0: anytype, v1: anytype) @TypeOf(v0, v1) {
    return select(v0 > v1, v0, v1); // maxps
}

inline fn select(E: type, mask: anytype, v0: anytype, v1: anytype) @TypeOf(v0, v1) {
    return @select(E, mask, v0, v1);
}

inline fn vec_from_array(E: type, size: usize, values: []E) @Vector(usize, E) {
    var vec = @Vector(size, E);

    inline for (values, 0..) |value, i| {
        vec[i] = value;
    }

    return values;
}

pub inline fn is_NAN(T: type, val: T) @Vector(T.len(), bool) {
    return val.values != val.values;
}

pub inline fn abs(val: anytype) @TypeOf(val) {
    .{ .values = @abs(val.values) };
}

pub inline fn is_inf(val: anytype) @Vector(val.len(), bool) {
    const T = @TypeOf(val);
    if (T != Vec2 and T != Vec3 and T != Vec4 and T != IVec2 and T != IVec3 and T != IVec4 and T != F32Vec2 and T != F32Vec3 and T != F32Vec4 and T != I32Vec2 and T != I32Vec3 and T != I32Vec4) {
        @compileError("is_approximatly_equal: T must be a type vector");
    }

    return abs(val) == new(T, f64, 4, 1, .{std.math.inf(f64)});
}

pub fn all_true(vb: anytype) bool {
    const T = @TypeOf(vb);
    if (T != bool_vectors.BVec2 and T != bool_vectors.BVec3 and T != bool_vectors.BVec4) {
        @compileError("all_true: T must be a type bool vector");
    }
    const ab: [T.len()]bool = vb;    
    var result = true;
    
    for (0..T.len()) |i| {
        result = result or ab[i];
    }
    return result;
}

pub fn any_true(vb: anytype) bool {
    const T = @TypeOf(vb);
    if (T != bool_vectors.BVec2 and T != bool_vectors.BVec3 and T != bool_vectors.BVec4) {
        @compileError("all_true: T must be a type bool vector");
    }
    const ab: [T.len()]bool = vb.values;
    var result = false;

    for (0..T.len()) |i| {
        result = result or ab[i];
    }
    return result;
}

pub inline fn is_in_bounds(v: anytype, bounds: anytype) @Vector(v.len(), bool) {
    const T = @TypeOf(v, bounds);
    if (T != Vec2 and T != Vec3 and T != Vec4 and T != IVec2 and T != IVec3 and T != IVec4 and T != F32Vec2 and T != F32Vec3 and T != F32Vec4 and T != I32Vec2 and T != I32Vec3 and T != I32Vec4) {
        @compileError("is_in_bounds: T must be a type vector");
    }

    const Te = @typeInfo(T).values.Vector.elem_type;
    const e_count = v.len();

    const Tu = @Vector(e_count, u1);
    const Tr = @Vector(e_count, bool);

    // 2 x cmpleps, xorps, load, andps
    const b0 = v <= bounds;
    const b1 = (bounds.values * new(T, Te, e_count, 1, -1.0)).values <= v;
    const b0u = @as(Tu, @bitCast(b0));
    const b1u = @as(Tu, @bitCast(b1));
    return @as(Tr, @bitCast(b0u & b1u));
}

pub inline fn and_int(v0: anytype, v1: anytype) @TypeOf(v0, v1) {
    const T = @TypeOf(v0, v1);
    const Tu = @Vector(v0.len(), u32);
    const v0u = @as(Tu, @bitCast(v0));
    const v1u = @as(Tu, @bitCast(v1));
    return @as(T, @bitCast(v0u & v1u)); // andps
}

pub inline fn and_not_int(v0: anytype, v1: anytype) @TypeOf(v0, v1) {
    const T = @TypeOf(v0, v1);
    const Tu = @Vector(v0.len(), u32);
    const v0u = @as(Tu, @bitCast(v0));
    const v1u = @as(Tu, @bitCast(v1));
    return @as(T, @bitCast(~v0u & v1u)); // andnps
}

pub inline fn or_int(v0: anytype, v1: anytype) @TypeOf(v0, v1) {
    const T = @TypeOf(v0, v1);
    const Tu = @Vector(v0.len(), u32);
    const v0u = @as(Tu, @bitCast(v0));
    const v1u = @as(Tu, @bitCast(v1));
    return @as(T, @bitCast(v0u | v1u)); // orps
}

pub inline fn nor_int(v0: anytype, v1: anytype) @TypeOf(v0, v1) {
    const T = @TypeOf(v0, v1);
    const Tu = @Vector(v0.len(), u32);
    const v0u = @as(Tu, @bitCast(v0));
    const v1u = @as(Tu, @bitCast(v1));
    return @as(T, @bitCast(~(v0u | v1u))); // por, pcmpeqd, pxor
}

pub inline fn xor_int(v0: anytype, v1: anytype) @TypeOf(v0, v1) {
    const T = @TypeOf(v0, v1);
    const Tu = @Vector(v0.len(), u32);
    const v0u = @as(Tu, @bitCast(v0));
    const v1u = @as(Tu, @bitCast(v1));
    return @as(T, @bitCast(v0u ^ v1u)); // xorps
}

pub fn atan(v: anytype) @TypeOf(v) {
    // 17-degree minimax approximation
    const T = @TypeOf(v);

    const vabs = abs(v);
    const vinv = T.splat(1.0) / v;
    var sign = select(v > T.splat(1.0), T.splat(1.0), splat_negative_zero(T));
    const comp = vabs <= T.splat(1.0);
    sign = select(comp, T.splat(0.0), sign);
    const x = select(comp, v, vinv);
    const x2 = x * x;

    var result = mul_add(splat(T, 0.0028662257), x2, splat(T, -0.0161657367));
    result = mul_add(result, x2, splat(T, 0.0429096138));
    result = mul_add(result, x2, splat(T, -0.0752896400));
    result = mul_add(result, x2, splat(T, 0.1065626393));
    result = mul_add(result, x2, splat(T, -0.1420889944));
    result = mul_add(result, x2, splat(T, 0.1999355085));
    result = mul_add(result, x2, splat(T, -0.3333314528));
    result = x * mul_add(result, x2, splat(T, 1.0));

    const result1 = sign * splat(T, 0.5 * std.math.pi) - result;
    return select(sign == splat(T, 0.0), result, result1);
}

pub fn atan2(vy: anytype, vx: anytype) @TypeOf(vx, vy) {
    const T = @TypeOf(vx, vy);
    const Tu = @Vector(T.len(), u32);

    const vx_is_positive =
        (@as(Tu, @bitCast(vx)) & @as(Tu, @splat(0x8000_0000))) == @as(Tu, @splat(0));

    const vy_sign = and_int(vy, T.splat(-0.0));
    const c0_25pi = or_int(vy_sign, @as(T, @splat(0.25 * std.math.pi)));
    const c0_50pi = or_int(vy_sign, @as(T, @splat(0.50 * std.math.pi)));
    const c0_75pi = or_int(vy_sign, @as(T, @splat(0.75 * std.math.pi)));
    const c1_00pi = or_int(vy_sign, @as(T, @splat(1.00 * std.math.pi)));

    var r1 = select(vx_is_positive, vy_sign, c1_00pi);
    var r2 = select(vx == T.splat(0.0), c0_50pi, splat_int(T, 0xffff_ffff));
    const r3 = select(vy == T.splat(0.0), r1, r2);
    const r4 = select(vx_is_positive, c0_25pi, c0_75pi);
    const r5 = select(is_inf(vx), r4, c0_50pi);
    const result = select(is_inf(vy), r5, r3);
    const result_valid = @as(Tu, @bitCast(result)) == @as(Tu, @splat(0xffff_ffff));

    const v = vy / vx;
    const r0 = atan(v);

    r1 = select(vx_is_positive, splat_negative_zero(T), c1_00pi);
    r2 = r0 + r1;

    return select(result_valid, r2, result);
}

pub inline fn mul_add(v0: anytype, v1: anytype, v2: anytype) @TypeOf(v0, v1, v2) {
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
