const std = @import("std");
const ascii = std.ascii;
const assert = std.debug.assert;
const print = std.debug.print;
const WriteError = std.fs.File.Writer.Error;
const heap = std.heap;
const getStdIn = std.io.getStdOut;
const getStdOut = std.io.getStdOut;
const mem = std.mem;

const builtin = @import("builtin");

const lang = @import("lang/de_DE.zig");

/// caller owns memory
fn getInput(
    allocator: mem.Allocator,
    stdin: anytype,
) (@TypeOf(stdin).NoEofError || mem.Allocator.Error)![]const u8 {
    var input = std.ArrayList(u8).init(allocator);
    var char = try stdin.readByte();
    while (char != '\n' and char != '\r') : (char = try stdin.readByte())
        if (ascii.isPrint(char) or !ascii.isASCII(char)) try input.append(char);
    return input.toOwnedSlice();
}

const Token = union(enum) {
    quit,
    bye,
    search,
    new,
    help,
    name,
    description,
    email,
    tel,
    client,
    order,
    literal: []const u8,

    fn parse(word: []const u8) @This() {
        return inline for (comptime std.meta.fieldNames(@This())) |field| {
            if (comptime std.mem.eql(u8, field, "literal")) continue;
            if (std.mem.eql(u8, word, @field(lang.tokens, field)))
                break @unionInit(@This(), field, {});
        } else .{ .literal = word };
    }
};

const TokenIterator = struct {
    word_iter: mem.TokenIterator(u8, .scalar),

    fn next(self: *@This()) ?Token {
        const word = self.word_iter.next() orelse return null;
        return Token.parse(word);
    }

    fn peek(self: *@This()) ?Token {
        const word = self.word_iter.peek() orelse return null;
        return Token.parse(word);
    }

    fn reset(self: *@This()) void {
        return self.word_iter.reset();
    }

    fn rest(self: @This()) void {
        return self.word_iter.rest();
    }
};

fn getTokenIterator(input: []const u8) TokenIterator {
    return .{ .word_iter = mem.tokenizeScalar(u8, input, ' ') };
}

fn new() WriteError!void {
    try getStdOut().writeAll("new\n");
}

fn edit() WriteError!void {
    try getStdOut().writeAll("edit\n");
}

fn help() WriteError!void {
    try getStdOut().writeAll("help\n");
}

fn search(allocator: mem.Allocator, token_iterator: TokenIterator) WriteError!void {
    const stdin = getStdIn().writer();
    const stdout = getStdOut().writer();
    _ = stdout; // autofix
    var token_iter = init: {
        var iter = token_iterator;
        if (iter.peek()) |_| break: init token_iterator else {
            const input = try getInput(allocator, stdin);
            break :init getTokenIterator(input);
        }
    };
    _ = token_iter; // autofix
}

fn quit(token_iterator: TokenIterator) WriteError!bool {
    const stdout = getStdOut().writer();
    var token_iter = token_iterator;
    if (token_iter.next()) |_| {
        try stdout.writeAll(lang.cmd.help.quit);
        return false;
    } else return true;
}

pub fn main() !void {
    var gpa = heap.GeneralPurposeAllocator(.{}){};
    defer switch (gpa.deinit()) {
        .ok => {},
        .leak => assert(gpa.detectLeaks()),
    };

    const stdin = getStdIn().reader();
    const stdout = getStdOut().writer();

    var arena = heap.ArenaAllocator.init(gpa.allocator());
    defer arena.deinit();
    while (true) : (_ = arena.reset(.retain_capacity)) {
        try stdout.writeAll(lang.prompt);

        const input = getInput(arena.allocator(), stdin) catch |err| switch (err) {
            error.EndOfStream => break,
            else => return err,
        };

        var token_iter = getTokenIterator(input);
        if (token_iter.next()) |token| switch (token) {
            .quit, .bye => if (try quit(token_iter)) break,
            .search => try search(),
            .help => try help(),
            .new => try new(),
            else => try help(),
        };
    }
    try stdout.writeAll(lang.shutdown_prompt);
}

const testing = if (builtin.is_test) std.testing else void;
const skip = error.SkipZigTest;
test {}
