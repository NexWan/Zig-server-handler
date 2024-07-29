/// Types and functions for CLI output formatting

const std = @import("std");

pub const colors = struct {
    pub const red = "\x1b[31m";
    pub const green = "\x1b[32m";
    pub const yellow = "\x1b[33m";
};

pub const funcs = struct {
    pub const reset = "\x1b[0m";
    pub const bold = "\x1b[1m";
    pub const underline = "\x1b[4m";
    pub const blink = "\x1b[5m";
    pub const reverse = "\x1b[7m";
    pub const invisible = "\x1b[8m";
    pub fn resetAll() !void {
        const stdout = std.io.getStdOut().writer();
        try stdout.print("{s}", .{funcs.reset});
    }

    pub fn clearTerminal() !void {
        const stdout = std.io.getStdOut().writer();
        try stdout.print("\x1b[2J\x1b[1;1H", .{});
    }
};

pub const cli = struct {
    colour: [*:0]const u8,
    pub fn println(message:anytype) !void {
        const stdout = std.io.getStdOut().writer();
        try stdout.print("{s}\n", .{message});
    }

    pub fn printFmt(message: [*:0]const u8, color: [*:0]const u8) !void {
        const stdout = std.io.getStdOut().writer();
        try stdout.print("{s}{s}", .{color,message});
    }
};
