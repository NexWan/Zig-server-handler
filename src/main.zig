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
const randomString = @cImport( ***REMOVED***
    @cInclude("randomString.h");
***REMOVED***);


var gpa = std.heap.GeneralPurposeAllocator(.***REMOVED******REMOVED***)***REMOVED******REMOVED***;
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

pub fn main() !void ***REMOVED***
    const reader = std.io.getStdIn().reader();
    try funcs.clearTerminal();
    try cli.printFmt(clifyMessage, colors.green);
    try funcs.resetAll();
    try cli.println(welcomeMessage);
    while (true) ***REMOVED***
        try printPlayingBox();
        var buffer = std.ArrayList(u8).init(allocator);
        defer buffer.deinit();
        while (reader.readByte() catch null) |byte| ***REMOVED***
            if (byte == '\n') break;
            try buffer.append(byte);
        ***REMOVED***
        const command = commands.handleCommand(buffer.items) catch |err| ***REMOVED***
            std.debug.print("Error: ***REMOVED***s***REMOVED***\n", .***REMOVED***err***REMOVED***);
            try cli.println("Invalid command, please try again!");
            continue;
        ***REMOVED***;
        try cli.println(command);
    ***REMOVED***
***REMOVED***



/// Prints the playing box in the terminal
pub fn printPlayingBox() !void ***REMOVED***
    try cli.printFmt(playingBoxInit, colors.green);
    try cli.printFmt("\n    Now Playing: ", colors.yellow);
    try cli.printFmt("Song Name", colors.green);
    try cli.printFmt(" - ", colors.yellow);
    try cli.printFmt("Artist Name\n", colors.green);
    try cli.printFmt(playingBoxEnd, colors.green);
    try cli.println("");
***REMOVED***

//test "HTTP test" ***REMOVED***
//    var req = requests.Requests.init(allocator);
//    const url = "https://whatthecommit.com/index.txt";
//    req.get(url) catch |err| ***REMOVED***
//        std.debug.print("Error: ***REMOVED***any***REMOVED***\n", .***REMOVED***err***REMOVED***);
//    ***REMOVED***;
//***REMOVED***

//test "Init config" ***REMOVED***
    //var config = try initConfig.init(allocator);
   // const path = "config.json";

  //  const parsed = config.readConfig(path) catch |err| ***REMOVED***
 //       std.debug.print("Error: ***REMOVED***any***REMOVED***\n", .***REMOVED***err***REMOVED***);
 //       return;
//    ***REMOVED***;

//    var root = parsed.value;

//    const client = root.object.get("client_id").?;
//    const secret = root.object.get("client_secret").?;
//    std.debug.print("Client: ***REMOVED***s***REMOVED***\n", .***REMOVED***client.string***REMOVED***);
//    std.debug.print("Secret: ***REMOVED***s***REMOVED***\n", .***REMOVED***secret.string***REMOVED***);
//***REMOVED***

//test "Check file exists" ***REMOVED***
//    var config = try initConfig.init(allocator);
//    const path = "config.json";
//    const exists = try config.checkConfigExists(path);
//    std.debug.print("Exists: ***REMOVED***any***REMOVED***\n", .***REMOVED***exists.exists***REMOVED***);
//***REMOVED***

//test "Write to JSON" ***REMOVED***
//    const path = "config.json";
//    var config = try initConfig.init(allocator);
//    try config.writeInitSettings(path);
//***REMOVED***

//test "HTTP server" ***REMOVED***
 //   var server = Server.init(allocator);
  //  _ = try server.start();
//***REMOVED***


test "Generate random string" ***REMOVED***
    const length = 10;
    const random = randomString.rand_str(length);
    std.debug.print("Random: ***REMOVED***s***REMOVED***\n", .***REMOVED***random***REMOVED***);
***REMOVED***