const Allocator = @import("std").mem.Allocator;
const Packet = @import("../packet.zig");
const CMD = Packet.CMD;
const SPP_DEFINE_MODE = Packet.SPP_DEFINE_MODE;

pub fn SetWorkMode(mode: ?SPP_DEFINE_MODE) Self {
    return Self.init(mode);
}

const Self = @This();
const DataType = [1]u8;
pub const command: CMD = .SetWorkMode;

data: DataType = .{0},

pub fn init(mode: ?SPP_DEFINE_MODE) Self {
    var self: Self = .{};
    self.data[0] = @intFromEnum(mode orelse .BT);

    return self;
}

pub fn set_mode(self: *Self, mode: SPP_DEFINE_MODE) void {
    self.data[0] = @intFromEnum(mode);
}

pub fn pack(self: *const Self, allocator: Allocator) !Packet {
    return Packet.init(DataType, command, &self.data, allocator);
}
