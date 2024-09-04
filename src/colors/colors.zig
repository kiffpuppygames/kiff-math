pub const ColorComponent = enum(u8) { R = 0, G = 1, B = 2, A = 3 };

pub const Color64A = @import("Color64A.zig");

/// Creates a new vector of any suported type from a slice of values. If the length of the slice is 1, the vector will be initialized with the same value for all components. Otherwise, the vector will be initialized with
/// the values in the slice.
/// 
/// @param T The type of the vector to create.
/// @param E The element type of the vector.
/// @param size The number of elements in the vector.
/// @param e_count The number of elements in the values array.
/// @param values The array of values to initialize the vector with.
pub fn new(comptime T: type, comptime E: type, comptime size: usize, comptime e_count: usize, values: [e_count]E) T {
    if (T != Color64A ) { // *and T != Vec3 and T != Vec4 and T != IVec2 and T != IVec3 and T != IVec4 and T != F32Vec2 and T != F32Vec3 and T != F32Vec4 and T != I32Vec2 and T != I32Vec3 and T != I32Vec4)
        @compileError("new_color: T must be of type color");
    }

    if (values.len != e_count) {
        @compileError("new_color: the number of elements must be equal to the length of values");
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