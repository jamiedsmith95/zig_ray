const std = @import("std");
const rl = @import("raylib.zig");
const main = @import("main.zig");

pub const WeaponType = enum { LASER, PROJECTILE, CONTACT };

fn Unwrapped(comptime Union: type, comptime field: []const u8) type {
    return inline for (std.meta.fields(Union)) |variant| {
        const Struct = variant.type;
        const s: Struct = undefined;
        if (@hasField(Struct, field)) break @TypeOf(@field(s, field));
    } else @compileError("No such field in any of the variants");
}

fn unwrap(u: anytype, comptime field: []const u8) ?Unwrapped(@TypeOf(u), field) {
    return switch (u) {
        inline else => |v| if (@hasField(@TypeOf(v), field)) @field(v, field) else null,
    };
}

pub fn get_scaled(vec: rl.Vector2) rl.Vector2 {
    const scale = main.SCALE.calc_scale();
    const x: f32 = @floatCast(vec.x * scale.xscale);
    const y: f32 = @floatCast(vec.y * scale.yscale);
    return rl.Vector2{
        .x = x,
        .y = y,
    };
}

pub const Tower = struct { tower: bool };
pub const Mob = struct {
    mobility: Mobility,
};
pub const EntityType = union(enum) {
    mob: Mob,
    tower: Tower,
};

const Weapon = struct {
    dmg: f32,
    range: f32,
    cooldown: f32,
    colour: rl.Color,
    weapon_type: WeaponType,
    pub const Self = @This();

    pub fn draw_attack(self: Self, wielder: rl.Vector2, target: rl.Vector2) void {
        const wield_pos = get_scaled(wielder);
        const target_pos = get_scaled(target);
        switch (self.weapon_type) {
            WeaponType.CONTACT => {},
            WeaponType.LASER => {
                rl.DrawLineV(wield_pos,target_pos, self.colour);
            },
            WeaponType.PROJECTILE => {},
        }
    }
};

const Mobility = struct {
    speed: f32,
};

const Weaponry = union(enum) {
    contact: f32,
    single: Weapon,
    multi: std.ArrayList(Weapon),
};

pub const Entity = struct {
    pos: rl.Vector2,
    type: EntityType,
    size: rl.Vector2,
    health: f32,
    full_health: f32,
    colour: rl.Color,
    weaponry: Weaponry,

    pub const Self = @This();
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    pub fn move(self: Self, direction: rl.Vector2) rl.Vector2 {
        return rl.Vector2Add(self.pos, direction);
    }

    pub fn draw_entity(self: Self) void {
        const pos = get_scaled(self.pos);
        const size = get_scaled(self.size);
        switch (self.type) {
            EntityType.mob => rl.DrawCircleV(pos, size.x, self.colour),
            EntityType.tower => rl.DrawRectangleV(pos, size, self.colour),
        }
    }

    pub fn default_tower() !Self {
        const pos = rl.Vector2{
            .x = main.WIDTH / 2,
            .y = main.HEIGHT / 2,
        };
        const entity_type = EntityType{
            .tower = Tower{ .tower = true },
        };
        const size = rl.Vector2{
            .x = 25,
            .y = 25,
        };
        const health = 100.0;
        const colour = rl.BLUE;
        var weapons = std.ArrayList(Weapon).init(allocator);
        const laser = Weapon{
            .colour = rl.ORANGE,
            .cooldown = 1,
            .dmg = 5.0,
            .range = 100.0,
            .weapon_type = WeaponType.LASER,
        };
        try weapons.append(laser);
        const tower = Self{
            .pos = pos,
            .type = entity_type,
            .size = size,
            .health = health,
            .full_health = health,
            .colour = colour,
            .weaponry = Weaponry{
                .multi = weapons,
            },
        };
        return tower;
    }

    pub fn spawn_mob(pos: rl.Vector2) Self {
        const size = rl.Vector2{
            .x = 10,
            .y = 10,
        };
        const health = 24.0;
        const colour = rl.RED;

        const mobility = Mobility{ .speed = 1.0 };
        const mob = Self{
            .size = size,
            .type = EntityType{
                .mob = Mob{
                    .mobility = mobility,
                },
            },
            .pos = pos,
            .health = health,
            .full_health = health,
            .colour = colour,
            .weaponry = Weaponry{ .contact = 5.0 },
        };
        return mob;
    }
};
