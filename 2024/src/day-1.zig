const std = @import("std");
const ArrayListUnmanaged = std.ArrayListUnmanaged;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    var file = try std.fs.cwd().openFile("inputs/day1.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var stream = buf_reader.reader();

    var list1: ArrayListUnmanaged(i32) = .empty;
    var list2: ArrayListUnmanaged(i32) = .empty;

    var buf: [128]u8 = undefined;
    while (try stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var it = std.mem.splitSequence(u8, line, "   ");

        const num1 = try std.fmt.parseInt(i32, it.next().?, 10);
        const num2 = try std.fmt.parseInt(i32, it.next().?, 10);

        try list1.append(allocator, num1);
        try list2.append(allocator, num2);
    }

    const numbers1 = try list1.toOwnedSlice(allocator);
    defer allocator.free(numbers1);

    const numbers2 = try list2.toOwnedSlice(allocator);
    defer allocator.free(numbers2);

    std.mem.sort(i32, numbers1, {}, std.sort.asc(i32));
    std.mem.sort(i32, numbers2, {}, std.sort.asc(i32));

    var total: u32 = 0;
    for (0..numbers1.len) |i| {
        const diff = @abs(numbers1[i] - numbers2[i]);
        total += diff;
    }

    try stdout.print("total: {any}\n", .{total});

    try bw.flush();
}
