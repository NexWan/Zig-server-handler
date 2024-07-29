// This file while handle operations related to the Spotify API

const std = @import("std");
const Server = @import("server.zig").ServerS;
const json = std.json;
const utils = @import("utils.zig").Utils;

pub const Spotify = struct {
    client_id: []const u8,
    client_secret: []const u8,
    allocator: std.mem.Allocator,

    const params = struct {
        response_type: []const u8,
        client_id: []const u8,
        scope: []const u8,
    }

    pub fn init(client_id: []const u8, client_secret: []const u8, allocator: anytype) Spotify {
        return Spotify{
            .client_id = client_id,
            .client_secret = client_secret,
            .allocator = allocator,
        };
    }

    pub fn getAuthCode(self:*Spotify) ![]const u8 {
        const url = "https://accounts.spotify.com/api/token";
        const body = "user-read-private user-read-email";
        const state = utils.generateRandomString(self.allocator,16);
    }
};