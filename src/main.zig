const std = @import("std");
const rl = @cImport({
    @cInclude("raylib.h");
});

const assert = std.debug.assert;

const screenHeight = 720;
const screenWidth = 1080;

const rows = 10;
const columns = 10;
const numberOfTiles = rows * columns;
const tileSize = 40;
var originalGrid: [numberOfTiles * 2]f32 = undefined;
var grid: [numberOfTiles * 2]f32 = undefined;

pub fn main() !void {
    rl.SetConfigFlags(rl.FLAG_VSYNC_HINT);
    rl.SetTargetFPS(60);
    rl.InitWindow(screenWidth, screenHeight, "isometric grid");
    defer rl.CloseWindow();

    setupOriginalGrid();
    transformGrid(1, 0.4, -1, 0.4);

    while (!rl.WindowShouldClose()) {
        try update();
        try draw();
    }
}

fn update() !void {
    if (rl.IsKeyPressed(rl.KEY_ESCAPE)) rl.CloseWindow();
}

fn draw() !void {
    rl.BeginDrawing();
    defer rl.EndDrawing();
    rl.ClearBackground(rl.BLACK);

    for (0..grid.len) |i| {
        const index = i * 2;
        if (index >= grid.len) break;

        const x = index + 0;
        const y = index + 1;
        assert(x < grid.len);
        assert(y <= grid.len);

        rl.DrawPixel(@intFromFloat(grid[x]), @intFromFloat(grid[y]), rl.YELLOW);
    }

    rl.DrawFPS(rl.GetScreenWidth() - 95, 10);
}

inline fn setupOriginalGrid() void {
    comptime var index: usize = 0;
    inline for (0..rows) |row| {
        inline for (0..columns) |column| {
            if (index >= originalGrid.len) break;

            const x = index + 0;
            const y = index + 1;
            assert(x < grid.len);
            assert(y <= grid.len);

            originalGrid[x] = @floatFromInt(column * tileSize);
            originalGrid[y] = @floatFromInt(row * tileSize);

            index += 2;
        }
    }
}

fn transformGrid(ax: f32, ay: f32, bx: f32, by: f32) void {
    for (0..grid.len) |i| {
        const index = i * 2;
        if (index >= grid.len) break;

        const x = index + 0;
        const y = index + 1;
        assert(x < grid.len);
        assert(y <= grid.len);

        const transformedX: f32 = originalGrid[x] * ax + originalGrid[y] * bx;
        const transformedY: f32 = originalGrid[x] * ay + originalGrid[y] * by;

        grid[x] = transformedX;
        grid[y] = transformedY;
    }
}

fn matrixMultiplication() void {}
