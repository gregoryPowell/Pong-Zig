const std = @import("std");
const rl = @import("raylib");
const b = @import("ball.zig");

const PADDLE_WIDTH = 20;
const PADDLE_HEIGHT = 100;
const PLAYER_VELOCITY = 5;
const COMPUTER_VELOCITY = 3;
const PADDLE_COLOR = rl.Color.white;
const PADDLE_GAP = 20;

pub const Side = enum { player_1, player_2 };
pub const Control = enum { person, computer };

pub const Player = struct {
    paddle: rl.Rectangle = undefined,
    score: i32,
    velocity: f32,
    side: Side,

    pub fn init(side: Side) Player {
        var player: Player = undefined;
        player.side = side;
        player.score = 0;
        var x: f32 = undefined;
        switch (player.side) {
            Side.player_1 => {
                x = PADDLE_GAP;
            },
            Side.player_2 => {
                x = @floatFromInt(rl.getScreenWidth() - PADDLE_WIDTH - PADDLE_GAP);
            },
        }
        const y: f32 = @floatFromInt(@divExact(rl.getScreenHeight(), 2) - PADDLE_HEIGHT);
        player.paddle = rl.Rectangle.init(x, y, PADDLE_WIDTH, PADDLE_HEIGHT);
        return player;
    }

    pub fn draw(self: *Player) void {
        rl.drawRectangleRec(self.paddle, PADDLE_COLOR);
    }

    pub fn move(
        self: *Player,
        ball: *b.Ball,
        control: Control,
    ) void {
        switch (control) {
            Control.computer => {
                self.moveTowardBall(ball);
            },
            Control.person => {
                if (rl.isKeyDown(.up)) {
                    self.velocity = PLAYER_VELOCITY * -1;
                } else if (rl.isKeyDown(.down)) {
                    self.velocity = PLAYER_VELOCITY;
                } else {
                    self.velocity = 0;
                }

                self.valid_move();
                self.paddle.y += self.velocity;
            },
        }

        self.check_colision(ball);
    }

    fn moveTowardBall(self: *Player, ball: *b.Ball) void {
        const player_y = self.paddle.y + (self.paddle.height / 2);
        const ball_y = ball.ball.y + (ball.ball.height / 2);
        const ball_x = ball.ball.x + (ball.ball.width / 2);

        if (player_y > ball_y) {
            self.velocity = COMPUTER_VELOCITY * -1;
        } else if (player_y < ball_y) {
            self.velocity = COMPUTER_VELOCITY;
        } else {
            self.velocity = 0;
        }

        switch (self.side) {
            Side.player_1 => {
                if (ball_x < @as(f32, @floatFromInt(@divExact(rl.getScreenWidth(), 2)))) {
                    self.valid_move();
                    self.paddle.y += self.velocity;
                }
            },
            Side.player_2 => {
                if (ball_x > @as(f32, @floatFromInt(@divExact(rl.getScreenWidth(), 2)))) {
                    self.valid_move();
                    self.paddle.y += self.velocity;
                }
            },
        }
    }

    fn check_colision(self: *Player, ball: *b.Ball) void {
        if (rl.checkCollisionRecs(self.paddle, ball.ball)) {
            const intersection = rl.getCollisionRec(self.paddle, ball.ball);
            switch (self.side) {
                Side.player_1 => {
                    if (intersection.x < self.paddle.x + self.paddle.width + ball.velocity.x) return;
                },
                Side.player_2 => {
                    if (intersection.x + intersection.width > self.paddle.x + ball.velocity.x) return;
                },
            }
            ball.velocity.x *= -1;
        }
    }

    fn valid_move(self: *Player) void {
        const y = self.paddle.y + self.velocity;
        if (y < 0 or y + self.paddle.height > @as(f32, @floatFromInt(rl.getScreenHeight()))) {
            self.velocity = 0;
        }
    }
};
