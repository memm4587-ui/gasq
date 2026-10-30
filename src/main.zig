const std = @import("std");

pub fn getNameVers(get: std.mem.Allocator) ![]u8 {
    const cwd = std.fs.cwd();
    const max_size = 1024;

    const file_contents = try cwd.readFileAlloc(get, "/proc/version", max_size);

    return file_contents;
}

pub fn readCpuCores() !u8 {
    const cwd = std.fs.cwd();
    var buf: [16384]u8 = undefined;

    const readbuf = try cwd.readFile("/proc/cpuinfo", &buf);

    const cect = std.mem.count(u8, readbuf, "processor");

    return @intCast(cect);
}

const mem = struct {
    total: u64,
    avail: u64,
    used: u64,
};

pub fn getMem() !mem {
    const cwd = std.fs.cwd();
    var buf: [2048]u8 = undefined;

    const readbuf = try cwd.readFile("/proc/meminfo", &buf);

    var total_kb: u64 = 0;
    var avail_kb: u64 = 0;

    var lines = std.mem.tokenizeSequence(u8, readbuf, "\n");
    while (lines.next()) |line| {
        if (std.mem.startsWith(u8, line, "MemTotal:")) {
            total_kb = try parseMemValue(line);
        } else if (std.mem.startsWith(u8, line, "MemAvailable:")) {
            avail_kb = try parseMemValue(line);
        }
    }

    const total_gb = total_kb / 1024 / 1024;
    const avail_gb = avail_kb / 1024 / 1024;
    const used_gb = total_gb - avail_gb;

    return mem{
        .total = total_gb,
        .avail = avail_gb,
        .used = used_gb,
    };
}

fn parseMemValue(line: []const u8) !u64 {
    var parts = std.mem.tokenizeAny(u8, line, " \t:");
    _ = parts.next(); 
    const val_str = parts.next() orelse return error.InvalidFormat;
    return try std.fmt.parseInt(u64, val_str, 10);
}

pub fn getHost(get: std.mem.Allocator) ![]u8 {
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

// gasqu 0.2.0, create a output with CPU
pub fn utgc(gut: std.mem.Allocator) ![]u8
{
var buffer: [16384]u8 = undefined;

const readbuf = try std.fs.cwd().readFile("/proc/cpuinfo", &buffer);

const realin = std.mem.IndexOf(readbuf, "model name");

const saved_name = try gut.dupe(u8, realin);
return saved_name;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    const gut = gpa.allocator();

    const system_info = try getNameVers(allocator);
    defer allocator.free(system_info);

    const highway_cores = try readCpuCores();
    const ram = try getMem();
    
    const host_info = try getHost(allocator);
    defer allocator.free(host_info);

    const namecpu_info = try utgc(gut);
    defer gut.free(namecpu_info);

    std.debug.print("Hostname:\t{s}\n", .{host_info});
    std.debug.print("System info:\t{s}\n", .{system_info});
    std.debug.print("CPU: {s}\n", .{namecpu_info});
    std.debug.print("Cores quantum:\t{}\n", .{highway_cores});
    std.debug.print("RAM Total:\t{} GB\n", .{ram.total});
    std.debug.print("RAM Available:\t{} GB\n", .{ram.avail});
    std.debug.print("RAM Used:\t{} GB\n", .{ram.used});
}
