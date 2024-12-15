const std = @import("std");
const rl = @import("raylib.zig");
const ent = @import("entities.zig");
const spawn = @import("spawner.zig");
const dbg = std.debug.print;
const win_width = rl.GetScreenWidth;
const win_height = rl.GetScreenHeight;
pub const WIDTH = 1280.0;
pub const HEIGHT = 720.0;
pub const MobList = std.ArrayList(ent.Entity);

pub const SCALE = struct {
    xscale: f64,
    yscale: f64,
    scale: f64,
    const Self = @This();

    pub fn calc_scale() Self {
        const xscale =  @as(f64,@floatFromInt(win_width())) / WIDTH;
        const yscale =  @as(f64,@floatFromInt(win_width())) / HEIGHT;
        return Self{
            .xscale = xscale,
            .yscale = yscale,
            .scale = std.math.sqrt(@as(f64, (xscale * xscale) + (yscale * yscale))),
        };
    }
};

pub fn main() !void {
    dbg("Are we running?\n", .{});
    rl.InitWindow(WIDTH, HEIGHT, "SHOOTY TOWER");
    rl.SetTargetFPS(60);
    dbg("After init window \n", .{});
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    var mobs: MobList = MobList.init(alloc);
    defer mobs.deinit();
    const pos = rl.Vector2{
        .x = 50.0,
        .y = 50.0,
    };
    var mob = ent.Entity.spawn_mob(pos);
    try mobs.append(mob);
    const tower: ent.Entity = try ent.Entity.default_tower();
    while (!rl.WindowShouldClose()) {
        rl.BeginDrawing();
        for (tower.weaponry.multi.items) |weapon| {
            weapon.draw_attack(tower.pos,mob.pos);
        }
        mob.pos = mob.move(rl.Vector2{.x = 0.0, .y = 1.0});
        defer rl.EndDrawing();
        tower.draw_entity();
        mob.draw_entity();


        // rl.DrawText(rl.TextFormat("Health %i/%i", tower.health, tower.full_health), 0, 0, 32, rl.BLACK);
        rl.ClearBackground(rl.WHITE);
    }
}
