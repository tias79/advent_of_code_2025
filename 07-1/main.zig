const std = @import("std");

const Position = struct { x: usize, y: usize };

const Matrix = struct {
    data: [][]u8,
    width: usize,
    height: usize,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, filename: []const u8) !Matrix {
        const file = try std.fs.cwd().openFile(filename, .{});
        defer file.close();

        const file_size = try file.getEndPos();
        const content = try allocator.alloc(u8, file_size);
        defer allocator.free(content);

        _ = try file.readAll(content);

        var line_count: usize = 0;
        var width: usize = 0;
        var lines = std.mem.tokenizeAny(u8, content, "\n\r");

        while (lines.next()) |line| {
            if (line.len > 0) {
                if (width == 0) {
                    width = line.len;
                }
                line_count += 1;
            }
        }

        const data = try allocator.alloc([]u8, line_count);
        for (data) |*row| {
            row.* = try allocator.alloc(u8, width);
        }

        lines = std.mem.tokenizeAny(u8, content, "\n\r");
        var row_idx: usize = 0;
        while (lines.next()) |line| {
            if (line.len > 0) {
                @memcpy(data[row_idx], line);
                row_idx += 1;
            }
        }

        return Matrix{
            .data = data,
            .width = width,
            .height = line_count,
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *Matrix) void {
        for (self.data) |row| {
            self.allocator.free(row);
        }
        self.allocator.free(self.data);
    }

    pub fn get(self: Matrix, x: usize, y: usize) ?u8 {
        if (x >= self.width or y >= self.height) {
            return null;
        }
        return self.data[y][x];
    }

    pub fn set(self: Matrix, x: usize, y: usize, value: u8) !void {
        if (x >= self.width or y >= self.height) {
            return error.OutOfBounds;
        }
        self.data[y][x] = value;
    }

    pub fn findStart(self: Matrix) ?Position {
        for (self.data, 0..) |row, y| {
            for (row, 0..) |char, x| {
                if (char == 'S') {
                    return .{ .x = x, .y = y };
                }
            }
        }
        return null;
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var matrix = try Matrix.init(allocator, "input.txt");
    defer matrix.deinit();

    var result: u64 = 0;

    if (matrix.findStart()) |start| {
        var buf = std.AutoHashMap(u64, void).init(allocator);

        buf.put(start.x, {}) catch {};
        var y = start.y + 1;
        while (y < matrix.height) {
            var next_buf = std.AutoHashMap(u64, void).init(allocator);
            var it = buf.keyIterator();
            while (it.next()) |pos| {
                if (matrix.get(pos.*, y) == '^') {
                    result += 1;
                    if (pos.* > 0) {
                        next_buf.put(pos.* - 1, {}) catch {};
                    }
                    if (pos.* + 1 < matrix.width) {
                        next_buf.put(pos.* + 1, {}) catch {};
                    }
                } else {
                    next_buf.put(pos.*, {}) catch {};
                }
            }

            buf.deinit();
            buf = next_buf;
            y += 1;
        }
        buf.deinit();

        std.debug.print("Result: {d}\n", .{result});
    }
}
