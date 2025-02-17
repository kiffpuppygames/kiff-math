const std = @import("std");
const vectors = @import("../vectors.zig");

test "Magnitude"
{
    const q = @Vector(4, f64) {1, 2, 3, 4};

    const mag = vectors.magnitude(q);

    const expected: f64 = 5.477225575051661;
    try std.testing.expectApproxEqAbs(expected, mag, std.math.floatEps(f64));
}

test "Normalize"
{
    const q = @Vector(4, f64) {1, 2, 3, 4};

    const normalized = vectors.normalize(q);
    
    try std.testing.expectApproxEqAbs(0.18257418583505536, normalized[0], std.math.floatEps(f64));
    try std.testing.expectApproxEqAbs(0.3651483716701107, normalized[1], std.math.floatEps(f64));
    try std.testing.expectApproxEqAbs(0.5477225575051661, normalized[2], std.math.floatEps(f64));
    try std.testing.expectApproxEqAbs(0.7302967433402214, normalized[3], std.math.floatEps(f64));
}