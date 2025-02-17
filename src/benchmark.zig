const std = @import("std");
const kmath = @import("root.zig");
const zbench = @import("zbench");

const ITERATIONS: usize = 3_000_000_000;
const TIME_LIMIT: usize = 2_000_000_000;
const RUNS: usize = 5;

const a: f64 = 1.23456789012345678901234567890123456789;
const b: f64 = -9.87654321098765432109876543210987654321;
const c: f64 = 3.141592653589793238462643383279502884197;
const d: f64 = -2.718281828459045235360287471352662497757;

const q1 = kmath.Quat { .values = .{a, b, c, d} };
const q2 = kmath.Quat { .values = .{d, c, b, a} };
const v1 = kmath.Vec3 { .values = .{ b, c, d } };
const v2 = kmath.Vec3 { .values = .{ a, d, b } };

pub fn main() !void 
{
    const stdout = std.io.getStdOut().writer();
    var bench = zbench.Benchmark.init(std.heap.page_allocator, .{ .max_iterations = ITERATIONS, .time_budget_ns = TIME_LIMIT * 7 });
    defer bench.deinit();

    try bench.add("Quaternion Multiplication", quat_mul_bench_kmath, .{ .max_iterations = ITERATIONS, .time_budget_ns = TIME_LIMIT });
    try bench.add("Quaternion Inverse", quat_inv_bench_kmath, .{  .max_iterations = ITERATIONS, .time_budget_ns = TIME_LIMIT });
    try bench.add("Quaternion Rotate", quat_rotate_vec_bench, .{  .max_iterations = ITERATIONS, .time_budget_ns = TIME_LIMIT });
    try bench.add("Quaternion Slerp", quat_slerp_bench_kmath, .{  .max_iterations = ITERATIONS, .time_budget_ns = TIME_LIMIT });
    try bench.add("Vec3 Scalar Multiplication", mul_s_bench_kmath, .{  .max_iterations = ITERATIONS, .time_budget_ns = TIME_LIMIT });
    try bench.add("Vec3 Magnitude", mag_bench_kmath, .{  .max_iterations = ITERATIONS, .time_budget_ns = TIME_LIMIT });
    try bench.add("Vec3 Normalize", normalize_bench_kmath, .{  .max_iterations = ITERATIONS, .time_budget_ns = TIME_LIMIT });

    try stdout.writeAll("\n");

    warm_cpu();

    try bench.run(stdout);
}

fn warm_cpu() void 
{
    var sum: f64 = 0;
    const num_iterations: u32 = 1000000;
    for (0..num_iterations) |i| {
        sum += @as(f64, @floatFromInt(i)) * @as(f64, @floatFromInt(i));
    }
    std.mem.doNotOptimizeAway(&sum);
}

fn quat_mul_bench_kmath(allocator: std.mem.Allocator) void
{
    _ = allocator;
    const r = q1.mul(q2);
    std.mem.doNotOptimizeAway(&r);
}

fn quat_inv_bench_kmath(allocator: std.mem.Allocator) void
{
    _ = allocator;
    const r = q1.inverse();
    std.mem.doNotOptimizeAway(&r);
}

fn quat_rotate_vec_bench(allocator: std.mem.Allocator) void
{
    _ = allocator;
    const r = q2.normalize().apply_to_vector(v2);
    std.mem.doNotOptimizeAway(&r);
}

fn mul_s_bench_kmath(allocator: std.mem.Allocator) void
{
    _ = allocator;
    const prod = v1.mull_s(a);
    std.mem.doNotOptimizeAway(&prod);
}

fn mag_bench_kmath(allocator: std.mem.Allocator) void
{
    _ = allocator;
    const r = v1.mag();
    std.mem.doNotOptimizeAway(&r);
}

fn normalize_bench_kmath(allocator: std.mem.Allocator) void
{
    _ = allocator;
    const r = v2.normalize();
    std.mem.doNotOptimizeAway(&r);
}

fn quat_slerp_bench_kmath(allocator: std.mem.Allocator) void
{
    _ = allocator;    
    const r = kmath.quaternions.slerp(q1.values, q2.values, d);
    std.mem.doNotOptimizeAway(&r);
}