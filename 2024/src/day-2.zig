const std = @import("std");
const ArrayListUnmanaged = std.ArrayListUnmanaged;

fn isReportSafe(report: []i8) bool {
    const increasing = report[0] < report[1];

    for (0..report.len - 1) |i| {
        const diff = @abs(report[i] - report[i + 1]);
        if (diff == 0 or diff > 3) {
            return false;
        }

        if (increasing and report[i] >= report[i + 1]) {
            return false;
        }

        if (!increasing and report[i] <= report[i + 1]) {
            return false;
        }
    }

    return true;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var file = try std.fs.cwd().openFile("inputs/day2.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var stream = buf_reader.reader();

    var safe_reports: u16 = 0;
    var safe_dampened: u16 = 0;

    var buf: [128]u8 = undefined;
    while (try stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var it = std.mem.splitScalar(u8, line, ' ');

        var report: ArrayListUnmanaged(i8) = .empty;

        while (it.next()) |c| {
            const level = try std.fmt.parseInt(i8, c, 10);
            try report.append(allocator, level);
        }

        const arr = try report.toOwnedSlice(allocator);
        defer allocator.free(arr);

        if (isReportSafe(arr)) {
            safe_reports += 1;
        } else {
            for (0..arr.len) |j| {
                const modified = try std.mem.concat(allocator, i8, &[_][]const i8{ arr[0..j], arr[j + 1 ..] });
                defer allocator.free(modified);

                if (isReportSafe(modified)) {
                    safe_dampened += 1;
                    break;
                }
            }
        }
    }

    std.debug.print("safe: {any}\n", .{safe_reports});
    std.debug.print("safe (dampened): {any}\n", .{safe_reports + safe_dampened});
}
