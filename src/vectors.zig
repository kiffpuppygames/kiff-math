const Vec3 = @import("Vec3.zig");

pub const VectorComponent = enum(usize) 
{
    W = 0,
    X = 1,
    Y = 2,
    Z = 3,
};

pub inline fn vec(len: usize, element_type: anytype, vals: []element_type) @Vector(len, element_type) 
{
    return vals;
}

pub inline fn x(self: anytype) f64
{
    return self.values[0];
}

pub inline fn y(self: anytype) f64
{
    return self.values[1];
}

pub inline fn z(self: anytype) f64
{
    return self.values[2];
}

pub inline fn w(self: anytype) f64
{
    return self.values[3];
}

pub inline fn set_x(v: anytype, X: anytype) void
{
    v[0] = X;
}

pub inline fn set_y(v: anytype, Y: anytype) void
{
    v[1] = Y;
}

pub inline fn set_z(v: anytype, Z: anytype) void
{
    v[2] = Z;
}

pub inline fn set_w(v: anytype, W: anytype) void
{
   v[2] = W;
}

pub inline fn mul(v1: anytype, v2: anytype) @TypeOf(v1, v2)
{
    return v1 * v2;
}

pub inline fn mul_s(v1: anytype, s: anytype, len: anytype) @TypeOf(v1)
{
    const s_vec: @Vector(len, @TypeOf(s)) = @splat(s);
    return v1.values * s_vec;
}

pub inline fn div(v1: anytype, v2: anytype) @TypeOf(v1, v2)
{
    return v1.values / v2.values;
}

pub inline fn add(v1: anytype, v2: anytype) @TypeOf(v1, v2)
{
    return v1.values + v2.values;
}

pub inline fn sub(v1: anytype, v2: anytype) @TypeOf(v1, v2)
{
    return v1.values - v2.values;
}

pub inline fn dot(v1: anytype, v2: anytype, Te: anytype) Te
{
    return @reduce(.Add, v1 * v2);
}

pub inline fn swizzle(element_type: anytype, v: anytype, comptime len: u32, mask: @Vector(len, usize)) @TypeOf(v)
{
    return @shuffle(element_type, v, undefined, mask);
}