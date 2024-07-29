const std = @import("std");
const net = std.net;
const fs = std.fs;
const mem = std.mem;

const server_addr = "0.0.0.0";
const server_port = 8000;

pub const ServerS = struct {
    server_addr: []const u8,
    server_port: u16,
    allocator: std.mem.Allocator,

    pub const ServerFileError = error{
        HeaderMalFormed,
        MethodNotSupported,
        ProtocolNotSupported,
        UnkownMimeType,
    };

    const mimeTypes = .{
        .{"html", "text/html"},
        .{"css", "text/css"},
        .{".png", "image/png"},
        .{".jpg", "image/jpeg"},
        .{".jpeg", "image/jpeg"},
    };

    const HeaderNames = enum {
        Host,
        @"User-Agent",
    };

    const HTTPHeader = struct {
        requestLine: []const u8,
        host: []const u8,
        userAgent: []const u8,

        pub fn print(self: HTTPHeader) void {
            std.debug.print("{s} - {s}\n", .{
                self.requestLine,
                self.host,
            });
        }
    };

    pub fn parseHeader(header: []const u8) !HTTPHeader {
        var headerStruct = HTTPHeader {
            .requestLine = undefined,
            .host = undefined,
            .userAgent = undefined,
        };
        var headerIter = mem.tokenizeSequence(u8, header, " \r\n");
        headerStruct.requestLine = headerIter.next() orelse return ServerFileError.HeaderMalFormed;
        while (headerIter.next()) |line| {
            const nameSlice = mem.sliceTo(line, ':');
            if(nameSlice.len == line.len) return ServerFileError.HeaderMalFormed;
            const headerName = std.meta.stringToEnum(HeaderNames,nameSlice) orelse continue;
            const headerValue = mem.trimLeft(u8, line[nameSlice.len + 1 ..], " ");
            switch (headerName) {
                .Host => headerStruct.host = headerValue,
                .@"User-Agent" => headerStruct.userAgent = headerValue,
            }
        }
        return headerStruct;
    }

    pub fn parsePath(requestLine: []const u8) ![]const u8 {
        var requestLineIter = mem.tokenizeScalar(u8, requestLine, ' ');
        const method = requestLineIter.next().?;
        if (!mem.eql(u8,method,"GET")) return ServerFileError.MethodNotSupported;
        const path = requestLineIter.next().?;
        if (path.len <= 0) return error.NoPath;
        var proto = requestLineIter.next().?;
        proto = mem.trim(u8, proto, " \r\n");
        std.debug.print("proto: {s}\n", .{proto});
        //if (!mem.eql(u8, proto, "HTTP/1.1")) return ServerFileError.ProtocolNotSupported;
        if(mem.eql(u8,path,"/")) return "/index.html";
        return path;
    }

    /// Weird implementation of opening the file at the server
    /// If the file ends with .html, it will open the file as is
    /// If not, it will append .html to the file and try opening it again
    /// If the file is not found, it will return a 404 error
    /// Not the best implementation, but it works for now
    pub fn openLocalFile(path: []const u8, allocator: anytype) ![]const u8 {
        const memory = std.heap.page_allocator;
        const maxSize = std.math.maxInt(usize);
        const localPath = path[1..];
        const endsWithHtml = checkFileEndsWithHtml(localPath);
        
        if (endsWithHtml) {
            std.debug.print("HTML file {s}\n", .{localPath});
            const file = fs.cwd().openFile(localPath, .{}) catch |err| switch (err) {
                error.FileNotFound => {
                    std.debug.print("File not found: {s}\n", .{localPath});
                    return error.FileNotFound;
                },
                else => return err,
                };
            defer file.close();
            std.debug.print("file: {any}\n", .{file});
            return try file.readToEndAlloc(memory, maxSize);
        }else { //Needs to use GeneralPurposeAllocator to allocate memory, otherwise it will crash
        // The purpose is to try and mimic must https servers that serve html files without the need of the extension, idk if it's a good idea lol
            const newPath = try std.fmt.allocPrintZ(allocator, "{s}.html", .{path});
            defer allocator.free(newPath);
            std.debug.print("newPath: {s}\n", .{newPath}); 
            const file = fs.cwd().openFile(newPath[1..], .{}) catch |err| switch (err) {
                error.FileNotFound => {
                    std.debug.print("File not found: {s}\n", .{newPath});
                    return error.FileNotFound;
                },
                else => return err,
                };
            defer file.close();
            return try file.readToEndAlloc(memory, maxSize);
        }
        return error.UnkownMimeType;
    }

    pub fn http404() []const u8 {
        return 
        \\ HTTP/1.1 404 NOT FOUND
        \\Connection: close
        \\Content-Type: text/html; charset=UTF-8
        \\Content-Length: 9
        \\
        \\NOT FOUND
        ;
    }

    pub fn mimeForPath(path: []const u8) ![]const u8 {
        const ext = std.fs.path.extension(path);
        inline for (mimeTypes) |kv| {
            if (mem.eql(u8,ext,kv[0])) {
                return kv[1];
            }
        }
        return "application/octet-stream";
    }

    pub fn init(allocator: anytype) ServerS {
        return ServerS{
            .server_addr = server_addr,
            .server_port = server_port,
            .allocator = allocator,
        };
    }

    pub fn start(self: *ServerS) !void {
        //Initialize the server
        const self_addr = try net.Address.parseIp(self.server_addr, self.server_port);
        var listener = try self_addr.listen(.{.reuse_address = true});
        std.debug.print("Listening on: {s}:{d}\n", .{self.server_addr, self.server_port});

        while (listener.accept()) |conn| {
            std.debug.print("Accepted connection from: {}\n", .{conn.address});
            var recv_buf: [4096]u8 = undefined;
            var recv_total: usize = 0;
            while (conn.stream.read(recv_buf[recv_total..])) |recv_len| {
                if (recv_len == 0) break;
                recv_total += recv_len;
                if (mem.containsAtLeast(u8, recv_buf[0..recv_total], 1, "\r\n\r\n")) {
                    break;
                }
            } else |read_err| {
                return read_err;
            }
            const recv_data = recv_buf[0..recv_total];
            if (recv_data.len == 0) {
                std.debug.print("Got connection but no header!\n", .{});
                continue;
            }
            const header = try parseHeader(recv_data);
            const path = try parsePath(header.requestLine);
            const mime = mimeForPath(path);
            const buf = openLocalFile(path, self.allocator) catch |err| {
                if (err == error.FileNotFound) {
                    _ = try conn.stream.writer().write(http404());
                    continue;
                } else {
                    return err;
                }
            };
            std.debug.print("SENDING----\n", .{});
            const httpHead =
                "HTTP/1.1 200 OK \r\n" ++
                "Connection: close\r\n" ++
                "Content-Type: {any}\r\n" ++
                "Content-Length: {any}\r\n" ++
                "\r\n";
            _ = try conn.stream.writer().print(httpHead, .{ mime, buf.len });
            _ = try conn.stream.writer().write(buf);
        } else |err| {
            std.debug.print("error in accept: {any}\n", .{err});
        }
    }

    pub fn checkFileEndsWithHtml(path: []const u8) bool {
        return mem.endsWith(u8, path, ".html");
    }
};