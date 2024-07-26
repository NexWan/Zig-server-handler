const std = @import("std");

pub const InitCheck = struct ***REMOVED***

    allocator: std.mem.Allocator,

    const Config = struct ***REMOVED***
        root: []const u8,
    ***REMOVED***;

    pub fn init(allocator: anytype) !InitCheck ***REMOVED***
        return InitCheck***REMOVED***
            .allocator = allocator,
        ***REMOVED***;
    ***REMOVED***

    pub fn readConfig(self:*InitCheck, path: []const u8) !std.json.Parsed(std.json.Value) ***REMOVED***
        const data = try std.fs.cwd().readFileAlloc(self.allocator, path, 2048);
        return std.json.parseFromSlice(std.json.Value, self.allocator, data, .***REMOVED******REMOVED***);
    ***REMOVED*** 
***REMOVED***;