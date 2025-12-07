const std = @import("std");

fn findFirstPosOfBiggest(start: usize, end: usize, numbers: std.ArrayList(i32)) usize {
    var max_value = numbers.items[start];
    var max_index: usize = start;

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

    var result: i64 = 0;
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

        const one = findFirstPosOfBiggest(0, numbers.items.len - 12, numbers);
        const two = findFirstPosOfBiggest(one + 1, numbers.items.len - 12 + 1, numbers);
        const three = findFirstPosOfBiggest(two + 1, numbers.items.len - 12 + 2, numbers);
        const four = findFirstPosOfBiggest(three + 1, numbers.items.len - 12 + 3, numbers);
        const five = findFirstPosOfBiggest(four + 1, numbers.items.len - 12 + 4, numbers);
        const six = findFirstPosOfBiggest(five + 1, numbers.items.len - 12 + 5, numbers);
        const seven = findFirstPosOfBiggest(six + 1, numbers.items.len - 12 + 6, numbers);
        const eight = findFirstPosOfBiggest(seven + 1, numbers.items.len - 12 + 7, numbers);
        const nine = findFirstPosOfBiggest(eight + 1, numbers.items.len - 12 + 8, numbers);
        const ten = findFirstPosOfBiggest(nine + 1, numbers.items.len - 12 + 9, numbers);
        const eleven = findFirstPosOfBiggest(ten + 1, numbers.items.len - 12 + 10, numbers);
        const twelve = findFirstPosOfBiggest(eleven + 1, numbers.items.len - 12 + 11, numbers);

        const number: i64 = numbers.items[one] * std.math.pow(i64, 10, 11) +
            numbers.items[two] * std.math.pow(i64, 10, 10) +
            numbers.items[three] * std.math.pow(i64, 10, 9) +
            numbers.items[four] * std.math.pow(i64, 10, 8) +
            numbers.items[five] * std.math.pow(i64, 10, 7) +
            numbers.items[six] * std.math.pow(i64, 10, 6) +
            numbers.items[seven] * std.math.pow(i64, 10, 5) +
            numbers.items[eight] * std.math.pow(i64, 10, 4) +
            numbers.items[nine] * std.math.pow(i64, 10, 3) +
            numbers.items[ten] * std.math.pow(i64, 10, 2) +
            numbers.items[eleven] * std.math.pow(i64, 10, 1) +
            numbers.items[twelve];
        result += number;
    }

    std.debug.print("Result: {}\n", .{result});
}
