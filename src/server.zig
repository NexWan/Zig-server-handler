const std = @import("std");
const net = std.net;
const fs = std.fs;
const mem = std.mem;

const server_addr = "0.0.0.0";
const server_port = 8000;

pub const ServerS = struct ***REMOVED***
    server_addr: []const u8,
    server_port: u16,
    allocator: std.mem.Allocator,

    pub const ServerFileError = error***REMOVED***
        HeaderMalFormed,
        MethodNotSupported,
        ProtocolNotSupported,
        UnkownMimeType,
    ***REMOVED***;

    const mimeTypes = .***REMOVED***
        .***REMOVED***"html", "text/html"***REMOVED***,
        .***REMOVED***"css", "text/css"***REMOVED***,
        .***REMOVED***".png", "image/png"***REMOVED***,
        .***REMOVED***".jpg", "image/jpeg"***REMOVED***,
        .***REMOVED***".jpeg", "image/jpeg"***REMOVED***,
    ***REMOVED***;

    const HeaderNames = enum ***REMOVED***
        Host,
        @"User-Agent",
    ***REMOVED***;

    const HTTPHeader = struct ***REMOVED***
        requestLine: []const u8,
        host: []const u8,
        userAgent: []const u8,

        pub fn print(self: HTTPHeader) void ***REMOVED***
            std.debug.print("***REMOVED***s***REMOVED*** - ***REMOVED***s***REMOVED***\n", .***REMOVED***
                self.requestLine,
                self.host,
            ***REMOVED***);
        ***REMOVED***
    ***REMOVED***;

    pub fn parseHeader(header: []const u8) !HTTPHeader ***REMOVED***
        var headerStruct = HTTPHeader ***REMOVED***
            .requestLine = undefined,
            .host = undefined,
            .userAgent = undefined,
        ***REMOVED***;
        var headerIter = mem.tokenizeSequence(u8, header, " \r\n");
        headerStruct.requestLine = headerIter.next() orelse return ServerFileError.HeaderMalFormed;
        while (headerIter.next()) |line| ***REMOVED***
            const nameSlice = mem.sliceTo(line, ':');
            if(nameSlice.len == line.len) return ServerFileError.HeaderMalFormed;
            const headerName = std.meta.stringToEnum(HeaderNames,nameSlice) orelse continue;
            const headerValue = mem.trimLeft(u8, line[nameSlice.len + 1 ..], " ");
            switch (headerName) ***REMOVED***
                .Host => headerStruct.host = headerValue,
                .@"User-Agent" => headerStruct.userAgent = headerValue,
            ***REMOVED***
        ***REMOVED***
        return headerStruct;
    ***REMOVED***

    pub fn parsePath(requestLine: []const u8) ![]const u8 ***REMOVED***
        var requestLineIter = mem.tokenizeScalar(u8, requestLine, ' ');
        const method = requestLineIter.next().?;
        if (!mem.eql(u8,method,"GET")) return ServerFileError.MethodNotSupported;
        const path = requestLineIter.next().?;
        if (path.len <= 0) return error.NoPath;
        var proto = requestLineIter.next().?;
        proto = mem.trim(u8, proto, " \r\n");
        std.debug.print("proto: ***REMOVED***s***REMOVED***\n", .***REMOVED***proto***REMOVED***);
        //if (!mem.eql(u8, proto, "HTTP/1.1")) return ServerFileError.ProtocolNotSupported;
        if(mem.eql(u8,path,"/")) return "index.html";
        return path;
    ***REMOVED***

    pub fn openLocalFile(path: []const u8) ![]const u8 ***REMOVED***
        const localPath = path[1..];
        const file = fs.cwd().openFile(localPath, .***REMOVED******REMOVED***) catch |err| switch (err) ***REMOVED***
            error.FileNotFound => ***REMOVED***
                std.debug.print("File not found: ***REMOVED***s***REMOVED***\n", .***REMOVED***localPath***REMOVED***);
                return error.FileNotFound;
            ***REMOVED***,
            else => return err,
        ***REMOVED***;
        defer file.close();
        std.debug.print("file: ***REMOVED***any***REMOVED***\n", .***REMOVED***file***REMOVED***);
        const memory = std.heap.page_allocator;
        const maxSize = std.math.maxInt(usize);
        return try file.readToEndAlloc(memory, maxSize);
    ***REMOVED***

    pub fn http404() []const u8 ***REMOVED***
        return 
        \\ HTTP/1.1 404 NOT FOUND
        \\Connection: close
        \\Content-Type: text/html; charset=UTF-8
        \\Content-Length: 9
        \\
        \\NOT FOUND
        ;
    ***REMOVED***

    pub fn mimeForPath(path: []const u8) ![]const u8 ***REMOVED***
        const ext = std.fs.path.extension(path);
        inline for (mimeTypes) |kv| ***REMOVED***
            if (mem.eql(u8,ext,kv[0])) ***REMOVED***
                return kv[1];
            ***REMOVED***
        ***REMOVED***
        return "application/octet-stream";
    ***REMOVED***

    pub fn init(allocator: anytype) ServerS ***REMOVED***
        return ServerS***REMOVED***
            .server_addr = server_addr,
            .server_port = server_port,
            .allocator = allocator,
        ***REMOVED***;
    ***REMOVED***

    pub fn start(self: *ServerS) !void ***REMOVED***
        //Initialize the server
        const self_addr = try net.Address.parseIp(self.server_addr, self.server_port);
        var listener = try self_addr.listen(.***REMOVED***.reuse_address = true***REMOVED***);
        std.debug.print("Listening on: ***REMOVED***s***REMOVED***:***REMOVED***d***REMOVED***\n", .***REMOVED***self.server_addr, self.server_port***REMOVED***);

        while (listener.accept()) |conn| ***REMOVED***
            std.debug.print("Accepted connection from: ***REMOVED******REMOVED***\n", .***REMOVED***conn.address***REMOVED***);
            var recv_buf: [4096]u8 = undefined;
            var recv_total: usize = 0;
            while (conn.stream.read(recv_buf[recv_total..])) |recv_len| ***REMOVED***
                if (recv_len == 0) break;
                recv_total += recv_len;
                if (mem.containsAtLeast(u8, recv_buf[0..recv_total], 1, "\r\n\r\n")) ***REMOVED***
                    break;
                ***REMOVED***
            ***REMOVED*** else |read_err| ***REMOVED***
                return read_err;
            ***REMOVED***
            const recv_data = recv_buf[0..recv_total];
            if (recv_data.len == 0) ***REMOVED***
                std.debug.print("Got connection but no header!\n", .***REMOVED******REMOVED***);
                continue;
            ***REMOVED***
            const header = try parseHeader(recv_data);
            const path = try parsePath(header.requestLine);
            const mime = mimeForPath(path);
            const buf = openLocalFile(path) catch |err| ***REMOVED***
                if (err == error.FileNotFound) ***REMOVED***
                    _ = try conn.stream.writer().write(http404());
                    continue;
                ***REMOVED*** else ***REMOVED***
                    return err;
                ***REMOVED***
            ***REMOVED***;
            std.debug.print("SENDING----\n", .***REMOVED******REMOVED***);
            const httpHead =
                "HTTP/1.1 200 OK \r\n" ++
                "Connection: close\r\n" ++
                "Content-Type: ***REMOVED***any***REMOVED***\r\n" ++
                "Content-Length: ***REMOVED***any***REMOVED***\r\n" ++
                "\r\n";
            _ = try conn.stream.writer().print(httpHead, .***REMOVED*** mime, buf.len ***REMOVED***);
            _ = try conn.stream.writer().write(buf);
        ***REMOVED*** else |err| ***REMOVED***
            std.debug.print("error in accept: ***REMOVED***any***REMOVED***\n", .***REMOVED***err***REMOVED***);
        ***REMOVED***
    ***REMOVED***
***REMOVED***;