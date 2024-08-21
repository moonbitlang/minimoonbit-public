const std = @import("std");

const Target = std.Target;

pub fn build(b: *std.Build) void {
    const cpu_model = Target.Query.CpuModel{ .explicit = Target.Cpu.Model.baseline(Target.Cpu.Arch.riscv64) };
    var disabled_features = Target.Cpu.Feature.Set.empty;
    disabled_features.addFeature(@intFromEnum(Target.riscv.Feature.c));

    const target = Target.Query{
        .cpu_arch = .riscv64,
        .os_tag = .linux,
        .cpu_model = cpu_model,
        .cpu_features_sub = disabled_features,
    };

    const libmincaml = b.addStaticLibrary(.{
        .name = "mincaml",
        .root_source_file = b.path("src/start.zig"),
        .target = b.resolveTargetQuery(target),
        .strip = false,
        .optimize = .Debug,
    });

    b.installArtifact(libmincaml);
}
