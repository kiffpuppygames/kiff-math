const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void 
{
    const target = b.standardTargetOptions(.{});    
    const optimize = b.standardOptimizeOption(.{});

    const zbench_module = b.dependency("zbench", .{ .target = target, .optimize = optimize }).module("zbench");

    const lib = b.addStaticLibrary(
    .{
        .name = "kiff-math",
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });    
    b.installArtifact(lib);
   
    const lib_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/tests.zig"),
        .target = target,
        .optimize = optimize,
    });
    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);
    
    try setup_benchmark(b, target, optimize, zbench_module);

    const test_check = b.addExecutable(.{
        .name = "kiff-engine",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    test_check.root_module.addImport("zbench", zbench_module);
    b.installArtifact(test_check);

    // These two lines you might want to copy
    // (make sure to rename 'exe_check')
    const check = b.step("check", "Test Check");
    check.dependOn(&test_check.step);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
}

fn setup_benchmark(b: *std.Build, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode, mod: *std.Build.Module ) !void
{
    const benchmark = b.addExecutable(.{
        .name = "benchmark",
        .root_source_file = b.path("src/benchmark.zig"),
        .target = target,
        .optimize = optimize,
    });
    benchmark.root_module.addImport("zbench", mod);
    b.installArtifact(benchmark);
    const run_benchmark = b.addRunArtifact(benchmark);
    const benchmark_step = b.step("benchmark", "Run benchmarks");
    
    benchmark_step.dependOn(&run_benchmark.step);
}
