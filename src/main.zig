const std = @import("std");
const zigimg = @import("zigimg");

fn writePixel(fb: *zigimg.Image, x: usize, y: usize, color: zigimg.color.Rgb24) void {
    if (x >= fb.width or y >= fb.height) return;
    const flipped_y = fb.height - 1 - y;
    fb.pixels.rgb24[flipped_y * fb.width + x] = color;
}

fn line(fb: *zigimg.Image, ax: f32, ay: f32, bx: f32, by: f32, color: zigimg.color.Rgb24) void {
    if (ax > bx) { //make it left-to-right
        line(fb, bx, by, ax, ay, color);
    }
    line(fb, ax, ay, bx, by, color);
}

fn drawLine(fb: *zigimg.Image, ax: f32, ay: f32, bx: f32, by: f32, color: zigimg.color.Rgb24) void {
    var x: f32 = ax;
    while (x < bx) : (x += 1.0){
        const t: f32 = (x-ax) / (bx-ax);
        const y: usize = @intFromFloat(std.math.round(ay + (by-ay)*t));
        writePixel(fb, @as(usize, @intFromFloat(x)), y, color);
    }
}

pub fn main(init: std.process.Init) !void {
    const allocator = init.gpa;
    const io = init.io;

    const width = 64;
    const height = 64;

    var framebuffer = try zigimg.Image.create(allocator, width, height, .rgb24);
    defer framebuffer.deinit(allocator);

    const black = zigimg.color.Rgb24{ .r = 0, .g = 0, .b = 0 };
    const blue = zigimg.color.Rgb24{ .r = 0, .g = 0, .b = 255 };
    const green= zigimg.color.Rgb24{ .r = 0, .g = 255, .b = 0 };
    const red= zigimg.color.Rgb24{ .r = 255, .g = 0, .b = 0 };
    const white = zigimg.color.Rgb24{ .r = 255, .g = 255, .b = 255 };
    const yellow = zigimg.color.Rgb24{ .r = 255, .g = 255, .b = 0 };

    const ax: f32 = 7;
    const ay: f32 = 3;
    const bx: f32 = 12;
    const by: f32 = 37;
    const cx: f32 = 62;
    const cy: f32 = 53;

    // Make the whole image black
    for (framebuffer.pixels.rgb24) |*p| p.* = black;

    writePixel(
        &framebuffer,
        @as(usize, @intFromFloat(ax)),
        @as(usize, @intFromFloat(ay)),
        white
    );
    writePixel(
        &framebuffer,
        @as(usize, @intFromFloat(bx)),
        @as(usize, @intFromFloat(by)),
        white
    );
    writePixel(
        &framebuffer,
        @as(usize, @intFromFloat(cx)),
        @as(usize, @intFromFloat(cy)),
        white
    );

    line(&framebuffer, ax, ay, bx, by, blue);
    line(&framebuffer, cx, cy, bx, by, green);
    line(&framebuffer, cx, cy, ax, ay, yellow);
    line(&framebuffer, ax, ay, cx, cy, red);

    var write_buffer: [zigimg.io.DEFAULT_BUFFER_SIZE]u8 = undefined;
    try framebuffer.writeToFilePath(allocator, io, "framebuffer.tga", write_buffer[0..], .{ .tga = .{} });
}
