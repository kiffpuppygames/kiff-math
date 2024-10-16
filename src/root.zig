const std = @import("std");

pub const vectors = @import("vectors.zig");
pub const quaternions = @import("quaternions.zig");

pub const Vec3 = @import("Vec3.zig");
pub const Vec3_32 = @import("Vec3_32.zig");
pub const Quat = @import("Quat.zig");
pub const Quat32 = @import("Quat32.zig");

comptime {
    _ = quaternions;
}