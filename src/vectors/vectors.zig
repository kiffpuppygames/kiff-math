/// This file contains the definition of vectors and their operations. The vectors are defined as structs with a values field that is an array of the vector's components.
/// The components are accessed using the x, y, z, and w fields of the vector struct. The vectors are defined for both floating-point and integer types.
const std = @import("std");

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
pub fn new(comptime T: type, comptime E: type, comptime size: usize, comptime e_count: usize, values: [e_count]E) T {
    if (T != Vec2 and T != Vec3 and T != Vec4 and T != IVec2 and T != IVec3 and T != IVec4 and T != F32Vec2 and T != F32Vec3 and T != F32Vec4 and T != I32Vec2 and T != I32Vec3 and T != I32Vec4) {
        @compileError("new_vec: T must be a type vector");
    }

    if (values.len != e_count) {
        @compileError("new_vec: the number of element must be equal to the length of values");
    }

    if (size != values.len and values.len != 1) {
        @compileError("new_vec: size must be equal to the length of values if values has more than one element");
    }

    if (values.len == 1) {
        const slice: [size]E = .{values[0]} ** size;
        const vals: @Vector(size, E) = slice;
        return T{ .values = vals };
    }

    const slice: [size]E = values;
    const vals: @Vector(size, E) = slice;

    return T{ .values = vals };
}

/// Retrieves the number of elements in a vector type.
pub inline fn num_elements(comptime T: type) comptime_int {
    return @typeInfo(T).Vector.len;
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
    const temp = max_fast(delta, new(T, E, num_elements(T), .{0.0}).values - delta);
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
