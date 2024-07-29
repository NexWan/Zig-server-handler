const std = @import("std");
const cli = @import("cli.zig").cli;
const colors = @import("cli.zig").colors;
const funcs = @import("cli.zig").funcs;
const commands = @import("commands.zig").commands;
const reqTypes = @import("requests.zig").RequestType;
const requests = @import("requests.zig");
const initConfig = @import("utils.zig").InitCheck;
const Server = @import("server.zig").ServerS;
const utils = @import("utils.zig").Utils;
//const randomString = @cImport(
//    @cInclude("randomString.h"),
//);

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

pub const clifyMessage = 
\\
\\  ____ _ _  __       
\\ / ___| (_)/ _|_   _ 
\\| |   | | | |_| | | |
\\| |___| | |  _| |_| |
\\ \____|_|_|_|  \__, |
\\               |___/ 
\\
;

pub const playingBoxInit = 
\\ -------------------------------------
;

pub const playingBoxEnd =
\\ -------------------------------------
\\
;

pub const welcomeMessage = 
\\ Welcome to Clify! this is a really simple CLI interface which allows you to interact with your Spotify player!
\\ If this is your first time using Clify, you can type 'help' to get a list of available commands.
\\ Thank you for using Clify! love you <3
;

pub fn main() !void {
    const reader = std.io.getStdIn().reader();
    try funcs.clearTerminal();
    try cli.printFmt(clifyMessage, colors.green);
    try funcs.resetAll();
    try cli.println(welcomeMessage);
    while (true) {
        try printPlayingBox();
        var buffer = std.ArrayList(u8).init(allocator);
        defer buffer.deinit();
        while (reader.readByte() catch null) |byte| {
            if (byte == '\n') break;
            try buffer.append(byte);
        }
        const command = commands.handleCommand(buffer.items) catch |err| {
            std.debug.print("Error: {s}\n", .{err});
            try cli.println("Invalid command, please try again!");
            continue;
        };
        try cli.println(command);
    }
}



/// Prints the playing box in the terminal
pub fn printPlayingBox() !void {
    try cli.printFmt(playingBoxInit, colors.green);
    try cli.printFmt("\n    Now Playing: ", colors.yellow);
    try cli.printFmt("Song Name", colors.green);
    try cli.printFmt(" - ", colors.yellow);
    try cli.printFmt("Artist Name\n", colors.green);
    try cli.printFmt(playingBoxEnd, colors.green);
    try cli.println("");
}

test "HTTP test" {
    var req = requests.Requests.init(allocator);
    const url = "https://whatthecommit.com/index.txt";
    req.get(url) catch |err| {
        std.debug.print("Error: {any}\n", .{err});
    };
}

test "Init config" {
    var config = try initConfig.init(allocator);
    const path = "config.json";

    const parsed = config.readConfig(path) catch |err| {
        std.debug.print("Error: {any}\n", .{err});
        return;
    };

    var root = parsed.value;

    const client = root.object.get("client_id").?;
    const secret = root.object.get("client_secret").?;
    std.debug.print("Client: {s}\n", .{client.string});
    std.debug.print("Secret: {s}\n", .{secret.string});
}

test "Check file exists" {
    var config = try initConfig.init(allocator);
    const path = "config.json";
    const exists = try config.checkConfigExists(path);
    std.debug.print("Exists: {any}\n", .{exists.exists});
}

test "Write to JSON" {
    const path = "config.json";
    var config = try initConfig.init(allocator);
    try config.writeInitSettings(path);
}

test "HTTP server" {
    var server = Server.init(allocator);
    _ = try server.start();
}


test "Generate random string" {
    const length = 10;
    const randomString = try utils.generateRandomString(allocator,length);
    defer allocator.free(randomString);
    try cli.println(randomString);
}