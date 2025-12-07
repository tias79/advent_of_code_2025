const std = @import("std");

const Range = struct {
    start: u64,
    end: u64,

    pub fn size(self: Range) u64 {
        return self.end - self.start + 1;
    }
};

fn lessThan(context: void, a: Range, b: Range) bool {
    _ = context;
    return a.start < b.start;
}

fn normalizeRanges(ranges: *std.ArrayList(Range)) void {
    std.mem.sort(Range, ranges.items, {}, lessThan);

    var write_idx: usize = 0;
    var current = ranges.items[0];

    var read_idx: usize = 1;
    while (read_idx < ranges.items.len) : (read_idx += 1) {
        const next = ranges.items[read_idx];

        if (current.end + 1 >= next.start) {
            current.end = @max(current.end, next.end);
        } else {
            ranges.items[write_idx] = current;
            write_idx += 1;
            current = next;
        }
    }

    ranges.items[write_idx] = current;
    write_idx += 1;

    ranges.items.len = write_idx;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    const file_content = try file.readToEndAlloc(allocator, 10 * 1024 * 1024);
    defer allocator.free(file_content);

    var ranges = std.ArrayList(Range){};
    defer ranges.deinit(allocator);

    var lines = std.mem.splitScalar(u8, file_content, '\n');
    var parsing_ranges = true;

    while (lines.next()) |line| {
        if (line.len == 0) {
            parsing_ranges = false;
            continue;
        }

        if (parsing_ranges) {
            var parts = std.mem.splitScalar(u8, line, '-');
            if (parts.next()) |start_str| {
                if (parts.next()) |end_str| {
                    const start = try std.fmt.parseInt(u64, start_str, 10);
                    const end = try std.fmt.parseInt(u64, end_str, 10);
                    try ranges.append(allocator, Range{ .start = start, .end = end });
                }
            }
        } else {
            break;
        }
    }

    normalizeRanges(&ranges);

    var result: u64 = 0;
    for (ranges.items) |range| {
        result += range.size();
    }

    std.debug.print("Result: {}\n", .{result});
}
