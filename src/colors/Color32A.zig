const colors = @import("colors.zig");
const cast_utils = @import("../cast_utils.zig");

const Color32A = @This();

values: @Vector(4, f32),

pub fn new(R: f32, G: f32, B: f32, A: f32) Color32A
{
    return colors.new(Color32A, f32, 4, 4, .{ R, G, B, A });
}

pub fn splat(value: f32) Color32A
{
    return .colors.new(Color32A, f32, 4, 1, .{ value } );
}

pub fn from_array(arr: [4]f32) Color32A
{
    return colors.new(Color32A, f32, 4, 1, arr );
}

pub fn from_color_64A(color: colors.Color64A) Color32A
{
    return .{ .values = .{ cast_utils.f32_from_f64(color.r()), cast_utils.f32_from_f64(color.g()), cast_utils.f32_from_f64(color.b()), cast_utils.f32_from_f64(color.a())} };
}

pub fn black() Color32A
{
    return .{ .values = .{ 0, 0, 0, 1} };
}

pub fn white() Color32A
{
    return .{ .values = .{ 1, 1, 1, 1} };
}

pub fn red() Color32A
{
    return .{ .values = .{ 1, 0, 0, 1} };
}

pub fn green() Color32A
{
    return .{ .values = .{ 0, 1, 0, 1} };
}

pub fn blue() Color32A
{
    return .{ .values = .{ 0, 0, 1, 1} };
}

pub fn magenta() Color32A
{
    return .{ .values = .{ 1, 0, 1, 1} };
}

pub fn r(self: *const Color32A) f32
{
    return self.values[0];
}

pub fn g(self: *const Color32A) f32
{
    return self.values[1];
}

pub fn b(self: *const Color32A) f32
{
    return self.values[2];
}

pub fn a(self: *const Color32A) f32
{
    return self.values[3];
}

pub fn add(self: Color32A, other: Color32A) Color32A
{
    return .{ .values = self.values + other.values };
}

pub fn sub(self: *const Color32A, other: Color32A) Color32A
{
    return .{ .values = self.values - other.values };
}

pub fn to_array(self: *Color32A) [4]f32 
{
    return .{ self.values[0], self.values[1], self.values[2], self.values[3] };
}