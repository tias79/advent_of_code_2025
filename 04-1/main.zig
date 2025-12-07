const std = @import("std");

const Matrix = struct {
    data: std.ArrayList(u8),
    width: i64,
    height: i64,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) Matrix {
        return Matrix{
            .data = std.ArrayList(u8){},
            .width = 0,
            .height = 0,
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *Matrix) void {
        self.data.deinit(self.allocator);
    }

    pub fn get(self: *const Matrix, x: i64, y: i64) ?u8 {
        if (x < 0 or x >= self.width or y < 0 or y >= self.height) {
            return null;
        }
        const ux: usize = @intCast(x);
        const uy: usize = @intCast(y);
        const uw: usize = @intCast(self.width);
        return self.data.items[uy * uw + ux];
    }

    pub fn set(self: *Matrix, x: i64, y: i64, value: u8) !void {
        if (x < 0 or x >= self.width or y < 0 or y >= self.height) {
            return error.OutOfBounds;
        }
        const ux: usize = @intCast(x);
        const uy: usize = @intCast(y);
        const uw: usize = @intCast(self.width);
        self.data.items[uy * uw + ux] = value;
    }

    pub fn print(self: *const Matrix) void {
        var y: i64 = 0;
        while (y < self.height) : (y += 1) {
            var x: i64 = 0;
            while (x < self.width) : (x += 1) {
                const char = self.get(x, y).?;
                std.debug.print("{c}", .{char});
            }
            std.debug.print("\n", .{});
        }
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    const file_content = try file.readToEndAlloc(allocator, 1024 * 1024);
    defer allocator.free(file_content);

    var matrix = Matrix.init(allocator);
    defer matrix.deinit();

    var lines = std.mem.splitScalar(u8, file_content, '\n');
    var first_line = true;

    while (lines.next()) |line| {
        if (line.len == 0) continue;

        if (first_line) {
            matrix.width = @intCast(line.len);
            first_line = false;
        }

        for (line) |char| {
            try matrix.data.append(allocator, char);
        }

        matrix.height += 1;
    }

    var result: u64 = 0;
    var y: i32 = 0;
    while (y < matrix.height) : (y += 1) {
        var x: i32 = 0;
        while (x < matrix.width) : (x += 1) {
            if (matrix.get(x, y) == '@') {
                var nrAdjacentRolls: u8 = 0;
                nrAdjacentRolls += if (matrix.get(x - 1, y - 1) == '@') 1 else 0;
                nrAdjacentRolls += if (matrix.get(x, y - 1) == '@') 1 else 0;
                nrAdjacentRolls += if (matrix.get(x + 1, y - 1) == '@') 1 else 0;
                nrAdjacentRolls += if (matrix.get(x - 1, y) == '@') 1 else 0;
                nrAdjacentRolls += if (matrix.get(x + 1, y) == '@') 1 else 0;
                nrAdjacentRolls += if (matrix.get(x - 1, y + 1) == '@') 1 else 0;
                nrAdjacentRolls += if (matrix.get(x, y + 1) == '@') 1 else 0;
                nrAdjacentRolls += if (matrix.get(x + 1, y + 1) == '@') 1 else 0;
                if (nrAdjacentRolls < 4) {
                    result += 1;
                }
            }
        }
    }

    std.debug.print("Result: {}\n", .{result});
}
