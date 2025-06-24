const std = @import("std");
const Allocator = std.mem.Allocator;

pub const CMD = enum(u8) {
    // System Setting
    SetBrightness = 0x74,
    SetWorkMode = 0x05,
    GetWorkingMode = 0x13,
    SendSdStatus = 0x15,
    SetBootGif = 0x52,
    GetDeviceTemp = 0x59,
    SendNetTemp = 0x5D,
    SendNetTempDisp = 0x5E,
    SendCurrentTemp = 0x5F,
    GetNetTempDisp = 0x73,
    SetDeviceName = 0x76,
    SetLowPowerSwitch = 0xB2,
    GetLowPowerSwitch = 0xB3,
    SetTempType = 0x2B,
    SetHourType = 0x2C,
    SetSongDisCtrl = 0x83,
    SetBluePassword = 0x27,
    SetPoweronVoiceVol = 0xBB,
    SetPoweronChannel = 0x8A,
    SetAutoPowerOff = 0xAB,
    GetAutoPowerOff = 0xAC,
    SetSoundCtrl = 0xA7,
    GetSoundCtrl = 0xA8,

    // Music Play
    GetSdPlayName = 0x06,
    GetSdMusicList = 0x07,
    SetVol = 0x08,
    GetVol = 0x09,
    SetPlayStatus = 0x0A,
    GetPlayStatus = 0x0B,
    SetSdPlayMusicId = 0x11,
    SetSdLastNext = 0x12,
    SendSdListOver = 0x14,
    GetSdMusicListTotalNum = 0x7D,
    GetSdMusicInfo = 0xB4,
    SetSdMusicInfo = 0xB5,
    SetSdMusicPostion = 0xB8,
    SetSdMusicPlayMode = 0xB9,
    AppNeedGetMusicList = 0x47,
    //SendSdCardStatus = 0x15,

    // Alarm Memorial
    GetAlarmTime = 0x42,
    SetAlarmTime = 0x43,
    SetAlarmGif = 0x51,
    SetMemorialTime = 0x54,
    GetMemorialTime = 0x53,
    SetMemorialGif = 0x55,
    SetAlarmListen = 0xA5,
    SetAlarmVol = 0xA6,
    SetAlarmVolCtrl = 0x82,

    // Time Plan
    SetTimeManageInfo = 0x56,
    SetTimeManageCtrl = 0x57,

    // Tool
    GetToolInfo = 0x71,
    SetToolInfo = 0x72,

    // Sleep
    GetSleepScene = 0xA2,
    SetSleepSceneListen = 0xA3,
    SetSceneVol = 0xA4,
    SetSleepColor = 0xAD,
    SetSleepLight = 0xAE,
    SetSleepAutoOff = 0x40,
    SetSleepScene = 0x41,

    // Game
    SendGameShark = 0x88,
    SetGame = 0xA0,
    SetGameCtrlInfo = 0x17,
    SetGameCtrlKeyUpInfo = 0x21,

    // Light
    SetLightMode = 0x45,
    GetLightMode = 0x46,
    SetLightPic = 0x44,
    SetLightPhoneGif = 0x49,
    SetGifSpeed = 0x16,
    SetLightPhoneWordAttr = 0x87,
    AppNewSendGifCmd = 0x8B,
    SetUserGif = 0xB1,
    ModifyUserGifItems = 0xB6,
    AppNewUserDefine = 0x8C,
    AppBig64UserDefine = 0x8D,
    AppGetUserDefineInfo = 0x8E,
    SetRhythmGif = 0xB7,
    AppSendEqGif = 0x1B,
    DrawingMulPadCtrl = 0x3A,
    DrawingBigPadCtrl = 0x3B,
    DrawingPadCtrl = 0x58,
    DrawingPadExit = 0x5A,
    DrawingMulEncodeSinglePic = 0x5B,
    DrawingMulEncodePic = 0x5C,
    DrawingMulEncodeGifPlay = 0x6B,
    DrawingEncodeMoviePlay = 0x6C,
    DrawingMulEncodeMoviePlay = 0x6D,
    DrawingCtrlMoviePlay = 0x6E,
    DrawingMulPadEnter = 0x6F,
    SandPaintCtrl = 0x34,
    PicScanCtrl = 0x35,
};

pub const SPP_DEFINE_MODE = enum(u4) {
    BT = 0,
    FM = 1,
    LINEIN = 2,
    SD = 3,
    USBHOST = 4,
    RECORD = 5,
    RECORDPLAY = 6,
    UAC = 7,
    PHONE = 8,
    DIVOOM_SHOW = 9,
    ALARM_SET = 10,
    GAME = 11,
};

const Packet = @This();

cmd: CMD,
data: []u8,
allocator: Allocator,

pub fn init(T: type, cmd: CMD, data: *const T, allocator: Allocator) !Packet {
    return Packet{
        .cmd = cmd,
        .data = try allocator.dupe(u8, data),
        .allocator = allocator,
    };
}

pub fn deinit(self: *const Packet) void {
    self.allocator.free(self.data);
}

pub fn serialize(self: *const Packet, allocator: Allocator) ![]u8 {
    const buf = try allocator.alloc(u8, self.data.len + 7);

    buf[0] = 0x01;
    std.mem.writePackedInt(u16, buf, 8, @intCast(self.data.len + 3), .little);
    buf[3] = @intFromEnum(self.cmd);
    std.mem.copyForwards(u8, buf[4 .. self.data.len + 4], self.data);
    std.mem.writePackedInt(u16, buf, 8 * (self.data.len + 4), calc_checksum(self), .little);
    buf[buf.len - 1] = 0x02;

    return buf;
}

fn calc_checksum(self: *const Packet) u16 {
    var checksum: u16 = @intFromEnum(self.cmd);
    checksum = @truncate(checksum + self.data.len + 3);
    for (self.data) |d| {
        checksum = @truncate(checksum + d);
    }

    return checksum;
}
