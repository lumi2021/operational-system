pub const debug_ignore: []const KeyValuePair = &[_]KeyValuePair{
    .{ .key = "Main", .value = default },
    .{ .key = "PMM", .value = ignore_all },
    .{ .key = "VMM", .value = ignore_all },
    .{ .key = "IDTM", .value = ignore_all },
    .{ .key = "Paging", .value = ignore_all },
    .{ .key = "Schedue", .value = default },

    .{ .key = "Process A", .value = default },
    .{ .key = "Process B", .value = default },
};

const KeyValuePair = struct { key: []const u8, value: u8 };
const default: u8 = 0b00000000;
const ignore_log: u8 = 0b00000001;
const ignore_err: u8 = 0b00000010;
const ignore_dbg: u8 = 0b00000100;
const ignore_warn: u8 = 0b00001000;
const ignore_all: u8 = 0b00001101;
