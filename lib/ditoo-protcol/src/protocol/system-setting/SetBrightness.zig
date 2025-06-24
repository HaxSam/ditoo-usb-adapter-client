const Allocator = @import("std").mem.Allocator;
const Packet = @import("../packet.zig");
const CMD = Packet.CMD;

pub fn SetBrightness(level: ?u8) Self {
    return Self.init(level);
}

const Self = @This();
const DataType = [1]u8;
pub const command: CMD = .SetBrightness;

data: DataType = .{0},

pub fn init(level: ?u8) Self {
    var self: Self = .{};
    self.data[0] = level orelse 0;

    return self;
}

pub fn set_brightness(self: *Self, level: u8) void {
    self.data[0] = level;
}

pub fn pack(self: *const Self, allocator: Allocator) !Packet {
    return Packet.init(DataType, command, &self.data, allocator);
}
