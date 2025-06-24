pub const Packet = @import("protocol/packet.zig");
pub const system_setting = @import("protocol/system-setting/root.zig");

test {
    const testing = @import("std").testing;
    testing.refAllDecls(@This());
}

test "Packing" {
    const testing = @import("std").testing;
    const allocator = testing.allocator;

    const packet = try Packet.init([1]u8, .SetBrightness, &[_]u8{0x10}, allocator);
    defer packet.deinit();

    const packet_data = try packet.serialize(allocator);
    defer allocator.free(packet_data);
    try testing.expectEqualSlices(u8, &[_]u8{ 1, 4, 0, 116, 16, 136, 0, 2 }, packet_data);
}
