const std = @import("std");
const rl = @cImport({
    @cInclude("raylib.h");
});

const assert = std.debug.assert;

const screenHeight = 720;
const screenWidth = 1080;

// grid properties
const rows = 10;
const columns = 10;
const numberOfTiles = rows * columns;
const tileSize = 40;
var originalGrid: [numberOfTiles * 2]f32 = undefined;
var grid: [numberOfTiles * 2]f32 = undefined;

var originalVerticalGridLinesStart: [numberOfTiles * 2]f32 = undefined;
var originalVerticalGridLinesEnd: [numberOfTiles * 2]f32 = undefined;
var verticalGridLinesStart: [numberOfTiles * 2]f32 = undefined;
var verticalGridLinesEnd: [numberOfTiles * 2]f32 = undefined;

var originalHorizontalGridLinesStart: [numberOfTiles * 2]f32 = undefined;
var originalHorizontalGridLinesEnd: [numberOfTiles * 2]f32 = undefined;
var horizontalGridLinesStart: [numberOfTiles * 2]f32 = undefined;
var horizontalGridLinesEnd: [numberOfTiles * 2]f32 = undefined;

// grid visualization properties
var offsetX: f32 = 0;
var offsetY: f32 = 0;
var tilt: f32 = 0.4;

pub fn main() !void {
    rl.SetConfigFlags(rl.FLAG_VSYNC_HINT);
    rl.SetTargetFPS(60);
    rl.InitWindow(screenWidth, screenHeight, "isometric grid");
    defer rl.CloseWindow();

    generateOriginalGrid();
    transformGrid(1, tilt, -1, tilt);

    while (!rl.WindowShouldClose()) {
        try update();
        try draw();
    }
}

fn update() !void {
    if (rl.IsKeyPressed(rl.KEY_ESCAPE)) rl.CloseWindow();
    if (rl.IsKeyDown(rl.KEY_SEMICOLON)) offsetX += 10;
    if (rl.IsKeyDown(rl.KEY_J)) offsetX -= 10;
    if (rl.IsKeyDown(rl.KEY_L)) offsetY -= 10;
    if (rl.IsKeyDown(rl.KEY_K)) offsetY += 10;
    if (rl.IsKeyDown(rl.KEY_R)) tiltBoard(-0.01);
    if (rl.IsKeyDown(rl.KEY_F)) tiltBoard(0.01);
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

        rl.DrawPixel(@intFromFloat(grid[x] + offsetX), @intFromFloat(grid[y] + offsetY), rl.YELLOW);
        rl.DrawLine(
            @intFromFloat(verticalGridLinesStart[x] + offsetX),
            @intFromFloat(verticalGridLinesStart[y] + offsetY),
            @intFromFloat(verticalGridLinesEnd[x] + offsetX),
            @intFromFloat(verticalGridLinesEnd[y] + offsetY),
            rl.BLUE,
        );
        rl.DrawLine(
            @intFromFloat(horizontalGridLinesStart[x] + offsetX),
            @intFromFloat(horizontalGridLinesStart[y] + offsetY),
            @intFromFloat(horizontalGridLinesEnd[x] + offsetX),
            @intFromFloat(horizontalGridLinesEnd[y] + offsetY),
            rl.BLUE,
        );
    }

    rl.DrawFPS(rl.GetScreenWidth() - 95, 10);
}

inline fn generateOriginalGrid() void {
    const halfTile = tileSize / 2;
    comptime var index: usize = 0;
    inline for (0..rows) |row| {
        inline for (0..columns) |column| {
            if (index >= originalGrid.len) break;

            const x = index + 0;
            const y = index + 1;
            assert(x < grid.len);
            assert(y <= grid.len);

            // grid tiles coordinates
            originalGrid[x] = @floatFromInt(column * tileSize);
            originalGrid[y] = @floatFromInt(row * tileSize);

            // grid lines coordinates
            originalVerticalGridLinesStart[x] = @floatFromInt(column * tileSize + halfTile);
            originalVerticalGridLinesStart[y] = -halfTile;
            originalVerticalGridLinesEnd[x] = originalGrid[x] + halfTile;
            originalVerticalGridLinesEnd[y] = tileSize * rows - halfTile;

            index += 2;

            if (column > 0) continue;

            originalHorizontalGridLinesStart[x] = -halfTile;
            originalHorizontalGridLinesStart[y] = @floatFromInt(row * tileSize + halfTile);
            originalHorizontalGridLinesEnd[x] = tileSize * columns - halfTile;
            originalHorizontalGridLinesEnd[y] = originalGrid[y] + halfTile;
        }
    }
}

fn transformPoints(pointX: f32, pointY: f32, ax: f32, ay: f32, bx: f32, by: f32) [2]f32 {
    const transformedX: f32 = pointX * ax + pointY * bx;
    const transformedY: f32 = pointX * ay + pointY * by;
    return [2]f32{ transformedX, transformedY };
}

fn transformGrid(ax: f32, ay: f32, bx: f32, by: f32) void {
    for (0..grid.len) |i| {
        const index = i * 2;
        if (index >= grid.len) break;

        const x = index + 0;
        const y = index + 1;
        assert(x < grid.len);
        assert(y <= grid.len);

        const transformedPoints: [2]f32 = transformPoints(originalGrid[x], originalGrid[y], ax, ay, bx, by);
        grid[x] = transformedPoints[0];
        grid[y] = transformedPoints[1];

        // vertical grid lines
        const verticalTransformedLinesPointsStart: [2]f32 = transformPoints(originalVerticalGridLinesStart[x], originalVerticalGridLinesStart[y], ax, ay, bx, by);
        verticalGridLinesStart[x] = verticalTransformedLinesPointsStart[0];
        verticalGridLinesStart[y] = verticalTransformedLinesPointsStart[1];
        const verticalTransformedLinesPointsEnd: [2]f32 = transformPoints(originalVerticalGridLinesEnd[x], originalVerticalGridLinesEnd[y], ax, ay, bx, by);
        verticalGridLinesEnd[x] = verticalTransformedLinesPointsEnd[0];
        verticalGridLinesEnd[y] = verticalTransformedLinesPointsEnd[1];

        // horizontal grid lines
        const horizontalTransformedLinesPointsStart: [2]f32 = transformPoints(originalHorizontalGridLinesStart[x], originalHorizontalGridLinesStart[y], ax, ay, bx, by);
        horizontalGridLinesStart[x] = horizontalTransformedLinesPointsStart[0];
        horizontalGridLinesStart[y] = horizontalTransformedLinesPointsStart[1];
        const horizontalTransformedLinesPointsEnd: [2]f32 = transformPoints(originalHorizontalGridLinesEnd[x], originalHorizontalGridLinesEnd[y], ax, ay, bx, by);
        horizontalGridLinesEnd[x] = horizontalTransformedLinesPointsEnd[0];
        horizontalGridLinesEnd[y] = horizontalTransformedLinesPointsEnd[1];
    }
}

fn tiltBoard(by: f32) void {
    if (tilt + by > 1 or tilt + by < 0) return;
    tilt += by;
    transformGrid(1, tilt, -1, tilt);
}
