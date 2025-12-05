const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    const file_size = try file.getEndPos();
    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    _ = try file.readAll(buffer);

    var numbers = std.ArrayList(i32){};
    defer numbers.deinit(allocator);

    var lines = std.mem.splitScalar(u8, buffer, '\n');
    while (lines.next()) |line| {
        if (line.len == 0) continue;

        const direction = line[0];
        const num_str = line[1..];

        const num = try std.fmt.parseInt(u32, num_str, 10);

        const value: i32 = if (direction == 'R')
            @intCast(num)
        else if (direction == 'L')
            -@as(i32, @intCast(num))
        else
            return error.InvalidFormat;

        try numbers.append(allocator, value);
    }

    var dial: i32 = 50;
    var result: u32 = 0;

    for (numbers.items) |num| {
        const full_laps = @divTrunc(@abs(num), 100);
        const mod = @rem(num, 100);
        const original_dial = dial;

        dial += mod;

        var passed_zero: bool = false;
        if (dial < 0) {
            passed_zero = true;
            dial = 100 + dial;
        } else if (dial >= 100) {
            passed_zero = true;
            dial = @rem(dial, 100);
        }

        result += full_laps;
        if (original_dial != 0) {
            if (dial == 0 or passed_zero) {
                result += 1;
            }
        }
    }

    std.debug.print("Result: {}\n", .{result});
}
