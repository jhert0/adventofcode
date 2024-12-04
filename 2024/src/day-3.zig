const std = @import("std");

pub fn main() !void {
    var file = try std.fs.cwd().openFile("inputs/day3.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var stream = buf_reader.reader();

    var total: u32 = 0;

    const size = 4096;
    var buf: [size]u8 = [_]u8{0} ** size;
    while (try stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var starting_index: usize = 0;

        while (starting_index < line.len) {
            const mul_start = std.mem.indexOfPos(u8, line, starting_index, "mul(");
            if (mul_start == null) {
                break;
            }

            const mul_end = std.mem.indexOfPos(u8, line, mul_start.?, ")");
            if (mul_end == null) {
                break;
            }

            starting_index = mul_start.? + 1;

            const diff = mul_end.? - mul_start.?;
            if (diff > 11) {
                continue;
            }

            const slice = buf[mul_start.? + 4 .. mul_end.?];
            std.debug.print("{s}\n", .{slice});

            var comma_found = false;
            for (slice) |c| {
                if (c == ',') {
                    comma_found = true;
                }
            }

            if (!comma_found) {
                continue;
            }

            var temp: u32 = 1;
            var it = std.mem.splitScalar(u8, slice, ',');
            while (it.next()) |val| {
                const number = try std.fmt.parseInt(u32, val, 10);
                temp *= number;
            }

            total += temp;
        }
    }

    std.debug.print("part 1: {any}\n", .{total});
}
