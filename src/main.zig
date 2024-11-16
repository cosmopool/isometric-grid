const std = @import("std");
const rl = @cImport({
    @cInclude("raylib.h");
});

pub fn main() !void {
    rl.SetConfigFlags(rl.FLAG_VSYNC_HINT);
    rl.SetTargetFPS(60);
    rl.InitWindow(1080, 720, "isometric grid");
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

    rl.DrawFPS(rl.GetScreenWidth() - 95, 10);
}
