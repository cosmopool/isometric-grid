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
var symmetricalGrid: [numberOfTiles * 2]f32 = undefined;
var grid: [numberOfTiles * 2]f32 = undefined;

var symmetricalVerticalLinesStart: [numberOfTiles * 2]f32 = undefined;
var symmetricalVerticalLinesEnd: [numberOfTiles * 2]f32 = undefined;
var verticalLinesStart: [numberOfTiles * 2]f32 = undefined;
var verticalLinesEnd: [numberOfTiles * 2]f32 = undefined;

var symmetricalHorizontalLinesStart: [numberOfTiles * 2]f32 = undefined;
var symmetricalHorizontalLinesEnd: [numberOfTiles * 2]f32 = undefined;
var horizontalLinesStart: [numberOfTiles * 2]f32 = undefined;
var horizontalLinesEnd: [numberOfTiles * 2]f32 = undefined;

// grid visualization properties
var offsetX: f32 = 0;
var offsetY: f32 = 0;
var tilt: f32 = 0.4;

pub fn main() !void {
    rl.SetConfigFlags(rl.FLAG_VSYNC_HINT);
    rl.SetTargetFPS(60);
    rl.InitWindow(screenWidth, screenHeight, "isometric grid");
    defer rl.CloseWindow();

    // setup initial grid
    generateSymmetricalGrid();
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
            @intFromFloat(verticalLinesStart[x] + offsetX),
            @intFromFloat(verticalLinesStart[y] + offsetY),
            @intFromFloat(verticalLinesEnd[x] + offsetX),
            @intFromFloat(verticalLinesEnd[y] + offsetY),
            rl.BLUE,
        );
        rl.DrawLine(
            @intFromFloat(horizontalLinesStart[x] + offsetX),
            @intFromFloat(horizontalLinesStart[y] + offsetY),
            @intFromFloat(horizontalLinesEnd[x] + offsetX),
            @intFromFloat(horizontalLinesEnd[y] + offsetY),
            rl.BLUE,
        );
    }

    rl.DrawFPS(rl.GetScreenWidth() - 95, 10);
}

/// The grid lines is separated in 4 arrays that store two-dimensional vector points
/// - vertical lines start
/// - vertical lines end
/// - horizontal lines start
/// - horizontal lines end
/// This is because we can use just one loop of vector size 2
/// to operate in grid tiles and grid lines at the same time.
/// The alternative is one for-loop to iterate over the tiles
/// and other to go over lines (maybe this is better/cleaner?).
inline fn generateSymmetricalGrid() void {
    const halfTile = tileSize / 2;
    comptime var index: usize = 0;
    inline for (0..rows) |row| {
        inline for (0..columns) |column| {
            if (index >= symmetricalGrid.len) break;

            const x = index + 0;
            const y = index + 1;
            assert(x < grid.len);
            assert(y <= grid.len);
            index += 2;

            // grid tiles coordinates
            symmetricalGrid[x] = @floatFromInt(column * tileSize);
            symmetricalGrid[y] = @floatFromInt(row * tileSize);

            // vertical grid lines coordinates
            symmetricalVerticalLinesStart[x] = @floatFromInt(column * tileSize + halfTile);
            symmetricalVerticalLinesStart[y] = -halfTile;
            symmetricalVerticalLinesEnd[x] = symmetricalGrid[x] + halfTile;
            symmetricalVerticalLinesEnd[y] = tileSize * rows - halfTile;

            if (column > 0) continue;
            // vertical grid lines coordinates
            symmetricalHorizontalLinesStart[x] = -halfTile;
            symmetricalHorizontalLinesStart[y] = @floatFromInt(row * tileSize + halfTile);
            symmetricalHorizontalLinesEnd[x] = tileSize * columns - halfTile;
            symmetricalHorizontalLinesEnd[y] = symmetricalGrid[y] + halfTile;
        }
    }
}

/// will multiply the vector [[pointX, pointY]] by the matrix [[[ax, bx]], [[ay, by]]]
/// --      --   --    --
/// | pointX |   |ax, bx|
/// | pointX | x |ay, by|
/// --      --   --    --
/// https://en.wikipedia.org/wiki/Matrix_multiplication
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

        const transformedPoints: [2]f32 = transformPoints(symmetricalGrid[x], symmetricalGrid[y], ax, ay, bx, by);
        grid[x] = transformedPoints[0];
        grid[y] = transformedPoints[1];

        // vertical grid lines
        const verticalTransformedLinesPointsStart: [2]f32 = transformPoints(symmetricalVerticalLinesStart[x], symmetricalVerticalLinesStart[y], ax, ay, bx, by);
        verticalLinesStart[x] = verticalTransformedLinesPointsStart[0];
        verticalLinesStart[y] = verticalTransformedLinesPointsStart[1];
        const verticalTransformedLinesPointsEnd: [2]f32 = transformPoints(symmetricalVerticalLinesEnd[x], symmetricalVerticalLinesEnd[y], ax, ay, bx, by);
        verticalLinesEnd[x] = verticalTransformedLinesPointsEnd[0];
        verticalLinesEnd[y] = verticalTransformedLinesPointsEnd[1];

        // horizontal grid lines
        const horizontalTransformedLinesPointsStart: [2]f32 = transformPoints(symmetricalHorizontalLinesStart[x], symmetricalHorizontalLinesStart[y], ax, ay, bx, by);
        horizontalLinesStart[x] = horizontalTransformedLinesPointsStart[0];
        horizontalLinesStart[y] = horizontalTransformedLinesPointsStart[1];
        const horizontalTransformedLinesPointsEnd: [2]f32 = transformPoints(symmetricalHorizontalLinesEnd[x], symmetricalHorizontalLinesEnd[y], ax, ay, bx, by);
        horizontalLinesEnd[x] = horizontalTransformedLinesPointsEnd[0];
        horizontalLinesEnd[y] = horizontalTransformedLinesPointsEnd[1];
    }
}

fn tiltBoard(amountToTilt: f32) void {
    if (tilt + amountToTilt > 1 or tilt + amountToTilt < 0) return;
    tilt += amountToTilt;
    transformGrid(1, tilt, -1, tilt);
}
