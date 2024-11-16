const std = @import("std");
const rl = @cImport({
    @cInclude("raylib.h");
});

const screenHeight = 720;
const screenWidth = 1080;

const rows = 10;
const columns = 10;
const tileSize = 40;

pub fn main() !void {
    rl.SetConfigFlags(rl.FLAG_VSYNC_HINT);
    rl.SetTargetFPS(60);
    rl.InitWindow(screenWidth, screenHeight, "isometric grid");
    defer rl.CloseWindow();

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

    const halfTile = tileSize / 2;

    for (0..rows) |row| {
        const gridCenterY: f32 = @floatFromInt(row * tileSize);
        for (0..columns) |column| {
            const gridCenterX: f32 = @floatFromInt(column * tileSize);
            // rl.DrawPixel(@intFromFloat(gridCenterX), @intFromFloat(gridCenterY), rl.WHITE);

            const transformedGridCenterX: f32 = gridCenterX - gridCenterY;
            const transformedGridCenterY: f32 = gridCenterX * 0.4 + gridCenterY * 0.4;
            rl.DrawPixel(@intFromFloat(transformedGridCenterX), @intFromFloat(transformedGridCenterY), rl.YELLOW);

            // draw grid vertical lines
            const gridLineStartX: f32 = @floatFromInt(column * tileSize + (tileSize / 2));
            const gridLineStartY: f32 = -halfTile;
            const gridLineEndX: f32 = gridCenterX + (tileSize / 2);
            const gridLineEndY: f32 = tileSize * rows - halfTile;
            // rl.DrawLine(@intFromFloat(gridLineStartX), @intFromFloat(gridLineStartY), @intFromFloat(gridLineEndX), @intFromFloat(gridLineEndY), rl.RED);
            const transformedGridLineStartX: f32 = gridLineStartX - gridLineStartY;
            const transformedGridLineStartY: f32 = gridLineStartX * 0.4 + gridLineStartY * 0.4;
            const transformedGridLineEndX: f32 = gridLineEndX - gridLineEndY;
            const transformedGridLineEndY: f32 = gridLineEndX * 0.4 + gridLineEndY * 0.4;
            rl.DrawLine(
                @intFromFloat(transformedGridLineStartX),
                @intFromFloat(transformedGridLineStartY),
                @intFromFloat(transformedGridLineEndX),
                @intFromFloat(transformedGridLineEndY),
                rl.BLUE,
            );
        }

        // draw grid horizontal lines
        const gridLineStartX: f32 = -halfTile;
        const gridLineStartY: f32 = @floatFromInt(row * tileSize + (tileSize / 2));
        const gridLineEndX: f32 = tileSize * columns - halfTile;
        const gridLineEndY: f32 = gridCenterY + (tileSize / 2);
        // rl.DrawLine(@intFromFloat(gridLineStartX), @intFromFloat(gridLineStartY), @intFromFloat(gridLineEndX), @intFromFloat(gridLineEndY), rl.RED);
        const transformedGridLineStartX: f32 = gridLineStartX - gridLineStartY;
        const transformedGridLineStartY: f32 = gridLineStartX * 0.4 + gridLineStartY * 0.4;
        const transformedGridLineEndX: f32 = gridLineEndX - gridLineEndY;
        const transformedGridLineEndY: f32 = gridLineEndX * 0.4 + gridLineEndY * 0.4;
        rl.DrawLine(
            @intFromFloat(transformedGridLineStartX),
            @intFromFloat(transformedGridLineStartY),
            @intFromFloat(transformedGridLineEndX),
            @intFromFloat(transformedGridLineEndY),
            rl.BLUE,
        );
    }

    rl.DrawFPS(rl.GetScreenWidth() - 95, 10);
}

fn matrixMultiplication() void {}
