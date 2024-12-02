const std = @import("std");

fn get_direction(val1: i8, val2: i8) i8 {
    const diff = val1 - val2;
    if (diff > 0) {
        return 1;
    }

    if (diff < 0) {
        return -1;
    }

    return 0;
}

pub fn main() !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    var file = try std.fs.cwd().openFile("inputs/day2.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var stream = buf_reader.reader();

    var last_level: ?i8 = null;
    var last_direction: ?i8 = null;
    var unsafe_reports: u16 = 0;
    var total_reports: u16 = 0;

    var buf: [128]u8 = undefined;
    while (try stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var it = std.mem.splitScalar(u8, line, ' ');

        var unsafe = false;
        while (it.next()) |c| {
            const current_level = try std.fmt.parseInt(i8, c, 10);

            if (last_level == null) {
                last_level = current_level;
                continue;
            }

            const diff = @abs(last_level.? - current_level);
            const direction = get_direction(last_level.?, current_level);
            if ((last_direction != direction and last_direction != null) or diff > 3) {
                unsafe = true;
                break;
            }

            last_level = current_level;
            last_direction = direction;
        }

        last_level = null;
        last_direction = null;

        if (unsafe) {
            unsafe_reports += 1;
        }

        total_reports += 1;
    }

    try stdout.print("safe: {any}\n", .{total_reports - unsafe_reports});

    try bw.flush();
}
