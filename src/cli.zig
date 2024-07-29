/// Types and functions for CLI output formatting

const std = @import("std");

pub const colors = struct ***REMOVED***
    pub const red = "\x1b[31m";
    pub const green = "\x1b[32m";
    pub const yellow = "\x1b[33m";
***REMOVED***;

pub const funcs = struct ***REMOVED***
    pub const reset = "\x1b[0m";
    pub const bold = "\x1b[1m";
    pub const underline = "\x1b[4m";
    pub const blink = "\x1b[5m";
    pub const reverse = "\x1b[7m";
    pub const invisible = "\x1b[8m";
    pub fn resetAll() !void ***REMOVED***
        const stdout = std.io.getStdOut().writer();
        try stdout.print("***REMOVED***s***REMOVED***", .***REMOVED***funcs.reset***REMOVED***);
    ***REMOVED***

    pub fn clearTerminal() !void ***REMOVED***
        const stdout = std.io.getStdOut().writer();
        try stdout.print("\x1b[2J\x1b[1;1H", .***REMOVED******REMOVED***);
    ***REMOVED***
***REMOVED***;

pub const cli = struct ***REMOVED***
    colour: [*:0]const u8,
    pub fn println(message:anytype) !void ***REMOVED***
        const stdout = std.io.getStdOut().writer();
        try stdout.print("***REMOVED***s***REMOVED***\n", .***REMOVED***message***REMOVED***);
    ***REMOVED***

    pub fn printFmt(message: [*:0]const u8, color: [*:0]const u8) !void ***REMOVED***
        const stdout = std.io.getStdOut().writer();
        try stdout.print("***REMOVED***s***REMOVED******REMOVED***s***REMOVED***", .***REMOVED***color,message***REMOVED***);
    ***REMOVED***
***REMOVED***;
