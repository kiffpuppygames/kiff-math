const std = @import("std");
const kmath = @import("root.zig");
const zmath = @import("zmath");
const mach = @import("mach");

pub fn main() !void 
{
    std.debug.print("Running Benchmarks:\n\n", .{});

    std.debug.print("Quaternion Multiplication ({s}):\n", .{ @typeName(kmath.Quat32) });
    for (0..3) |i|
    {
        std.debug.print("\tRun {d}:\n", .{ i + 1 });
        try quat_mul_bench(kmath.Quat32, 10_000_000_00);
    }

    std.debug.print("Quaternion Multiplication ({s}):\n", .{ @typeName(kmath.Quat) });
    for (0..3) |i|
    {
        std.debug.print("\tRun {d}:\n", .{ i + 1 });
        try quat_mul_bench(kmath.Quat, 10_000_000_00);
    }

    std.debug.print("Magnitude ({s}):\n", .{ @typeName(kmath.Quat) });
    for (0..3) |i|
    {
        std.debug.print("\tRun {d}:\n", .{ i + 1 });
        try mag_bench(kmath.Quat, 10_000_000_00);
    }

    std.debug.print("Normalize ({s}):\n", .{ @typeName(kmath.Quat) });
    for (0..3) |i|
    {
        std.debug.print("\tRun {d}:\n", .{ i + 1 });
        try normalize_bench(kmath.Quat, 10_000_000_00);
    }
}

fn quat_mul_bench(T: anytype, iterations: usize) !void
{
    const q1 = T { .values = .{1, 0, 1, 0} };
    const q2 = T{ .values = .{1, 0.5, 0.5, 0.75} };

    {
        std.debug.print("\t\tWarming up...", .{});
        for (0..iterations) |_|
        {
            const r = q1.mul(q2);
            std.mem.doNotOptimizeAway(&r);
        }

        var timer = try std.time.Timer.start();        
        var elapsed_s: f64 = 0;
        for (0..3) |_| 
        {
            for (0..iterations) |_|
            {
                const r = q1.mul(q2);
                std.mem.doNotOptimizeAway(&r);
            }
            elapsed_s += @as(f64, @floatFromInt(timer.lap())) / std.time.ns_per_s;
        }
        
        std.debug.print("KMath, average(x3) time taken: {d:.4}s\n", .{elapsed_s / 3});
    }

    if (T == kmath.Quat32)
    {
        {
            std.debug.print("\t\tWarming up...", .{});
            for (0..iterations) |_|
            {
                const r = zmath.qmul(q1.values, q2.values);
                std.mem.doNotOptimizeAway(&r);
            }

            var timer = try std.time.Timer.start();        
            var elapsed_s: f64 = 0;
            for (0..3) |_| 
            {
                for (0..iterations) |_|
                {
                    const r = zmath.qmul(q1.values, q2.values);
                    std.mem.doNotOptimizeAway(&r);
                }

                elapsed_s += @as(f64, @floatFromInt(timer.lap())) / std.time.ns_per_s;
            }  

            std.debug.print("ZMath, average(x3) time taken: {d:.4}s\n", .{elapsed_s / 3});    
        }
    }
    else 
    {
        std.debug.print("\t\tZMath does not support 64bit floating points...\n", .{});
    }
}

fn mag_bench(T: anytype, iterations: usize) !void
{
    const q = T { .values = .{1.75, 0.667, 1.78932, 125.6} };

    {
        std.debug.print("\t\tWarming up...", .{});
        for (0..iterations) |_|
        {
            const r = q.mag();
            std.mem.doNotOptimizeAway(&r);
        }

        var timer = try std.time.Timer.start();        
        var elapsed_s: f64 = 0;
        for (0..3) |_| 
        {
            for (0..iterations) |_|
            {
                const r = q.mag();
                std.mem.doNotOptimizeAway(&r);
            }
            elapsed_s += @as(f64, @floatFromInt(timer.lap())) / std.time.ns_per_s;
        }
        
        std.debug.print("KMath, average(x3) time taken: {d:.4}s\n", .{elapsed_s / 3});
    }
}

fn normalize_bench(T: anytype, iterations: usize) !void
{
    const q = T { .values = .{2.75, 1.667, 3.78932, 125.76} };

    {
        std.debug.print("\t\tWarming up...", .{});
        for (0..iterations) |_|
        {
            const r = q.normalize();
            std.mem.doNotOptimizeAway(&r);
        }

        var timer = try std.time.Timer.start();        
        var elapsed_s: f64 = 0;
        for (0..3) |_| 
        {
            for (0..iterations) |_|
            {
                const r = q.normalize();
                std.mem.doNotOptimizeAway(&r);
            }
            elapsed_s += @as(f64, @floatFromInt(timer.lap())) / std.time.ns_per_s;
        }
        
        std.debug.print("KMath, average(x3) time taken: {d:.4}s\n", .{elapsed_s / 3});
    }
}