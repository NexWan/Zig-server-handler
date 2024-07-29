const std = @import("std");
const ascii = std.ascii;
    pub const command = enum {
        help,
        play,
        pause,
        next,
        previous,
        shuffle,
        repeat,
        volume,
        search,
        exit,
    };

pub const commands = struct {
    pub const helpCommand = 
    \\ Available commands:
    \\ - play - play the current song
    \\ - pause - pause the current song
    \\ - next - play the next song
    \\ - previous - play the previous song
    \\ - shuffle - shuffle the playlist
    \\ - repeat - repeat the current song
    \\ - volume - change the volume
    \\ - search - search for a song
    \\ - exit - exit the program
;

    pub fn handleCommand(comm: []u8) ![*:0]const u8 {
        // Trim whitespace and convert the input command to lowercase
        const trimmed_comm = std.mem.trim(u8, comm, " \t\n\r");        
        const case = std.meta.stringToEnum(command, trimmed_comm);
        if (case == null) {
            return "Invalid command, please try again!";
        }
        const sel = switch (case.?) {
            command.help => helpCommand,
            command.play => "play",
            command.pause => "pause",
            command.next => "next",
            command.previous => "previous",
            command.shuffle => "shuffle",
            command.repeat => "repeat",
            command.volume => "volume",
            command.search => "search",
            command.exit => "exit",
        };
        return sel;
    }
};