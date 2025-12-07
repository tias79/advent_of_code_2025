const std = @import("std");

const Column = struct {
    values: std.ArrayList([]u8),
    operator: u8,
    width: usize,

    pub fn init() Column {
        return Column{
            .values = std.ArrayList([]u8){},
            .operator = 0,
            .width = 0,
        };
    }

    pub fn deinit(self: *Column, allocator: std.mem.Allocator) void {
        for (self.values.items) |val| {
            allocator.free(val);
        }
        self.values.deinit(allocator);
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    const file_size = try file.getEndPos();
    const content = try allocator.alloc(u8, file_size);
    defer allocator.free(content);
    _ = try file.readAll(content);

    // Split into lines
    var lines = std.ArrayList([]const u8){};
    defer lines.deinit(allocator);

    var line_iter = std.mem.splitScalar(u8, content, '\n');
    while (line_iter.next()) |line| {
        if (line.len > 0) {
            try lines.append(allocator, line);
        }
    }

    // The last line (bottom line) defines operators and widths
    const operator_line = lines.items[lines.items.len - 1];

    // Parse operators and widths from the bottom line
    var operators = std.ArrayList(u8){};
    defer operators.deinit(allocator);

    var widths = std.ArrayList(usize){};
    defer widths.deinit(allocator);

    var i: usize = 0;
    while (i < operator_line.len) {
        const c = operator_line[i];
        if (c != ' ') {
            try operators.append(allocator, c);

            // Count spaces after the operator until next operator or end of line
            // These spaces represent the column width
            var width: usize = 0;
            i += 1;
            while (i < operator_line.len and operator_line[i] == ' ') {
                width += 1;
                i += 1;
            }

            try widths.append(allocator, width);
        } else {
            i += 1;
        }
    }

    // Adjust the last column's width: add 1 to account for the operator position
    if (widths.items.len > 0) {
        widths.items[widths.items.len - 1] += 1;
    }

    const num_columns = operators.items.len;

    const columns = try allocator.alloc(Column, num_columns);
    defer {
        for (columns) |*col| {
            col.deinit(allocator);
        }
        allocator.free(columns);
    }

    for (columns, 0..) |*col, idx| {
        col.* = Column.init();
        col.operator = operators.items[idx];
        col.width = widths.items[idx];
    }

    // Read data lines from bottom to top (excluding the operator line)
    var line_idx: usize = lines.items.len - 1;
    while (line_idx > 0) : (line_idx -= 1) {
        const line = lines.items[line_idx - 1];

        // Parse each column according to its width
        var pos: usize = 0;
        for (columns) |*col| {
            var value_array = try allocator.alloc(u8, col.width);

            for (0..col.width) |j| {
                if (pos < line.len) {
                    const ch = line[pos];
                    if (ch == ' ') {
                        value_array[j] = 0;
                    } else if (ch >= '0' and ch <= '9') {
                        value_array[j] = ch - '0';
                    } else {
                        value_array[j] = ch;
                    }
                    pos += 1;
                } else {
                    value_array[j] = 0;
                }
            }

            try col.values.append(allocator, value_array);

            if (pos < line.len and line[pos] == ' ') {
                pos += 1;
            }
        }
    }

    var result: i64 = 0;

    for (columns) |*col| {
        var columnTotal: i64 = 0;
        for (0..col.width) |colIndex| {
            var value: i64 = 0;
            var pow: i64 = 0;
            for (col.values.items) |val| {
                if (val[colIndex] == 0) continue;
                value += val[colIndex] * std.math.pow(i64, 10, @as(i64, @intCast(pow)));
                pow += 1;
            }

            if (col.operator == '+') {
                columnTotal += value;
            } else if (col.operator == '*') {
                if (columnTotal == 0) {
                    columnTotal = value;
                } else {
                    columnTotal *= value;
                }
            }
        }

        result += columnTotal;
    }

    std.debug.print("Result: {}\n", .{result});
}
