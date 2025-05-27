const std = @import("std");
const msgpack = @import("msgpack");
const serial = @import("serial");

const bufferType = std.fs.File;

const Pack = msgpack.Pack(
    bufferType,
    bufferType,
    bufferType.WriteError,
    bufferType.ReadError,
    bufferType.write,
    bufferType.read,
);

pub fn main() !void {
    const alloc = std.heap.page_allocator;

    var seriel = try std.fs.cwd().openFile("\\\\.\\COM16", .{ .mode = .read_write });
    defer seriel.close();

    try serial.configureSerialPort(seriel, .{
        .baud_rate = 115200,
        .word_size = .eight,
        .parity = .none,
        .stop_bits = .one,
        .handshake = .none,
    });

    var p: Pack = .init(seriel, seriel);

    //var data = [_]u8{ 0x01, 0x04, 0x00, 0x74, 0x10, 0x88, 0x00, 0x02 }; //@constCast("Hello, World!");
    try p.write(.{ .ext = .{ .data = @constCast(&[_]u8{0}), .type = 0 } });

    var payload_bin: msgpack.Payload = undefined;

    while (true) {
        var payload = p.read(alloc) catch {
            std.time.sleep(1000);
            continue;
        };
        defer payload.free(alloc);

        switch (payload) {
            .ext => {
                std.debug.print("Ext {d}: {any}\n", .{ payload.ext.type, payload.ext.data });
                if (payload.ext.type == 1) {
                    try p.write(.{ .ext = .{ .data = @constCast(&[_]u8{ 177, 33, 129, 100, 226, 158 }), .type = 1 } });
                    //try p.write(.{ .ext = .{ .data = &data, .type = 2 } });
                }
            },
            .map => {
                var iter = payload.map.iterator();
                while (iter.next()) |i| {
                    std.debug.print("{s} {any}\n", .{ i.key_ptr.*, i.value_ptr.bin.value() });
                }
                var v_iter = payload.map.valueIterator();
                payload_bin = v_iter.next().?.*;
                try p.write(.{ .ext = .{ .data = payload_bin.bin.value(), .type = 1 } });
            },
            else => std.debug.print("{any}\n", .{payload}),
        }
    }
}
