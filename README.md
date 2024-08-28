![CI](https://github.com/kiffpuppygames/kiff-math/actions/workflows/build.yml/badge.svg)

# kiff-math

NOTE: 64bit is not yet implemented! I will be making the 64bit branch available soon.

64 bit Linear Algebra Library based on zmath (https://github.com/zig-gamedev/zig-gamedev/tree/main/libs/kmath). I did this as zmath is embeded in zig-gamedev and us such creates a lot bloat in your repos when all you want to use is the math lib and extra friction by having to copy and paste folders which can make keeping up with new versions a pain. In addition zmath does not support 64bit, which is the ultimate goal of this repo.

# Goals
- 64bit
- Keep up with zig master
- Stand alone and able to be used in any project without additional dependancies or bloated repos.

# Based on zmath v0.10.0 - SIMD math library for game developers

Tested on x86_64 and AArch64.

Provides ~140 optimized routines and ~70 extensive tests.

Can be used with any graphics API.

Documentation can be found [here](https://github.com/kiffpuppygames/kiff-math/blob/main/src/kmath.zig).

Benchamrks can be found [here](https://github.com/kiffpuppygames/kiff-math/blob/main/src/benchmark.zig).

An intro article can be found [here](https://zig.news/michalz/fast-multi-platform-simd-math-library-in-zig-2adn).

## Getting started

Add the following to your `build.zig.zon` .dependencies:
```
    // https://github.com/kiffpuppygames/kiff-math
    .kmath = .{ 
        .url = "https://github.com/kiffpuppygames/kiff-math/archive/d4472648724ec560bb2ff9a882d131a75e5cff2b.tar.gz",
        .hash = "12201293d4d33858f8cc5df3d464e2d694ec2c34e669e38509ef6391dbc164cbc3e2"
    },
```

Then in your `build.zig` add:

```zig
pub fn build(b: *std.Build) void {
    const exe = b.addExecutable(.{ ... });

    const kmath = b.dependency("kmath", .{});
    exe.root_module.addImport("kmath", kmath.module("root"));
}
```

Now in your code you may import and use kmath:

```zig
const km = @import("kmath");

pub fn main() !void {
    //
    // OpenGL/Vulkan example
    //
    const object_to_world = km.rotationY(..);
    const world_to_view = km.lookAtRh(
        km.f32x4(3.0, 3.0, 3.0, 1.0), // eye position
        km.f32x4(0.0, 0.0, 0.0, 1.0), // focus point
        km.f32x4(0.0, 1.0, 0.0, 0.0), // up direction ('w' coord is zero because this is a vector not a point)
    );
    // `perspectiveFovRhGl` produces Z values in [-1.0, 1.0] range (Vulkan app should use `perspectiveFovRh`)
    const view_to_clip = km.perspectiveFovRhGl(0.25 * math.pi, aspect_ratio, 0.1, 20.0);

    const object_to_view = km.mul(object_to_world, world_to_view);
    const object_to_clip = km.mul(object_to_view, view_to_clip);

    // Transposition is needed because GLSL uses column-major matrices by default
    gl.uniformMatrix4fv(0, 1, gl.TRUE, km.arrNPtr(&object_to_clip));
    
    // In GLSL: gl_Position = vec4(in_position, 1.0) * object_to_clip;
    
    //
    // DirectX example
    //
    const object_to_world = km.rotationY(..);
    const world_to_view = km.lookAtLh(
        km.f32x4(3.0, 3.0, -3.0, 1.0), // eye position
        km.f32x4(0.0, 0.0, 0.0, 1.0), // focus point
        km.f32x4(0.0, 1.0, 0.0, 0.0), // up direction ('w' coord is zero because this is a vector not a point)
    );
    const view_to_clip = km.perspectiveFovLh(0.25 * math.pi, aspect_ratio, 0.1, 20.0);

    const object_to_view = km.mul(object_to_world, world_to_view);
    const object_to_clip = km.mul(object_to_view, view_to_clip);
    
    // Transposition is needed because HLSL uses column-major matrices by default
    const mem = allocateUploadMemory(...);
    km.storeMat(mem, km.transpose(object_to_clip));
    
    // In HLSL: out_position_sv = mul(float4(in_position, 1.0), object_to_clip);
    
    //
    // 'WASD' camera movement example
    //
    {
        const speed = km.f32x4s(10.0);
        const delta_time = km.f32x4s(demo.frame_stats.delta_time);
        const transform = km.mul(km.rotationX(demo.camera.pitch), km.rotationY(demo.camera.yaw));
        var forward = km.normalize3(km.mul(km.f32x4(0.0, 0.0, 1.0, 0.0), transform));

        km.storeArr3(&demo.camera.forward, forward);

        const right = speed * delta_time * km.normalize3(km.cross3(km.f32x4(0.0, 1.0, 0.0, 0.0), forward));
        forward = speed * delta_time * forward;

        var cam_pos = km.loadArr3(demo.camera.position);

        if (keyDown('W')) {
            cam_pos += forward;
        } else if (keyDown('S')) {
            cam_pos -= forward;
        }
        if (keyDown('D')) {
            cam_pos += right;
        } else if (keyDown('A')) {
            cam_pos -= right;
        }

        km.storeArr3(&demo.camera.position, cam_pos);
    }
   
    //
    // SIMD wave equation solver example (works with vector width 4, 8 and 16)
    // 'T' can be F32x4, F32x8 or F32x16
    //
    var z_index: i32 = 0;
    while (z_index < grid_size) : (z_index += 1) {
        const z = scale * @intToFloat(f32, z_index - grid_size / 2);
        const vz = km.splat(T, z);

        var x_index: i32 = 0;
        while (x_index < grid_size) : (x_index += km.veclen(T)) {
            const x = scale * @intToFloat(f32, x_index - grid_size / 2);
            const vx = km.splat(T, x) + voffset * km.splat(T, scale);

            const d = km.sqrt(vx * vx + vz * vz);
            const vy = km.sin(d - vtime);

            const index = @intCast(usize, x_index + z_index * grid_size);
            km.store(xslice[index..], vx, 0);
            km.store(yslice[index..], vy, 0);
            km.store(zslice[index..], vz, 0);
        }
    }
}
```
