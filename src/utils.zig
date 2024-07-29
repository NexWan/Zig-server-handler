const std = @import("std");
const cli = @import("cli.zig").cli;
const colors = @import("cli.zig").colors;

pub const InitCheck = struct ***REMOVED***

    allocator: std.mem.Allocator,
    const returnFileType = struct ***REMOVED***
        exists: bool,
        path: []const u8,
    ***REMOVED***;

    const initConfig = struct ***REMOVED***
        client_id: []const u8,
        client_secret: []const u8,
    ***REMOVED***;

    const Config = struct ***REMOVED***
        root: []const u8,
    ***REMOVED***;

    pub fn init(allocator: anytype) !InitCheck ***REMOVED***
        return InitCheck***REMOVED***
            .allocator = allocator,
        ***REMOVED***;
    ***REMOVED***

    pub fn checkConfigExists(self:*InitCheck, path: []const u8) !returnFileType***REMOVED***
        const exists = blk: ***REMOVED***
            _ = std.fs.cwd().createFile(path, .***REMOVED***.exclusive = true***REMOVED***) catch |err| ***REMOVED***
                switch (err) ***REMOVED***
                    error.PathAlreadyExists => break :blk true,
                    else => break :blk false,
                ***REMOVED***
            ***REMOVED***;
            break :blk false; // If no error occurs, the file was created successfully, so it doesn't exist before.
        ***REMOVED***;
        const abs_path = try std.fs.cwd().realpathAlloc(self.allocator,path);
        if(!exists)***REMOVED***
            return returnFileType***REMOVED*** .exists = false, .path = abs_path ***REMOVED***;
        ***REMOVED***else ***REMOVED***
            return returnFileType***REMOVED*** .exists = true, .path = abs_path ***REMOVED***;
        ***REMOVED***
    ***REMOVED***

    pub fn writeInitSettings(self:*InitCheck, path: []const u8) !void***REMOVED***
        const data = initConfig***REMOVED***
            .client_id = "your token here",
            .client_secret = "your client here",
        ***REMOVED***;
        
        // Set up pretty-print options
        const options = std.json.StringifyOptions***REMOVED***
            .whitespace = .indent_4,
        ***REMOVED***;

        var string = std.ArrayList(u8).init(self.allocator);
        try std.json.stringify(data, options, string.writer());
        var file = try std.fs.cwd().createFile(path, .***REMOVED******REMOVED***);
        defer file.close();


        // Convert the string to an owned slice and handle potential errors
        const ownedSlice = try string.toOwnedSlice();

        // Write the JSON string to the file
        try file.writeAll(ownedSlice);
    ***REMOVED***

    pub fn readConfig(self:*InitCheck, path: []const u8) !std.json.Parsed(std.json.Value) ***REMOVED***
        const exists = try self.checkConfigExists(path);
        if(!exists.exists)***REMOVED***
            const msg = try std.fmt.allocPrintZ(self.allocator, "File not found, created config file at ***REMOVED***s***REMOVED***\n", .***REMOVED***exists.path***REMOVED***);
            defer self.allocator.free(msg);
            try cli.printFmt(msg, colors.red);
            return error.FileNotFound;
        ***REMOVED***
        const data = try std.fs.cwd().readFileAlloc(self.allocator, path, 2048);
        if(data.len == 0)***REMOVED***
            return error.FileIsEmpty;
        ***REMOVED***
        return std.json.parseFromSlice(std.json.Value, self.allocator, data, .***REMOVED******REMOVED***);
    ***REMOVED*** 
***REMOVED***;

pub const Utils = struct ***REMOVED***
    pub fn generateRandomString(allocator: std.mem.Allocator,length: usize) ![]const u8 ***REMOVED***
        const RndGen = std.rand.DefaultPrng;
        const charSet = [_]u8***REMOVED***
            'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
            'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
            '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
        ***REMOVED***;

        var seed:u64 = undefined;
        std.posix.getrandom(std.mem.asBytes(&seed)) catch unreachable;
        var rnd =  RndGen.init(seed);

        const randomString = try allocator.alloc(u8, length);

        for (randomString) |*char| ***REMOVED***
            const some_random = rnd.random().intRangeLessThan(usize,0,charSet.len);
            char.* = charSet[some_random];
        ***REMOVED***
        return randomString;
    ***REMOVED***
***REMOVED***;