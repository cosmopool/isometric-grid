const std = @import("std");
const rl = @cImport({
    @cInclude("raylib.h");
});

const screenHeight = 720;
const screenWidth = 1080;

const rows = 10;
const columns = 10;
const gridSize = 40;

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

    const halfGrid = gridSize / 2;

    for (0..rows) |row| {
        const gridYCenter: i32 = @intCast(row * gridSize);
        for (0..columns) |column| {
            const gridXCenter: i32 = @intCast(column * gridSize);
            rl.DrawPixel(gridXCenter, gridYCenter, rl.WHITE);

            // draw grid vertical lines
            const gridLineStartX: i32 = @intCast(column * gridSize + (gridSize / 2));
            const gridLineStartY: i32 = -halfGrid;
            const gridLineEndX: i32 = @intCast(gridXCenter + (gridSize / 2));
            const gridLineEndY: i32 = gridSize * rows - halfGrid;
            rl.DrawLine(gridLineStartX, gridLineStartY, gridLineEndX, gridLineEndY, rl.RED);
        }

        // draw grid horizontal lines
        const gridLineStartX: i32 = -halfGrid;
        const gridLineStartY: i32 = @intCast(row * gridSize + (gridSize / 2));
        const gridLineEndX: i32 = gridSize * columns - halfGrid;
        const gridLineEndY: i32 = @intCast(gridYCenter + (gridSize / 2));
        rl.DrawLine(gridLineStartX, gridLineStartY, gridLineEndX, gridLineEndY, rl.RED);
    }

    rl.DrawFPS(rl.GetScreenWidth() - 95, 10);
}
