const std = @import("std");

const F64x2 = @Vector(2, f64);
const F64x3 = @Vector(3, f64);
const F64x4 = @Vector(4, f64);

const I64x2 = @Vector(2, i64);
const I64x3 = @Vector(3, i64);
const I64x4 = @Vector(4, i64);

pub const Vec2 = F64x2;
pub const Vec3 = F64x3;
pub const Vec4 = F64x4;

pub const IVec2 = F64x2;
pub const IVec3 = F64x3;
pub const IVec4 = F64x4;

pub const AxisComponent = enum(u8) { X = 0, Y = 1, Z = 2, W = 3 };

// ------------------------------------------------------------------------------
//
// 1. Initialization functions
//
// ------------------------------------------------------------------------------
pub fn new(T: type) T
{
    if (T == Vec2) 
    {
        return f64x2(0, 0);
    } 
    else if (T == Vec3) 
    {
        return f64x3(0, 0, 0);
    } 
    else if (T == Vec4)
    {
        return f64x4(0.0, 0.0, 0.0, 0.0);
    }
    else if (T == IVec2)
    {
        return i64x4(0.0, 0.0, 0.0, 0.0);
    }
    else if (T == IVec3)
    {
        return i64x4(0.0, 0.0, 0.0, 0.0);
    }
    else if (T == IVec4)
    {
        return i64x4(0.0, 0.0, 0.0, 0.0);
    }
}

pub fn newSplat(T: type, value: f64) T
{
    if (T == F64x2) 
    {
        return f64x2s(value);
    } 
    else if (T == F64x3) 
    {
        return f64x3(value);
    } 
    else if (T == F64x4)
    {
        return f64x4s(value);
    }
    else if (T == I64x2)
    {
        return i64x2s(value);
    }
    else if (T == I64x3)
    {
        return i64x3s(value);
    }
    else if (T == I64x4)
    {
        return i64x4s(value);
    }
}

fn f64x2(e0: f64, e1: f64) F64x2 
{
    return .{ e0, e1 };
}

fn f64x3(e0: f64, e1: f64, e2: f64) F64x4 
{
    return .{ e0, e1, e2 };
}

fn f64x4(e0: f64, e1: f64, e2: f64, e3: f64) F64x4 {
    return .{ e0, e1, e2, e3 };
}

fn i64x2(e0: i64, e1: i64) I64x2 
{
    return .{ e0, e1 };
}

fn i64x3(e0: f64, e1: f64, e2: f64) I64x3 
{
    return .{ e0, e1, e2 };
}

fn i64x4(e0: i64, e1: i64, e2: i64, e3: i64) I64x4 {
    return .{ e0, e1, e2, e3 };
}

fn f64x2s(val: f64) Vec2 
{
    return splat(F64x4, val);
}

fn f64x3s(val: f64) Vec3 
{
    return splat(F64x3, val);
}

fn f64x4s(val: f64) Vec4 
{
    return splat(F64x4, val);
}

fn i64x2s(val: f64) I64x2 
{
    return splat(I64x2, val);
}

fn i64x3s(val: f64) I64x3 
{
    return splat(I64x3, val);
}

fn i64x4s(val: i64) I64x4 
{
    return splat(I64x4, val);
}

// ------------------------------------------------------------------------------

pub fn splat(comptime T: type, value: anytype) T 
{
    if (T == F64x2 and @TypeOf(value) == f64) 
    {
        return f64x2s(f64, value);
    } 
    else if (T == F64x3 and @TypeOf(value) == f64) 
    {
        return f64x3s(f64, value);
    } 
    else if (T == F64x4 and @TypeOf(value) == f64)
    {
        return f64x4s(f64, value);
    }
    else if (T == I64x2 and @TypeOf(value) == i64)
    {
        return i64x2s(i64, value);
    }
    else if (T == I64x3 and @TypeOf(value) == i64)
    {
        return i64x3s(i64, value);
    }
    else if (T == I64x4 and @TypeOf(value) == i64)
    {
        return i64x4s(i64, value);
    }
    else 
    {
        @compileError("Incorrect type(s) passed to splat");
    }
}

pub inline fn num_elements(comptime T: type) comptime_int 
{
    return @typeInfo(T).Vector.len;
}

pub inline fn load(mem: []const f64, comptime T: type, comptime len: u32) T 
{
    var v = splat(T, 0.0);
    const loop_len = if (len == 0) num_elements(T) else len;
    comptime var i: u32 = 0;
    inline while (i < loop_len) : (i += 1) {
        v[i] = mem[i];
    }
    return v;
}

pub fn store(mem: []f32, v: anytype, comptime len: u32) void {
    const T = @TypeOf(v);
    const loop_len = if (len == 0) num_elements(T) else len;
    comptime var i: u32 = 0;
    inline while (i < loop_len) : (i += 1) {
        mem[i] = v[i];
    }
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
