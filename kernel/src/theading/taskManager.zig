const os = @import("root").os;
const std = @import("std");
const schedue = os.theading.schedue;
const fs = os.fs;

const ProcessEntryFunction = os.theading.ProcessEntryFunction;
const Task = os.theading.Task;

const write = os.console_write("taskman");
const st = os.stack_tracer;

const TaskItem = ?*Task;

pub var task_list: []TaskItem = undefined;

var thead_count: usize = 0;
pub fn getTheadCount() usize { return thead_count; }

var allocator: std.mem.Allocator = undefined;

pub fn init() void {
    st.push(@src()); defer st.pop();

    allocator = os.memory.allocator;
    task_list = allocator.alloc(TaskItem, 0x200) catch unreachable;
    for (0..task_list.len) |i| { task_list[i] = null; }
}

pub fn run_process(taskName: [:0]u8, entry: ProcessEntryFunction, args: ?*const anyopaque, argssize: usize) !void {
    st.push(@src()); defer st.pop();

    write.dbg("Scheduing task \"{s}\" to be initialized...", .{taskName});

    const task = Task.allocate_new();
    try task.alloc_stack();

    const talloc = task.taskAllocator.allocator();

    if (argssize > 0) if (args) |a| {
        const argsptr = try talloc.alloc(u8, argssize);
        const argssrc = @as([*]u8, @constCast(@alignCast(@ptrCast(a))))[0..argssize];

        std.mem.copyForwards(u8, @constCast(argsptr), argssrc);

        task.args_pointer = @intFromPtr(argsptr.ptr);
    };

    task.name = taskName;
    task.state = .new;
    task.entry_pointer = @intFromPtr(entry);

    const tid = get_first_free_tid();
    task.id = tid;

    // add task to task list
    task_list[tid] = task;
    thead_count += 1;

    // create task virtual directory
    var buf: [128]u8 = undefined;
    const procdir = fs.make_dir(std.fmt.bufPrint(&buf, "sys:/proc/{X:0>5}", .{tid}) catch unreachable) catch unreachable;
    _ = procdir.branch("stdio", .{ .pipe = .{ .pipePtr = task.stdio } });
}

pub fn kill_process(tid: usize) void {
    st.push(@src()); defer st.pop();

    const curr = getTask(tid) catch return;
    task_list[tid] = null;

    curr.destry();
    curr.taskAllocator.deinit();

    write.dbg("Task destroyed", .{});

    thead_count -= 1;
}

pub inline fn getTask(tid: usize) error{invalidTid}!*Task {
    const target = task_list[tid];
    if (target == null) return error.invalidTid;
    return target.?;
}
pub fn get_first_free_tid() usize {
    st.push(@src()); defer st.pop();

    for (task_list, 1..) |e, i| {
        if (e == null) return i;
    }
    
    // TODO increase thead list
    unreachable;
}
