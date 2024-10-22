const std = @import("std");

pub const vectors = @import("vectors.zig");
pub const quaternions = @import("Quat.zig");

comptime {
    _ = vectors;
    _ = quaternions;
}