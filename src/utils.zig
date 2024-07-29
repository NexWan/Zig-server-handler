const std = @import("std");
const cli = @import("cli.zig").cli;
const colors = @import("cli.zig").colors;

pub const InitCheck = struct {

    allocator: std.mem.Allocator,
    const returnFileType = struct {
        exists: bool,
        path: []const u8,
    };

    const initConfig = struct {
        client_id: []const u8,
        client_secret: []const u8,
    };

    const Config = struct {
        root: []const u8,
    };

    pub fn init(allocator: anytype) !InitCheck {
        return InitCheck{
            .allocator = allocator,
        };
    }

    pub fn checkConfigExists(self:*InitCheck, path: []const u8) !returnFileType{
        const exists = blk: {
            _ = std.fs.cwd().createFile(path, .{.exclusive = true}) catch |err| {
                switch (err) {
                    error.PathAlreadyExists => break :blk true,
                    else => break :blk false,
                }
            };
            break :blk false; // If no error occurs, the file was created successfully, so it doesn't exist before.
        };
        const abs_path = try std.fs.cwd().realpathAlloc(self.allocator,path);
        if(!exists){
            return returnFileType{ .exists = false, .path = abs_path };
        }else {
            return returnFileType{ .exists = true, .path = abs_path };
        }
    }

    pub fn writeInitSettings(self:*InitCheck, path: []const u8) !void{
        const data = initConfig{
            .client_id = "your token here",
            .client_secret = "your client here",
        };
        
        // Set up pretty-print options
        const options = std.json.StringifyOptions{
            .whitespace = .indent_4,
        };

        var string = std.ArrayList(u8).init(self.allocator);
        try std.json.stringify(data, options, string.writer());
        var file = try std.fs.cwd().createFile(path, .{});
        defer file.close();


        // Convert the string to an owned slice and handle potential errors
        const ownedSlice = try string.toOwnedSlice();

        // Write the JSON string to the file
        try file.writeAll(ownedSlice);
    }

    pub fn readConfig(self:*InitCheck, path: []const u8) !std.json.Parsed(std.json.Value) {
        const exists = try self.checkConfigExists(path);
        if(!exists.exists){
            const msg = try std.fmt.allocPrintZ(self.allocator, "File not found, created config file at {s}\n", .{exists.path});
            defer self.allocator.free(msg);
            try cli.printFmt(msg, colors.red);
            return error.FileNotFound;
        }
        const data = try std.fs.cwd().readFileAlloc(self.allocator, path, 2048);
        if(data.len == 0){
            return error.FileIsEmpty;
        }
        return std.json.parseFromSlice(std.json.Value, self.allocator, data, .{});
    } 
};

pub const Utils = struct {
    pub fn generateRandomString(allocator: std.mem.Allocator,length: usize) ![]const u8 {
        const RndGen = std.rand.DefaultPrng;
        const charSet = [_]u8{
            'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
            'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
            '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
        };

        var seed:u64 = undefined;
        std.posix.getrandom(std.mem.asBytes(&seed)) catch unreachable;
        var rnd =  RndGen.init(seed);

        const randomString = try allocator.alloc(u8, length);

        for (randomString) |*char| {
            const some_random = rnd.random().intRangeLessThan(usize,0,charSet.len);
            char.* = charSet[some_random];
        }
        return randomString;
    }
};