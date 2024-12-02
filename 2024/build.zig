const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    for (1..26) |i| {
        const name = try std.fmt.allocPrint(b.allocator, "day-{any}", .{i});
        const path = try std.fmt.allocPrint(b.allocator, "src/{s}.zig", .{name});

        const exe = b.addExecutable(.{
            .name = name,
            .root_source_file = b.path(path),
            .target = target,
            .optimize = optimize,
        });

        b.installArtifact(exe);

        const run_cmd = b.addRunArtifact(exe);
        run_cmd.step.dependOn(b.getInstallStep());

        if (b.args) |args| {
            run_cmd.addArgs(args);
        }

        const run_name = try std.fmt.allocPrint(b.allocator, "run-{s}", .{name});
        const run_description = try std.fmt.allocPrint(b.allocator, "Run day {any}", .{i});
        const run_step = b.step(run_name, run_description);
        run_step.dependOn(&run_cmd.step);
    }
}
