/// This will handle HTTP requests

const std = @import("std");
const http = std.http;

pub const Requests = struct ***REMOVED***
    client: http.Client,
    allocator: std.mem.Allocator,

    pub fn init(allocator: anytype) Requests ***REMOVED***
        //Http client
        var client = http.Client***REMOVED*** .allocator = allocator ***REMOVED***;
        defer client.deinit();
        return Requests***REMOVED***
            .client = client,
            .allocator = allocator,
        ***REMOVED***;
    ***REMOVED***

    pub fn get( self: *Requests, url: []const u8) !void ***REMOVED***
        const uri = std.Uri.parse(url) catch unreachable;
        const headers = std.http.Client.Request.Headers***REMOVED***
            .content_type = std.http.Client.Request.Headers.Value***REMOVED***
                .override = "*/*",
            ***REMOVED***,
        ***REMOVED***;

        const server_header_buffer = try self.allocator.alloc(u8,8*1024*4);

        var request = try self.client.open(.GET,uri, std.http.Client.RequestOptions***REMOVED***
            .server_header_buffer = server_header_buffer,
            .headers = headers,
        ***REMOVED***);
        request.transfer_encoding = .none;
        defer request.deinit();
        try request.send();
        try request.finish();
        try request.wait();
        //Read response
        const body = try request.reader().readAllAlloc(self.allocator, 1024);
        std.debug.print("Response: ***REMOVED***s***REMOVED***\n", .***REMOVED***body***REMOVED***);
    ***REMOVED***
***REMOVED***;

pub const RequestType = enum ***REMOVED***
    GET,
    POST,
    PUT,
    DELETE,
***REMOVED***;