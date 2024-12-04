const std = @import("std");
const ArrayListUnmanaged = std.ArrayListUnmanaged;

fn calculateTotal(part2: bool) !u32 {
    var total: u32 = 0;

    var run_mul = true;

    var file = try std.fs.cwd().openFile("inputs/day3.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var stream = buf_reader.reader();

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

            if (part2) {
                if (!run_mul) {
                    const do = std.mem.indexOfPos(u8, line, starting_index, "do()");
                    if (do != null and do.? < mul_start.?) {
                        run_mul = true;
                    }
                } else {
                    const dont = std.mem.indexOfPos(u8, line, starting_index, "don't()");
                    if (dont != null and dont.? < mul_start.?) {
                        run_mul = false;
                        starting_index = dont.? + 1;
                        continue;
                    }
                }
            }

            starting_index = mul_start.? + 1;

            if (!run_mul) {
                continue;
            }

            const diff = mul_end.? - mul_start.?;
            if (diff > 11) {
                continue;
            }

            const slice = line[mul_start.? + 4 .. mul_end.?];

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

    return total;
}

pub fn main() !void {
    const total = try calculateTotal(false);
    const total2 = try calculateTotal(true);

    std.debug.print("part 1: {d}\n", .{total});
    std.debug.print("part 2: {d}\n", .{total2});
}
