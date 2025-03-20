const std = @import("std");
const reqTypes = @import("requests.zig").RequestType;
const requests = @import("requests.zig");
const Server = @import("server.zig").ServerS;
const ServerTest = @import("server.zig").Testing;
//const randomString = @cImport(
//    @cInclude("randomString.h"),
//);

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

pub fn main() !void {
    std.debug.print("Hello, World!\n", .{});
}


test "HTTP test" {
    var req = requests.Requests.init(allocator);
    const url = "https://whatthecommit.com/index.txt";
    req.get(url) catch |err| {
        std.debug.print("Error: {any}\n", .{err});
    };
}

test "HTTP server" {
    var server = Server.init(allocator);
    _ = try server.start();
}

test "HTTP server with random string" {
    var server = Server.init(allocator);
    _ = try server.start();
}

test "Slice url"{
    const url = "https://www.google.com/search?q=zig+programming+language";
    const map = try ServerTest.parseQueryString(url);
    
    var it = map.iterator();
    while(it.next()) |entry| {
        std.debug.print("Key: {s}, Value: {s}\n", .{entry.key_ptr.*, entry.value_ptr.*});
    }
}