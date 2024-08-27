const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    const options = .{
        .optimize = b.option(
            std.builtin.OptimizeMode,
            "optimize",
            "Select optimization mode",
        ) orelse b.standardOptimizeOption(.{
            .preferred_optimize_mode = .ReleaseFast,
        }),
        .enable_cross_platform_determinism = b.option(
            bool,
            "enable_cross_platform_determinism",
            "Enable cross-platform determinism",
        ) orelse true,
    };

    const options_step = b.addOptions();
    inline for (std.meta.fields(@TypeOf(options))) |field| {
        options_step.addOption(field.type, field.name, @field(options, field.name));
    }

    const options_module = options_step.createModule();

    const kmath = b.addModule("root", .{
        .root_source_file = b.path("src/main.zig"),
        .imports = &.{
            .{ .name = "kmath_options", .module = options_module },
        },
    });

    const test_step = b.step("test", "Run kmath tests");

    const tests = b.addTest(.{
        .name = "kmath-tests",
        .root_source_file = b.path("src/run_tests.zig"),
        .target = target,
        .optimize = options.optimize,
    });
    b.installArtifact(tests);

    tests.root_module.addImport("kmath_options", options_module);

    test_step.dependOn(&b.addRunArtifact(tests).step);

    const benchmark_step = b.step("benchmark", "Run kmath benchmarks");

    const benchmarks = b.addExecutable(.{
        .name = "kmath-benchmarks",
        .root_source_file = b.path("src/benchmark.zig"),
        .target = target,
        .optimize = options.optimize,
    });
    b.installArtifact(benchmarks);

    benchmarks.root_module.addImport("kmath", kmath);

    benchmark_step.dependOn(&b.addRunArtifact(benchmarks).step);
}
