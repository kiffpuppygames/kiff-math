const std = @import("std");

pub const Pi: f64 = 3.1415926535897932384626433832795028841971693993751058209749445923078164062862089986280348253421170679;
pub const Tau: f64 = Pi * 2;

pub inline fn sin(theta: anytype) @TypeOf(theta)
{
    return @sin(theta);
}

pub inline fn cos(theta: anytype) @TypeOf(theta)
{
    return @cos(theta);
}

pub inline fn tan(theta: anytype) @TypeOf(theta)
{
    const T = @TypeOf(theta);
    
    if (T != f64 or @Type(T).kind != .Vector)

    return @tan(theta);
}