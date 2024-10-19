const std = @import("std");
const kmath = @import("root.zig");
const zmath = @import("zmath");

var prng = std.Random.DefaultPrng.init(0);
const random = prng.random();

const ITERATIONS: usize = 500_000_000;
const RUNS: usize = 5;

pub fn main() !void 
{
    std.debug.print("Running Benchmarks: (The average over {d} runs with {d} iterations each)\n", .{ RUNS, ITERATIONS });

    std.debug.print("\tQuaternions: \n", .{});
    
    try quat_mul_bench_kmath();
    try quat_mul_bench_zmath();
    
    try quat_inv_bench_kmath();
    try quat_inv_bench_zmath();

    try quat_rotate_vec_bench();

    std.debug.print("\tVectors: \n", .{});
    try mul_s_bench_kmath();
    try mag_bench_kmath();
    try normalize_bench_kmath();
}

fn quat_mul_bench_kmath() !void
{
    std.debug.print("\t\tMultiplication KMath (f64): ", .{ });    
    const q1 = kmath.Quat { .values = .{random.float(f64), random.float(f64), random.float(f64), random.float(f64)} };
    const q2 = kmath.Quat { .values = .{random.float(f64), random.float(f64), random.float(f64), random.float(f64)} };

    std.debug.print("Warming up... ", .{});
    const sum_q1 = @reduce(.Add, q1.values);
    const sum_q2 = @reduce(.Add, q2.values);
    std.mem.doNotOptimizeAway(&sum_q1);
    std.mem.doNotOptimizeAway(&sum_q2);

    var timer = try std.time.Timer.start();        
    var elapsed_s: f64 = 0;
    for (0..RUNS) |_| 
    {
        for (0..ITERATIONS) |_|
        {
            const r = q1.mul(q2);
            std.mem.doNotOptimizeAway(&r);
        }
        elapsed_s += @as(f64, @floatFromInt(timer.lap())) / std.time.ns_per_s;
    }
    
    std.debug.print("Time taken: {d:.4}s\n", .{ elapsed_s / RUNS });  
}

fn quat_mul_bench_zmath() !void
{
    std.debug.print("\t\tMultiplication ZMath (f32): ", .{ });
    const q1 = zmath.Quat { random.float(f32), random.float(f32), random.float(f32), random.float(f32)};
    const q2 = zmath.Quat { random.float(f32), random.float(f32), random.float(f32), random.float(f32)};

    std.debug.print("Warming up... ", .{});
    const sum_q1 = @reduce(.Add, q1);
    const sum_q2 = @reduce(.Add, q2);
    std.mem.doNotOptimizeAway(&sum_q1);
    std.mem.doNotOptimizeAway(&sum_q2);

    var timer = try std.time.Timer.start();        
    var elapsed_s: f64 = 0;
    for (0..RUNS) |_| 
    {
        for (0..ITERATIONS) |_|
        {
            const r = zmath.qmul(q1, q2);
            std.mem.doNotOptimizeAway(&r);
        }

        elapsed_s += @as(f64, @floatFromInt(timer.lap())) / std.time.ns_per_s;
    } 

    std.debug.print("Time taken: {d:.4}s\n", .{ elapsed_s / RUNS});  
}

fn quat_inv_bench_kmath() !void
{
    std.debug.print("\t\tInverse KMath (f64): ", .{ });    
    const q = kmath.Quat { .values = .{random.float(f64), random.float(f64), random.float(f64), random.float(f64) } };

    std.debug.print("Warming up... ", .{});
    const sum_q = @reduce(.Add, q.values);
    std.mem.doNotOptimizeAway(&sum_q);

    var timer = try std.time.Timer.start();        
    var elapsed_s: f64 = 0;
    for (0..RUNS) |_| 
    {
        for (0..ITERATIONS) |_|
        {
            const r = q.inverse();
            std.mem.doNotOptimizeAway(&r);
        }
        elapsed_s += @as(f64, @floatFromInt(timer.lap())) / std.time.ns_per_s;
    }
    
    std.debug.print("Time taken: {d:.4}s\n", .{ elapsed_s / RUNS});  
}

