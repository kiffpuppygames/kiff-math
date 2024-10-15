const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void 
{
    const target = b.standardTargetOptions(.{});    
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(
    .{
        .name = "kiff-math",
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });    
    b.installArtifact(lib);
   
    const lib_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    try setup_benchmark(b, target, optimize);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
}

fn setup_benchmark(b: *std.Build, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode ) !void
{
    const benchmark = b.addExecutable(.{
        .name = "benchmark",
        .root_source_file = b.path("src/benchmark.zig"),
        .target = target,
        .optimize = optimize,
    });

    const zmath = b.dependency("zmath", .{
        .target = target,
        .optimize = optimize,
    });
    benchmark.root_module.addImport("zmath", zmath.module("root"));
    b.installArtifact(benchmark);
    const run_benchmark = b.addRunArtifact(benchmark);
    const benchmark_step = b.step("benchmark", "Run benchmarks");
    
    benchmark_step.dependOn(&run_benchmark.step);
}
