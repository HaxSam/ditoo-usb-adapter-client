const Allocator = @import("std").mem.Allocator;
const Packet = @import("../packet.zig");
const CMD = Packet.CMD;
const SPP_DEFINE_MODE = Packet.SPP_DEFINE_MODE;

const Self = @This();
pub const command: CMD = .GetWorkingMode;

mode: ?SPP_DEFINE_MODE = null,

pub const init: Self = .{};

pub fn unpack(packet: *const Packet) Self {
    return Self{
        .mode = @enumFromInt(packet.data[0]),
    };
}

pub fn pack(_: *const Self, allocator: Allocator) !Packet {
    const data = [0]u8{};
    return Packet.init(command, data[0..], allocator);
}
