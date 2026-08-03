const std = @import("std");
const builtin = @import("builtin");

// =====================[  SETUP ALLOCATOR  ]=====================
// const utils = @import("utils.zig");
// const ca = utils.get_allocator(.Adaptive);
// const alloc = ca.allocator();
// defer ca.deinit();
// =========================[ END SETUP ]=========================
const AllocatorKind = enum { Adaptive, Arena };
pub fn get_allocator(comptime a_kind: AllocatorKind) type {
    return struct {
        const is_debug = builtin.mode == .Debug or builtin.mode == .ReleaseSafe;

        var debug_allocator: std.heap.DebugAllocator(.{}) = .init;
        const base_allocator = if (is_debug) debug_allocator.allocator() else std.heap.smp_allocator;
        var arena = std.heap.ArenaAllocator.init(base_allocator);

        pub fn allocator() std.mem.Allocator {
            return switch (a_kind) {
                .Adaptive => base_allocator,
                .Arena => arena.allocator(),
            };
        }

        pub fn deinit() void {
            if (a_kind == .Arena) arena.deinit();
            _ = if (is_debug) debug_allocator.deinit();
        }
    };
}

// =====================[  SETUP PRINTER  ]=====================
// const utils = @import("utils.zig");
// const println = utils.println;
// =========================[ END SETUP ]=========================
var stdout_buffer: [4096]u8 = undefined;
var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
const stdout = &stdout_writer.interface;
pub fn println(comptime fmt: []const u8, args: anytype, flush: bool) void {
    stdout.print(fmt, args) catch @panic("Printing error!");
    stdout.print("\n", .{}) catch @panic("Printing error!");
    if (flush) stdout.flush() catch @panic("Printing error!");
}
