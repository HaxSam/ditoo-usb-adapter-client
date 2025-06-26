pub const Packet = @import("protocol/packet.zig");
pub const system_setting = @import("protocol/system-setting/root.zig");

test {
    const testing = @import("std").testing;
    testing.refAllDecls(@This());
}

test "Packing" {
    const testing = @import("std").testing;
    const allocator = testing.allocator;

    const packet = try Packet.init(.SetBrightness, ([_]u8{0x10})[0..], allocator);
    defer packet.deinit();

    const packet_data = try packet.serialize(allocator);
    defer allocator.free(packet_data);
    try testing.expectEqualSlices(u8, &[_]u8{ 0x01, 0x04, 0x00, 0x74, 0x10, 0x88, 0x00, 0x02 }, packet_data);
}

test "Unpacking" {
    const testing = @import("std").testing;
    const allocator = testing.allocator;

    const packet_data = [_]u8{ 0x01, 0x04, 0x00, 0x74, 0x10, 0x88, 0x00, 0x02 };

    const packet = try Packet.deserialize(@TypeOf(packet_data), &packet_data, allocator);
    defer packet.deinit();

    try testing.expectEqual(Packet.CMD.SetBrightness, packet.cmd);
    try testing.expectEqual(0x10, packet.data[0]);
}
