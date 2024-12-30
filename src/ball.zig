const std = @import("std");
const rl = @import("raylib");
const p = @import("player.zig");

const BALL_SIZE = 25;
const BALL_COLOR = rl.Color.red;
const BALL_VELOCITY: f32 = 5;

pub const Ball = struct {
    ball: rl.Rectangle = undefined,
    velocity: rl.Vector2 = undefined,

    pub fn init() Ball {
        var ball: Ball = undefined;
        ball.centerBall();
        return ball;
    }

    pub fn draw(self: *Ball) void {
        rl.drawRectangleRec(self.ball, BALL_COLOR);
    }

    pub fn move(self: *Ball, player_1: *p.Player, player_2: *p.Player) void {
        self.ball.x += self.velocity.x;
        self.ball.y += self.velocity.y;

        if (self.ball.y <= 0 or self.ball.y + BALL_SIZE >= @as(f32, @floatFromInt(rl.getScreenHeight()))) {
            self.velocity.y *= -1;
        }

        if (self.ball.x < 0) {
            player_1.score += 1;
            self.centerBall();
        } else if (self.ball.x > @as(f32, @floatFromInt(rl.getScreenWidth() - BALL_SIZE))) {
            player_2.score += 1;
            self.centerBall();
        }
    }

    fn centerBall(self: *Ball) void {
        const x: f32 = @floatFromInt(@divExact(rl.getScreenWidth(), 2) - BALL_SIZE);
        const y: f32 = @floatFromInt(@divExact(rl.getScreenHeight(), 2) - BALL_SIZE);
        self.ball = rl.Rectangle.init(x, y, BALL_SIZE, BALL_SIZE);
        const direction = rl.getRandomValue(0, 1);
        self.velocity.x = if (direction > 0) BALL_VELOCITY else BALL_VELOCITY * -1;

        var y_vel = rl.getRandomValue(-5, 5);
        while (y_vel == 0) : (y_vel = rl.getRandomValue(-5, 5)) {
            continue;
        }

        self.velocity.y = @floatFromInt(y_vel);
    }
};
