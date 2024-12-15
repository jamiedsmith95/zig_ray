const std = @import("std");
const ent = @import("entities.zig");
const rl = @import("raylib.zig");
const main = @import("main.zig");
const win_width = rl.GetScreenWidth;
const win_height = rl.GetScreenHeight;

pub fn mob_handler(points: *i32, mobs: *std.ArrayList(ent.Entity)) !void {
    while (points.* > 200) {
        points.* -= 200;
        const where: f32 = @floatFromInt(rl.GetRandomValue(0, main.WIDTH + main.HEIGHT));
        const which = rl.GetRandomValue(0, 1);
        if (which == 0 and where < main.WIDTH) {
            const new_mob = ent.Mob.spawn_mob(where, 0, 5, rl.RED, 2, 50,5.0);
            try mobs.*.append(new_mob);
        } else if (which == 0) {
            const new_mob = ent.Mob.spawn_mob(0, where - main.WIDTH, 5, rl.RED, 2, 50,5.0);
            try mobs.*.append(new_mob);
        } else if (where == 1 and where < main.WIDTH) {
            const new_mob = ent.Mob.spawn_mob(where, main.HEIGHT, 5, rl.RED, 2, 50,5.0);
            try mobs.*.append(new_mob);
        } else {
            const new_mob = ent.Mob.spawn_mob(main.WIDTH, where - main.WIDTH, 5, rl.RED, 2, 50,5.0);
            try mobs.*.append(new_mob);
        }
    }
    for (mobs.items, 0..mobs.items.len) |mob, i| {
        if (mob.health == 0) {
            _ = mobs.swapRemove(i);
        }
    }
}
