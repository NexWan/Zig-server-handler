/// This will handle HTTP requests

const std = @import("std");
const http = std.http;

pub const Requests = struct {
    client: http.Client,
    allocator: std.mem.Allocator,

    pub fn init(allocator: anytype) Requests {
        //Http client
        var client = http.Client{ .allocator = allocator };
        defer client.deinit();
        return Requests{
            .client = client,
            .allocator = allocator,
        };
    }

    pub fn get( self: *Requests, url: []const u8) !void {
        const uri = std.Uri.parse(url) catch unreachable;
        const headers = std.http.Client.Request.Headers{
            .content_type = std.http.Client.Request.Headers.Value{
                .override = "*/*",
            },
        };

        const server_header_buffer = try self.allocator.alloc(u8,8*1024*4);

        var request = try self.client.open(.GET,uri, std.http.Client.RequestOptions{
            .server_header_buffer = server_header_buffer,
            .headers = headers,
        });
        request.transfer_encoding = .none;
        defer request.deinit();
        try request.send();
        try request.finish();
        try request.wait();
        //Read response
        const body = try request.reader().readAllAlloc(self.allocator, 1024);
        std.debug.print("Response: {s}\n", .{body});
    }

    pub fn post(self: *Requests, url: []const u8, body: []const u8, ) !void {
        const uri = std.Uri.parse(url) catch unreachable;
        const headers = std.http.Client.Request.Headers{
            .content_type = std.http.Client.Request.Headers.Value{
                .override = "application/x-www-form-urlencoded",
            },
        };

        const server_header_buffer = try self.allocator.alloc(u8,8*1024*4);

        var request = try self.client.open(.POST,uri, std.http.Client.RequestOptions{
            .server_header_buffer = server_header_buffer,
            .headers = headers,
        });
        request.transfer_encoding = .none;
        defer request.deinit();
        try request.writer().write(body);
        try request.finish();
        try request.wait();
        //Read response
        const msg = try request.reader().readAllAlloc(self.allocator, 1024);
        std.debug.print("Response: {s}\n", .{msg});
    }
};

pub const RequestType = enum {
    GET,
    POST,
    PUT,
    DELETE,
};