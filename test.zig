const std = @import("std");

pub fn main() !void { // <-- Добавили !, так как получение рандома может вернуть ошибку
    std.debug.print("Hello, {s}!\n", .{"World"});

    // 1. Инициализируем генератор случайными байтами от операционной системы
    var prng = std.Random.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        try std.posix.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });
    const rand = prng.random();

    // 2. Генерируем случайное число от 1 до 16 (16 не включается)
    const mym = rand.intRangeLessThan(u64, 1, 17);

    // Выводим сгенерированное число (используем пустые скобки {}, Zig сам поймет u64)
    std.debug.print("Hello, {s} {}\n", .{ "твое число is", mym });

    // 3. Проверяем: если число равно 7, выводим фразу
    if (mym == 7) {
        std.debug.print("ты {s}\n", .{"фрик"});
    } else {
        std.debug.print("ты {s}\n", .{"почему не фрик"});
    }
}
