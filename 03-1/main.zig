const std = @import("std");

fn findFirstPosOfBiggest(start: usize, end: usize, numbers: std.ArrayList(i32)) usize {
    var max_value = numbers.items[start];
    var max_index: usize = start;

    // Find the maximum value and its first occurrence in the range [start, end]
    for (numbers.items[start .. end + 1], start..) |num, i| {
        if (num > max_value) {
            max_value = num;
            max_index = i;
        }
    }

    return max_index;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    const file_content = try file.readToEndAlloc(allocator, 1024 * 1024);
    defer allocator.free(file_content);

    var result: i32 = 0;
    var lines = std.mem.splitScalar(u8, file_content, '\n');
    while (lines.next()) |line| {
        if (line.len == 0) continue;

        // Convert each character in the line to an integer
        var numbers = std.ArrayList(i32){};
        defer numbers.deinit(allocator);

        for (line) |char| {
            if (char >= '0' and char <= '9') {
                const digit = char - '0';
                try numbers.append(allocator, @intCast(digit));
            }
        }

        const fstPos = findFirstPosOfBiggest(0, numbers.items.len - 2, numbers);
        const sndPos = findFirstPosOfBiggest(fstPos + 1, numbers.items.len - 1, numbers);

        std.debug.print("Fst: {}\n", .{fstPos});
        std.debug.print("Snd: {}\n", .{sndPos});

        result += (numbers.items[fstPos] * 10) + numbers.items[sndPos];
    }

    std.debug.print("Result: {}\n", .{result});
}
