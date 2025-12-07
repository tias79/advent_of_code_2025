const std = @import("std");

const Range = struct {
    start: u64,
    end: u64,

    pub fn contains(self: Range, id: u64) bool {
        return id >= self.start and id <= self.end;
    }
};

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

    var ids = std.ArrayList(u64){};
    defer ids.deinit(allocator);

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
            const id = try std.fmt.parseInt(u64, line, 10);
            try ids.append(allocator, id);
        }
    }

    var result: u64 = 0;

    for (ids.items[0..ids.items.len]) |id| {
        for (ranges.items) |range| {
            if (range.contains(id)) {
                result += 1;
                break;
            }
        }
    }

    std.debug.print("Result: {}\n", .{result});
}
