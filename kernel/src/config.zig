pub const input = .{
    .usb = .{ .enable = false },
    .ps2 = .{ .enable = true, .keyboard = true, .mouse = true },
};

pub const max_ioapics = 5;

pub const debug_ignore: []const KeyValuePair = &[_]KeyValuePair{
    .{ .key = "Main", .value = default },
    
    // memory
    .{ .key = "PMM", .value = ignore_all },
    .{ .key = "VMM", .value = ignore_all },
    .{ .key = "Paging", .value = ignore_all },

    // threading
    .{ .key = "schedue", .value = ignore_all },
    .{ .key = "taskman", .value = default },
    .{ .key = "task", .value = default },

    // interruptions
    .{ .key = "IDTM", .value = ignore_all },
    .{ .key = "syscall", .value = ignore_all },

    // file system
    .{ .key = "fs", .value = default },
    .{ .key = "vfs", .value = default },

    // Drivers related
    .{ .key = "Drivers", .value = ignore_all },
    .{ .key = "PCI", .value = default },
    .{ .key = "ps2", .value = default },
    .{ .key = "keyboard", .value = default },
    .{ .key = "mouse", .value = default },

    // Allocations
    .{ .key = "Alloc", .value = ignore_all },

    .{ .key = "ProcessA", .value = default },

    // Debug
    .{ .key = "Stack Tracer", .value = ignore_all },
};

const KeyValuePair = struct { key: []const u8, value: u8 };
const default: u8 = 0b00000000;
const ignore_log: u8 = 0b00000001;
const ignore_err: u8 = 0b00000010;
const ignore_dbg: u8 = 0b00000100;
const ignore_warn: u8 = 0b00001000;
const ignore_all: u8 = 0b00001101;
