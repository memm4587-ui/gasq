const std = @import("std");

// разобьем задачу на несколько шагов
// 1.Получить имя ОС и версию ядра — через uname.

// 2.Получить число ядер CPU — прочитать /proc/cpuinfo и посчитать процессоры, либо использовать std.Thread.getCpuCount().

// 3.Получить память — прочитать /proc/meminfo.

// 4.Получить hostname — через uname или файл /proc/sys/kernel/hostname.

// 5.Напечатать всё в нужном формате.

// 1. получаем ОС и версию, все в один блок
pub fn getNameVers(get: std.mem.Allocator) ![]u8 {
    const cwd = std.fs.cwd();
    const max_size = 1024;

    const file_contents = try cwd.readFileAlloc(get, "/proc/version", max_size);

    return file_contents;
}

// 2. читаем ядра процессора
pub fn readCpuCores() !u8 {
    const cwd = std.fs.cwd();
    var buf: [16384]u8 = undefined;

    const readbuf = try cwd.readFile("/proc/cpuinfo", &buf);

    const cect = std.mem.count(u8, readbuf, "processor");

    return @intCast(cect);
}

// 3. получаем опру. сколько всего, использовано, сколько доступно в гб

const mem = struct {
    total: u64,
    avail: u64,
    used: u64,
};
pub fn getMem() !mem {
    const cwd = std.fs.cwd();
    var buf: [2048]u8 = undefined;

    const readbuf = try cwd.readFile("/proc/meminfo", &buf);

    _ = readbuf;

    return mem{ .total = 0, .free = 0, .used = 0 };
}

// 4. получаем имя хоста

pub fn getHost(get: std.mem.Allocator) ![]u8
{
const file = try std.fs.cwd().openFile("/proc/sys/kernel/hostname", .{ .mode = .read_only });
    defer file.close();

    const hostname_raw = try file.reader().readAllAlloc(get, 256);
    errdefer get.free(hostname_raw);

    const hostname = std.mem.trim(u8, hostname_raw, " \n\r\t");

    if (hostname.len == hostname_raw.len) {
        return hostname_raw;
    }

    const hostname_cleaned = try get.alloc(u8, hostname.len);
    @memcpy(hostname_cleaned, hostname);
    get.free(hostname_raw);

    return hostname_cleaned;
}

// 5. в мейн выводим найденные значения
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const system_info = try getNameVers(allocator);
    const cores_info = try readCpuCores();

    defer allocator.free(system_info);

    const host_info = try getHost(allocator);
    defer allocator.free(host_info);

    std.debug.print("System info:\t{s}\n", .{system_info});
    std.debug.print("Cores quantum:\t{}\n", .{cores_info});
    std.debug.print("Hostname:\t{s}\n", .{host_info});
}
