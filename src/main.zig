const std = @import("std");
const rl = @import("raylib");
const p = @import("player.zig");
const b = @import("ball.zig");

const SCREEN_WIDTH = 800;
const SCREEN_HEIGHT = 400;
const FONT_SIZE = 40;
const SCORE_OFFSET = 50;

pub fn main() !void {
    rl.initWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Pong");
    defer rl.closeWindow();

    rl.setWindowState(rl.ConfigFlags{ .window_resizable = true });

    var player_1 = p.Player.init(p.Side.player_1);
    var player_2 = p.Player.init(p.Side.player_2);
    var ball = b.Ball.init();

    rl.setTargetFPS(60);
    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        // CLEAR
        rl.clearBackground(rl.Color.black);

        // UPDATE
        const width = rl.getScreenWidth();
        const height = rl.getScreenHeight();
        const top_middle: rl.Vector2 = rl.Vector2.init(@floatFromInt(@divExact(width, 2)), 0);
        const bottom_middle: rl.Vector2 = rl.Vector2.init(@floatFromInt(@divExact(width, 2)), @floatFromInt(height));
        const score = rl.textFormat("%i     %i", .{ player_1.score, player_2.score });
        const text_width = @divExact(rl.measureText(score, FONT_SIZE), 2);

        player_1.move(&ball, p.Control.person);
        player_2.move(&ball, p.Control.computer);
        ball.move(&player_1, &player_2);

        // DRAW
        rl.drawLineEx(top_middle, bottom_middle, 10, rl.Color.white);
        rl.drawText(score, @divExact(width, 2) - text_width, SCORE_OFFSET, FONT_SIZE, rl.Color.white);
        player_1.draw();
        player_2.draw();
        ball.draw();
    }
}
