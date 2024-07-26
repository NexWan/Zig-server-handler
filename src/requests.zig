const std = @import("std");

var gpa = std.heap.GeneralPurposeAllocator(.***REMOVED******REMOVED***)***REMOVED******REMOVED***;
defer std.debug.assert(gpa.deinit() == .ok);
const allocator = gpa.allocator();

const http = std.http;

//Http client
var client = http.Client***REMOVED***.allocator = allocator***REMOVED***;
defer client.deinit();



test "HTTP GET request" ***REMOVED***
    const request = http.Request.init(allocator);
    defer request.deinit();

    request.setUrl("https://jsonplaceholder.typicode.com/todos/1");
    request.setMethod("GET");

    const result = client.fetch(request) catch |err| ***REMOVED***
        std.debug.print("Error: ***REMOVED***s***REMOVED***\n", .***REMOVED***err***REMOVED***);
        return;
    ***REMOVED***;

    const response = result.response;
    const body = response.getBody();
    std.debug.print("Response: ***REMOVED***s***REMOVED***\n", .***REMOVED***body***REMOVED***);
***REMOVED***