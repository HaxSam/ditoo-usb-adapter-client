const Packet = @import("../packet.zig");

pub const SetBrightness = @import("SetBrightness.zig").SetBrightness;
pub const SetWorkMode = @import("SetWorkMode.zig").SetWorkMode;

test "SetBrightness" {
    const testing = @import("std").testing;
    const allocator = testing.allocator;

    const packet = try SetBrightness(0x10).pack(allocator);
    defer packet.deinit();

    const packet_data = try packet.serialize(allocator);
    defer allocator.free(packet_data);
    try testing.expectEqualSlices(u8, &[_]u8{ 1, 4, 0, 116, 16, 136, 0, 2 }, packet_data);
}

test "SetWorkMode" {
    const testing = @import("std").testing;
    const allocator = testing.allocator;

    const packet = try SetWorkMode(.GAME).pack(allocator);
    defer packet.deinit();

    const packet_data = try packet.serialize(allocator);
    defer allocator.free(packet_data);
    try testing.expectEqualSlices(u8, &[_]u8{ 1, 4, 0, 5, 11, 20, 0, 2 }, packet_data);
}
