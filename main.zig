const std = @import("std");

// разобьем задачу на несколько шагов
// 1.Получить имя ОС и версию ядра — через uname.

// 2.Получить число ядер CPU — прочитать /proc/cpuinfo и посчитать процессоры, либо использовать std.Thread.getCpuCount().

// 3.Получить память — прочитать /proc/meminfo.

// 4.Получить uptime — прочитать /proc/uptime.

// 5.Получить hostname — через uname или файл /proc/sys/kernel/hostname.

// 6.Напечатать всё в нужном формате.


// 1. получаем ОС и версию, все в один блок
pub fn getNameVers(get: std.mem.Allocator) ![]u8 
{
   
   const cwd = std.fs.cwd();
   const max_size = 1024;
   
   const file_contents = try cwd.readFileAlloc(get, "/proc/version", max_size);

   return file_contents;
}

// 2. читаем ядра процессора 
pub fn readCpuCores() !u8
{

const cwd = std.fs.cwd();
var buf: [16384]u8 = undefined;


const readbuf = try cwd.readFile("/proc/cpuinfo", &buf);


const cect = std.mem.count(u8, readbuf, "processor");

return @intCast(cect);
}


// 6. в мейн выводим найденные значения
pub fn main() !void 
{
 
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    
    const system_info = try getNameVers(allocator);
    const cores_info = try readCpuCores();
    
    
    defer allocator.free(system_info);

   
    std.debug.print("System info:\t{s}\n", .{system_info});
    std.debug.print("Cores quantum:\t{}\n", .{cores_info});
}
