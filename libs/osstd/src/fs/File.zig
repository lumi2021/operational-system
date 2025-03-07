const root = @import("../osstd.zig");
const std = @import("std");

descriptor: isize,
flags: AccessFlags,
kind: Kind,

pub fn open(path: [:0]u8, flags: AccessFlags) FileError!@This() {
    const syscall_res = root.doSystemCall(.open_file_descriptor, @intFromPtr(path.ptr), @bitCast(flags), 0, 0);

    if (syscall_res.err != .NoError) return switch (syscall_res.err) {
        .FileNotFound => FileError.fileNotFound,
        .PathNotFound => FileError.pathNotFound,
        .AccessDenied => FileError.accessDenied,
        .InvalidPath => FileError.invalidPath,
        .NotAFile => FileError.notAFile,
        
        else => {
            root.debug.print("unhandled error: {s}\n", .{@tagName(syscall_res.err)});
            return error.Undefined;
        }
    };

    const descriptor: isize = @bitCast(syscall_res.res);

    return .{
        .descriptor = descriptor,
        .flags = flags,
        .kind = .file,
    };
}
pub fn close(self: @This()) void {
    if (self.descriptor == -1) @panic("Invalid descriptor!");
    _ = root.doSystemCall(.close_file_descriptor, @bitCast(self.descriptor), 0, 0, 0);
}

pub fn writeBytes(self: @This(), data: []u8, pos: usize) FileError!void {
    const res = root.doSystemCall(.write, @bitCast(self.descriptor), @intFromPtr(data.ptr), data.len, pos);
    if (res.err != .NoError) return switch (res.err) {

        else => {
            root.debug.print("Unhandled error: {s}", .{@tagName(res.err)});
            return error.Undefined;
        }
    };
}
pub fn readBytes(self: @This(), buf: []u8, pos: usize) FileError!void {
    const res = root.doSystemCall(.read, @bitCast(self.descriptor), @intFromPtr(buf.ptr), buf.len, pos);
    if (res.err != .NoError) return switch (res.err) {

        else => {
            root.debug.print("Unhandled error: {s}", .{@tagName(res.err)});
            return error.Undefined;
        }
    };
}

pub fn printf(self: @This(), comptime str: []const u8, args: anytype) FileError!void {
    var buf: [1024]u8 = undefined;
    const res = std.fmt.bufPrint(&buf, str, args) catch unreachable;
    try self.writeBytes(res, 0);
}

pub const Kind = enum {
    file,
    directory,
    device,
    input_output,
};
pub const AccessFlags = packed struct(u64) {
    read: bool = false,
    write: bool = false,
    execute: bool = false,
    create_new: bool = false,
    _: u60 = undefined,
};
pub const FileError = error{
    fileNotFound,
    pathNotFound,
    accessDenied,
    invalidPath,
    notAFile,

    Undefined,
};
