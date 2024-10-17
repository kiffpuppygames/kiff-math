const std = @import("std");
const kmath = @import("root.zig");
const zmath = @import("zmath");

var prng = std.Random.DefaultPrng.init(0);
const random = prng.random();

pub fn main() !void 
{
    std.debug.print("Running Benchmarks:\n\n", .{});
    const iterations = 10_000_000_00;

    try quat_mul_bench_kmath(iterations);
    
    std.debug.print("Quaternion Inverse KMath (f64):\n", .{ });
    for (0..3) |i|
    {
        std.debug.print("\tRun {d}:\n", .{ i + 1 });
        try quat_inv_bench_kmath(10_000_000_00);
    }
    

    try quat_mul_bench_zmath(iterations);
    

    // std.debug.print("Quaternion Inverse ZMath (f32):\n", .{});
    // for (0..3) |i|
    // {
    //     std.debug.print("\tRun {d}:\n", .{ i + 1 });
    //     try quat_inv_bench_zmath(10_000_000_00);
    // }

    

    

    

    // std.debug.print("Magnitude ({s}):\n", .{ @typeName(kmath.Quat) });
    // for (0..3) |i|
    // {
    //     std.debug.print("\tRun {d}:\n", .{ i + 1 });
    //     try mag_bench(kmath.Quat, 10_000_000_00);
    // }

    // std.debug.print("Normalize ({s}):\n", .{ @typeName(kmath.Quat) });
    // for (0..3) |i|
    // {
    //     std.debug.print("\tRun {d}:\n", .{ i + 1 });
    //     try normalize_bench(kmath.Quat, 10_000_000_00);
    // }
}

fn quat_mul_bench_kmath(iterations: usize) !void
{
    std.debug.print("Quaternion Multiplication KMath (f64):\n", .{ });    
    const q1 = kmath.Quat { .values = .{random.float(f64), random.float(f64), random.float(f64), random.float(f64)} };
    const q2 = kmath.Quat { .values = .{random.float(f64), random.float(f64), random.float(f64), random.float(f64)} };
    const runs = 6;

    std.debug.print("\tWarming up...", .{});
    for (0..iterations) |_|
    {
        const r = q1.mul(q2);
        std.mem.doNotOptimizeAway(&r);
    }

    var timer = try std.time.Timer.start();        
    var elapsed_s: f64 = 0;
    for (0..runs) |_| 
    {
        for (0..iterations) |_|
        {
            const r = q1.mul(q2);
            std.mem.doNotOptimizeAway(&r);
        }
        elapsed_s += @as(f64, @floatFromInt(timer.lap())) / std.time.ns_per_s;
    }
    
    std.debug.print("\t{d} Runs at {d} iterations Average: {d:.4}s\n", .{ runs, iterations, elapsed_s / runs});  
}

fn quat_mul_bench_zmath(iterations: usize) !void
{
    std.debug.print("Quaternion Multiplication ZMath (f32):\n", .{ });
    const q1 = zmath.Quat {random.float(f32), random.float(f32), random.float(f32), random.float(f32)};
    const q2 = zmath.Quat { random.float(f32), random.float(f32), random.float(f32), random.float(f32)};
    const runs = 6;

    std.debug.print("\tWarming up... ", .{ });
    for (0..iterations) |_|
    {
        const r = zmath.qmul(q1, q2);
        std.mem.doNotOptimizeAway(&r);
    }

    var timer = try std.time.Timer.start();        
    var elapsed_s: f64 = 0;
    for (0..runs) |_| 
    {
        for (0..iterations) |_|
        {
            const r = zmath.qmul(q1, q2);
            std.mem.doNotOptimizeAway(&r);
        }

        elapsed_s += @as(f64, @floatFromInt(timer.lap())) / std.time.ns_per_s;
    } 

    std.debug.print("\t{d} Runs at {d} iterations Average: {d:.4}s\n", .{ runs, iterations, elapsed_s / runs});  
}

fn quat_inv_bench_kmath_32(iterations: usize) !void
{
    const q = kmath.Quat32 { .values = .{random.float(f32), random.float(f32), random.float(f32), random.float(f32) } };
    std.debug.print("\t\tWarming up...", .{});
    for (0..iterations) |_|
    {
        const r = q.inverse();
        std.mem.doNotOptimizeAway(&r);
    }

    var timer = try std.time.Timer.start();        
    var elapsed_s: f64 = 0;
    for (0..3) |_| 
    {
        for (0..iterations) |_|
        {
            const r = q.inverse();
            std.mem.doNotOptimizeAway(&r);
        }
        elapsed_s += @as(f64, @floatFromInt(timer.lap())) / std.time.ns_per_s;
    }
    
    std.debug.print("KMath, average(x3) time taken: {d:.4}s\n", .{elapsed_s / 3});
}

fn quat_inv_bench_zmath(iterations: usize) !void
{
    const q = zmath.Quat { random.float(f32), random.float(f32), random.float(f32), random.float(f32) };
    std.debug.print("\t\tWarming up...", .{});
    for (0..iterations) |_|
    {
        const r = zmath.inverse(q);
        std.mem.doNotOptimizeAway(&r);
    }

    var timer = try std.time.Timer.start();        
    var elapsed_s: f64 = 0;
    for (0..3) |_| 
    {
        for (0..iterations) |_|
        {
            const r = zmath.inverse(q);
            std.mem.doNotOptimizeAway(&r);
        }

        elapsed_s += @as(f64, @floatFromInt(timer.lap())) / std.time.ns_per_s;
    }  

    std.debug.print("ZMath, average(x3) time taken: {d:.4}s\n", .{elapsed_s / 3});    
}

fn quat_inv_bench_kmath(iterations: usize) !void
{
    {
        const q = kmath.Quat { .values = .{random.float(f64), random.float(f64), random.float(f64), random.float(f64) } };
        std.debug.print("\t\tWarming up...", .{});
        for (0..iterations) |_|
        {
            const r = q.inverse();
            std.mem.doNotOptimizeAway(&r);
        }

        var timer = try std.time.Timer.start();        
        var elapsed_s: f64 = 0;
        for (0..3) |_| 
        {
            for (0..iterations) |_|
            {
                const r = q.inverse();
                std.mem.doNotOptimizeAway(&r);
            }
            elapsed_s += @as(f64, @floatFromInt(timer.lap())) / std.time.ns_per_s;
        }
        
        std.debug.print("KMath, average(x3) time taken: {d:.4}s\n", .{elapsed_s / 3});
    }
}

fn mag_bench(T: anytype, iterations: usize) !void
{
    const q = T { .values = .{ random.float(f64), random.float(f64), random.float(f64), random.float(f64)} };

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
    const q = T { .values = .{ random.float(f64), random.float(f64), random.float(f64), random.float(f64)} };

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