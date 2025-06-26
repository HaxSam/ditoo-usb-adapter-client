const Packet = @import("../packet.zig");

pub const SetBrightness = @import("SetBrightness.zig");
pub const SetWorkMode = @import("SetWorkMode.zig");
pub const GetWorkingMode = @import("GetWorkingMode.zig");

test "SetBrightness" {
    const testing = @import("std").testing;
    const allocator = testing.allocator;

    const packet = try SetBrightness.init(0x10).pack(allocator);
    defer packet.deinit();

    const packet_data = try packet.serialize(allocator);
    defer allocator.free(packet_data);
    try testing.expectEqualSlices(u8, &[_]u8{ 0x01, 0x04, 0x00, 0x74, 0x10, 0x88, 0x00, 0x02 }, packet_data);
}

test "SetWorkMode" {
    const testing = @import("std").testing;
    const allocator = testing.allocator;

    const packet = try SetWorkMode.init(.GAME).pack(allocator);
    defer packet.deinit();

    const packet_data = try packet.serialize(allocator);
    defer allocator.free(packet_data);
    try testing.expectEqualSlices(u8, &[_]u8{ 0x01, 0x04, 0x00, 0x05, 0x0B, 0x14, 0x00, 0x02 }, packet_data);
}

test "GetWorkingMode" {
    const testing = @import("std").testing;
    const allocator = testing.allocator;

    {
        const packet = try GetWorkingMode.init.pack(allocator);
        defer packet.deinit();

        const packet_data = try packet.serialize(allocator);
        defer allocator.free(packet_data);

        try testing.expectEqualSlices(u8, &[_]u8{ 0x01, 0x03, 0x00, 0x13, 0x16, 0x00, 0x02 }, packet_data);
    }

    {
        const packet_data = [_]u8{ 0x01, 0x05, 0x00, 0x04, 0x13, 0x0B, 0x2D, 0x00, 0x02 };

        const packet = try Packet.deserialize(@TypeOf(packet_data), &packet_data, allocator);
        defer packet.deinit();

        const working_mode = GetWorkingMode.unpack(&packet);

        try testing.expectEqual(Packet.SPP_DEFINE_MODE.GAME, working_mode.mode);
    }
}
