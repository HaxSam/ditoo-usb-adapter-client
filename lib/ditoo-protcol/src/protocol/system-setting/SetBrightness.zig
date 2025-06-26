const Allocator = @import("std").mem.Allocator;
const Packet = @import("../packet.zig");
const CMD = Packet.CMD;

const Self = @This();
pub const command: CMD = .SetBrightness;

level: u8 = 0,

pub fn init(level: u8) Self {
    return Self{
        .level = level,
    };
}

pub fn pack(self: *const Self, allocator: Allocator) !Packet {
    const data = [1]u8{self.level};
    return Packet.init(command, data[0..], allocator);
}
