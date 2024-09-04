const std = @import("std");

pub const F32x4 = @Vector(4, f32);
pub const F32x8 = @Vector(8, f32);
pub const F32x16 = @Vector(16, f32);

pub const Boolx4 = @Vector(4, bool);
pub const Boolx8 = @Vector(8, bool);
pub const Boolx16 = @Vector(16, bool);

pub const Vec = F32x4;

pub const F32x4Component = enum { x, y, z, w };

// ------------------------------------------------------------------------------
//
// 1. Initialization functions
//
// ------------------------------------------------------------------------------
pub inline fn f32x4(e0: f32, e1: f32, e2: f32, e3: f32) F32x4 {
    return .{ e0, e1, e2, e3 };
}

pub inline fn f32x8(e0: f32, e1: f32, e2: f32, e3: f32, e4: f32, e5: f32, e6: f32, e7: f32) F32x8 {
    return .{ e0, e1, e2, e3, e4, e5, e6, e7 };
}

pub inline fn f32x16(e0: f32, e1: f32, e2: f32, e3: f32, e4: f32, e5: f32, e6: f32, e7: f32, e8: f32, e9: f32, ea: f32, eb: f32, ec: f32, ed: f32, ee: f32, ef: f32) F32x16 {
    return .{ e0, e1, e2, e3, e4, e5, e6, e7, e8, e9, ea, eb, ec, ed, ee, ef };
}

pub inline fn f32x4s(e0: f32) F32x4 {
    return splat(F32x4, e0);
}
pub inline fn f32x8s(e0: f32) F32x8 {
    return splat(F32x8, e0);
}
pub inline fn f32x16s(e0: f32) F32x16 {
    return splat(F32x16, e0);
}

pub inline fn boolx4(e0: bool, e1: bool, e2: bool, e3: bool) Boolx4 {
    return .{ e0, e1, e2, e3 };
}
pub inline fn boolx8(e0: bool, e1: bool, e2: bool, e3: bool, e4: bool, e5: bool, e6: bool, e7: bool) Boolx8 {
    return .{ e0, e1, e2, e3, e4, e5, e6, e7 };
}

pub inline fn boolx16(e0: bool, e1: bool, e2: bool, e3: bool, e4: bool, e5: bool, e6: bool, e7: bool, e8: bool, e9: bool, ea: bool, eb: bool, ec: bool, ed: bool, ee: bool, ef: bool) Boolx16 {
    return .{ e0, e1, e2, e3, e4, e5, e6, e7, e8, e9, ea, eb, ec, ed, ee, ef };
}

pub inline fn splat(comptime T: type, value: f32) T {
    return @splat(value);
}

pub inline fn splatInt(comptime T: type, value: u32) T {
    return @splat(@bitCast(value));
}

pub inline fn loadArr2(arr: [2]f32) F32x4 {
    return f32x4(arr[0], arr[1], 0.0, 0.0);
}
pub inline fn loadArr2zw(arr: [2]f32, z: f32, w: f32) F32x4 {
    return f32x4(arr[0], arr[1], z, w);
}
pub inline fn loadArr3(arr: [3]f32) F32x4 {
    return f32x4(arr[0], arr[1], arr[2], 0.0);
}
pub inline fn loadArr3w(arr: [3]f32, w: f32) F32x4 {
    return f32x4(arr[0], arr[1], arr[2], w);
}
pub inline fn loadArr4(arr: [4]f32) F32x4 {
    return f32x4(arr[0], arr[1], arr[2], arr[3]);
}

pub inline fn storeArr2(arr: *[2]f32, v: F32x4) void {
    arr.* = .{ v[0], v[1] };
}
pub inline fn storeArr3(arr: *[3]f32, v: F32x4) void {
    arr.* = .{ v[0], v[1], v[2] };
}
pub inline fn storeArr4(arr: *[4]f32, v: F32x4) void {
    arr.* = .{ v[0], v[1], v[2], v[3] };
}

pub inline fn arr3Ptr(ptr: anytype) *const [3]f32 {
    comptime std.debug.assert(@typeInfo(@TypeOf(ptr)) == .Pointer);
    const T = std.meta.Child(@TypeOf(ptr));
    comptime std.debug.assert(T == F32x4);
    return @as(*const [3]f32, @ptrCast(ptr));
}

pub inline fn vecToArr2(v: Vec) [2]f32 {
    return .{ v[0], v[1] };
}
pub inline fn vecToArr3(v: Vec) [3]f32 {
    return .{ v[0], v[1], v[2] };
}
pub inline fn vecToArr4(v: Vec) [4]f32 {
    return .{ v[0], v[1], v[2], v[3] };
}