fn quat_inv_bench_zmath() !void
{    
    std.debug.print("\t\tInverse ZMath (f32): ", .{});
    const q = zmath.Quat { random.float(f32), random.float(f32), random.float(f32), random.float(f32) };
    
    std.debug.print("Warming up... ", .{});
    const sum_q = @reduce(.Add, q);
    std.mem.doNotOptimizeAway(&sum_q);

    var timer = try std.time.Timer.start();        
    var elapsed_s: f64 = 0;
    for (0..RUNS) |_| 
    {
        for (0..ITERATIONS) |_|
        {
            const r = zmath.inverse(q);
            std.mem.doNotOptimizeAway(&r);
        }

        elapsed_s += @as(f64, @floatFromInt(timer.lap())) / std.time.ns_per_s;
    }  

    std.debug.print("Time taken: {d:.4}s\n", .{elapsed_s / RUNS});    
}

fn quat_rotate_vec_bench() !void
{
    std.debug.print("\t\tRotate Vec (f64): ", .{});
    const q = kmath.Quat.new(random.float(f64), random.float(f64), random.float(f64), random.float(f64));    
    const v = kmath.Vec3.new(random.float(f64), random.float(f64), random.float(f64));
    
    std.debug.print("Warming up... ", .{});
    const sum_q = @reduce(.Add, q.values);
    std.mem.doNotOptimizeAway(&sum_q);
    const sum_v = @reduce(.Add, v.values);
    std.mem.doNotOptimizeAway(&sum_v);

    var timer = try std.time.Timer.start();        
    var elapsed_s: f64 = 0;
    for (0..RUNS) |_| 
    {
        for (0..ITERATIONS) |_|
        {
            const r = q.normalize().apply_to_vector(v);
            std.mem.doNotOptimizeAway(&r);
        }

        elapsed_s += @as(f64, @floatFromInt(timer.lap())) / std.time.ns_per_s;
    }  

    std.debug.print("Time taken: {d:.4}s\n", .{elapsed_s / RUNS});    
}

fn mul_s_bench_kmath() !void
{
    std.debug.print("\t\tMultiply Scalar KMath (f64): ", .{ });
    const v = kmath.Vec3 { .values = .{ random.float(f64), random.float(f64), random.float(f64) } };
    const s = random.float(f64);
    
    std.debug.print("Warming up... ", .{});
    const sum_v = @reduce(.Add, v.values);
    std.mem.doNotOptimizeAway(&sum_v);
    const r = s + random.float(f64);
    std.mem.doNotOptimizeAway(&r); 

    var timer = try std.time.Timer.start();        
    var elapsed_s: f64 = 0;
    for (0..RUNS) |_| 
    {
        for (0..ITERATIONS) |_|
        {
            const prod = v.mull_s(s);
            std.mem.doNotOptimizeAway(&prod);
        }
        elapsed_s += @as(f64, @floatFromInt(timer.lap())) / std.time.ns_per_s;
    }
    
    std.debug.print("Time taken: {d:.4}s\n", .{elapsed_s / RUNS});
}

fn mag_bench_kmath() !void
{
    std.debug.print("\t\tMagnitude KMath (f64): ", .{ });
    const v = kmath.Vec3 { .values = .{ random.float(f64), random.float(f64), random.float(f64) } };
    
    std.debug.print("Warming up... ", .{});
    const sum_v = @reduce(.Add, v.values);
    std.mem.doNotOptimizeAway(&sum_v);

    var timer = try std.time.Timer.start();        
    var elapsed_s: f64 = 0;
    for (0..RUNS) |_| 
    {
        for (0..ITERATIONS) |_|
        {
            const r = v.mag();
            std.mem.doNotOptimizeAway(&r);
        }
        elapsed_s += @as(f64, @floatFromInt(timer.lap())) / std.time.ns_per_s;
    }
    
    std.debug.print("Time taken: {d:.4}s\n", .{elapsed_s / RUNS});
}

fn normalize_bench_kmath() !void
{
    std.debug.print("\t\tNormalize KMath (f64): ", .{ });
    const v = kmath.Vec3.new(random.float(f64), random.float(f64), random.float(f64));

    std.debug.print("Warming up... ", .{});
    const sum_v = @reduce(.Add, v.values);
    std.mem.doNotOptimizeAway(&sum_v);

    var timer = try std.time.Timer.start();        
    var elapsed_s: f64 = 0;
    for (0..RUNS) |_| 
    {
        for (0..ITERATIONS) |_|
        {
            const r = v.normalize();
            std.mem.doNotOptimizeAway(&r);
        }
        elapsed_s += @as(f64, @floatFromInt(timer.lap())) / std.time.ns_per_s;
    }
    
    std.debug.print("Time taken: {d:.4}s\n", .{elapsed_s / RUNS});
}