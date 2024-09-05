pub const BVec2 = struct {
    values: @Vector(2, bool),

    pub fn new(e0: bool, e1: bool) BVec2 {
        return new_b_vec(BVec2, bool, 2, 2, [2]bool{ e0, e1 });
    }

    pub fn len() usize {
        return 2;
    }
};

pub const BVec3 = struct {
    values: @Vector(3, bool),

    pub fn new(e0: bool, e1: bool, e2: bool) BVec3 {
        return new_b_vec(BVec3, bool, 3, 3, [3]bool{ e0, e1, e2 });
    }

    pub fn len() usize {
        return 3;
    }
};

pub const BVec4 = struct {
    values: @Vector(4, bool),

    pub fn new(e0: bool, e1: bool, e2: bool, e3: bool) BVec4 {
        return new_b_vec(BVec4, bool, 4, 4, [4]bool{ e0, e1, e2, e3 });
    }

    pub fn len() usize {
        return 4;
    }
};

pub fn new_b_vec(comptime T: type, comptime E: type, comptime size: usize, comptime e_count: usize, values: [e_count]E) T {
    if (T != BVec2 and T != BVec3 and T != BVec4) {
        @compileError("new_b_vec: T must be a type bool vector");
    }

    if (values.len != e_count) {
        @compileError("new_b_vec: the number of element must be equal to the length of values");
    }

    if (size != values.len and values.len != 1) {
        @compileError("new_b_vec: size must be equal to the length of values if values has more than one element");
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
