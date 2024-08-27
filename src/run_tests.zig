// const std = @import("std");

// const testing = std.testing;
// pub const kmath_tests = @import("tests.zig");

// pub fn main() void 
// {    
//     // Run the tests
//     testing.runAllTests();
// }

comptime {
    _ = @import("tests.zig");
    // And all other files
}