const std = @import("std");

pub fn alignDown(comptime t: type, alignment: t, value: t) t {
    return value - (value % alignment);
}

pub fn alignUp(comptime t: type, alignment: t, value: t) t {
    return alignDown(t, alignment, value + alignment - 1);
}

pub fn isAligned(comptime t: type, alignment: t, value: t) bool {
    return alignDown(t, alignment, value) == value;
}

fn isRuntime() bool {
    var b = true;
    const v = if (b) @as(u8, 0) else @as(u32, 0);
    _ = &b;
    return @TypeOf(v) == u32;
}

fn sliceAlignCast(comptime t: type, slice: anytype) !(if (std.meta.trait.isConstPtr(@TypeOf(slice.ptr))) []const t else []t) {
    const alignment = @alignOf(t);
    const ptr_type = comptime if (std.meta.trait.isConstPtr(@TypeOf(slice.ptr))) [*]const t else [*]t;
    if (isRuntime() // we can't detect alignment of pointer values at comptime, not that it matters anyways
    and isAligned(usize, alignment, @intFromPtr(slice.ptr)) // base ptr aligned
    and isAligned(usize, alignment, slice.len)) { // length aligned
        return @as(ptr_type, @ptrCast(
            @alignCast(slice.ptr),
        ))[0..@divExact(slice.len, alignment)];
    }
    return error.NotAligned;
}

pub fn alignedCopy(comptime t: type, dest: []u8, src: []const u8) void {
    const dest_aligned = sliceAlignCast(t, dest) catch return std.mem.copy(u8, dest, src);
    const src_aligned = sliceAlignCast(t, src) catch return std.mem.copy(u8, dest, src);
    return std.mem.copy(t, dest_aligned, src_aligned);
}

pub fn alignedFill(comptime t: type, dest: []u8, value: u8) void {
    const dest_aligned = sliceAlignCast(t, dest) catch return std.mem.set(u8, dest, value);
    const big_value = @as(t, @truncate(0x0101010101010101)) * @as(t, value);
    return std.mem.set(t, dest_aligned, big_value);
}
