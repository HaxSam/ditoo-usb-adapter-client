const Allocator = @import("std").mem.Allocator;
const Packet = @import("../packet.zig");
const CMD = Packet.CMD;
const SPP_DEFINE_MODE = Packet.SPP_DEFINE_MODE;

const Self = @This();
pub const command: CMD = .SetWorkMode;

mode: SPP_DEFINE_MODE = .BT,

pub fn init(mode: SPP_DEFINE_MODE) Self {
    return Self{
        .mode = mode,
    };
}

pub fn pack(self: *const Self, allocator: Allocator) !Packet {
    const data = [_]u8{@intFromEnum(self.mode)};
    return Packet.init(command, data[0..], allocator);
}
