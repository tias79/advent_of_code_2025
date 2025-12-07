const std = @import("std");

const Column = struct {
    values: std.ArrayList(i64),
    operator: u8,

    pub fn init() Column {
        return Column{
            .values = std.ArrayList(i64){},
            .operator = 0,
        };
    }

    pub fn deinit(self: *Column, allocator: std.mem.Allocator) void {
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

    var lines = std.ArrayList([]const u8){};
    defer lines.deinit(allocator);

    var line_iter = std.mem.splitScalar(u8, content, '\n');
    while (line_iter.next()) |line| {
        if (line.len > 0) {
            try lines.append(allocator, line);
        }
    }

    const operator_line = lines.items[lines.items.len - 1];
    var operators = std.ArrayList(u8){};
    defer operators.deinit(allocator);

    var token_iter = std.mem.tokenizeAny(u8, operator_line, " \t");
    while (token_iter.next()) |token| {
        if (token.len == 1) {
            try operators.append(allocator, token[0]);
        }
    }

    const num_columns = operators.items.len;

    var columns = try allocator.alloc(Column, num_columns);
    defer {
        for (columns) |*col| {
            col.deinit(allocator);
        }
        allocator.free(columns);
    }

    for (columns, 0..) |*col, i| {
        col.* = Column.init();
        col.operator = operators.items[i];
    }

    for (lines.items[0 .. lines.items.len - 1]) |line| {
        var col_index: usize = 0;
        var num_iter = std.mem.tokenizeAny(u8, line, " \t");

        while (num_iter.next()) |num_str| {
            const num = try std.fmt.parseInt(i64, num_str, 10);
            try columns[col_index].values.append(allocator, num);
            col_index += 1;
        }
    }

    var result: i64 = 0;
    for (columns) |col| {
        var calculatedValue: i64 = 0;
        for (col.values.items) |val| {
            if (col.operator == '+') {
                calculatedValue += val;
            } else if (col.operator == '*') {
                if (calculatedValue == 0) {
                    calculatedValue = val;
                } else {
                    calculatedValue *= val;
                }
            }
        }

        result += calculatedValue;
    }

    std.debug.print("Result: {}\n", .{result});
}
