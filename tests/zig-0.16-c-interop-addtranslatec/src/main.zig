const std = @import("std");
const c = @import("c");

pub fn main(init: std.process.Init) !void {
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.Io.File.stdout().writer(init.io, &stdout_buffer);
    const stdout = &stdout_writer.interface;
    try stdout.print("C answer: {d}\n", .{c.answer()});
    try stdout.flush();
}
