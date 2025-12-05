const std = @import("std");

const Interval = struct {
    start: u64,
    end: u64,
};

fn countDigits(n: u64) u64 {
    if (n == 0) return 1;

    var count: u64 = 0;
    var temp = n;

    while (temp > 0) : (temp /= 10) {
        count += 1;
    }

    return count;
}

fn isInvalidId(id: u64) bool {
    const nrDigits: u64 = countDigits(id);
    if (nrDigits % 2 == 0) {
        const divisor = std.math.pow(u64, 10, nrDigits / 2);
        const left = id / divisor;
        const right = id % divisor;

        return left == right;
    } else {
        return false;
    }
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    const content = try file.readToEndAlloc(allocator, 1024 * 1024);
    defer allocator.free(content);

    var intervals = std.ArrayList(Interval){};
    defer intervals.deinit(allocator);

    var line_iter = std.mem.splitScalar(u8, content, '\n');
    while (line_iter.next()) |line| {
        if (line.len == 0) continue;

        var pair_iter = std.mem.splitScalar(u8, line, ',');
        while (pair_iter.next()) |pair| {
            var range_iter = std.mem.splitScalar(u8, pair, '-');
            const start_str = range_iter.next() orelse continue;
            const end_str = range_iter.next() orelse continue;

            const start = try std.fmt.parseUnsigned(u64, std.mem.trim(u8, start_str, " \t\r"), 10);
            const end = try std.fmt.parseUnsigned(u64, std.mem.trim(u8, end_str, " \t\r"), 10);

            try intervals.append(allocator, Interval{ .start = start, .end = end });
        }
    }

    var result: u64 = 0;

    for (intervals.items) |interval| {
        var n = interval.start;
        while (n <= interval.end) : (n += 1) {
            if (isInvalidId(n)) {
                result += n;
            }
        }
    }

    std.debug.print("Result: {d}\n", .{result});
}
