const std = @import("std");
const c = @import("c");

const AnswerStatus = enum {
    ok,
    retry,
    failed,
    unknown,
};

fn answerStatusFromC(raw: c.answer_status) AnswerStatus {
    return switch (@as(c_int, raw)) {
        c.ANSWER_STATUS_OK => .ok,
        c.ANSWER_STATUS_RETRY => .retry,
        c.ANSWER_STATUS_FAILED => .failed,
        else => .unknown,
    };
}

test "maps translated C enum through wrapper" {
    try std.testing.expectEqual(AnswerStatus.ok, answerStatusFromC(c.ANSWER_STATUS_OK));
    try std.testing.expectEqual(AnswerStatus.retry, answerStatusFromC(c.ANSWER_STATUS_RETRY));
    try std.testing.expectEqual(AnswerStatus.failed, answerStatusFromC(c.ANSWER_STATUS_FAILED));
    try std.testing.expectEqual(AnswerStatus.unknown, answerStatusFromC(@as(c.answer_status, 99)));
}

pub fn main(init: std.process.Init) !void {
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.Io.File.stdout().writer(init.io, &stdout_buffer);
    const stdout = &stdout_writer.interface;
    try stdout.print("C answer: {d} {s}\n", .{
        c.answer(),
        @tagName(answerStatusFromC(c.answer_status_value())),
    });
    try stdout.flush();
}
