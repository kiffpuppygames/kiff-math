pub const ColorComponent = enum(u8) { R = 0, G = 1, B = 2, A = 3 };

pub const Color64A = @import("Color64A.zig");

/// Creates a new vector of any suported type from a slice of values. If the length of the slice is 1, the vector will be initialized with the same value for all components. Otherwise, the vector will be initialized with
/// the values in the slice.
/// 
/// @param T The type of the vector to create.
/// @param E The element type of the vector.
/// @param size The number of elements in the vector.
/// @param e_count The number of elements in the values array.
/// @param values The array of values to initialize the vector with.
pub fn new(comptime T: type, comptime E: type, comptime size: usize, comptime e_count: usize, values: [e_count]E) T {
    if (T != Color64A ) { // *and T != Vec3 and T != Vec4 and T != IVec2 and T != IVec3 and T != IVec4 and T != F32Vec2 and T != F32Vec3 and T != F32Vec4 and T != I32Vec2 and T != I32Vec3 and T != I32Vec4)
        @compileError("new_color: T must be of type color");
    }

    if (values.len != e_count) {
        @compileError("new_color: the number of elements must be equal to the length of values");
    }

    if (size != values.len and values.len != 1) {
        @compileError("new_vec: size must be equal to the length of values if values has more than one element");
    }

    if (values.len == 1) {
        const slice: [size]E = .{values[0]} ** size;
        const vals: @Vector(size, E) = slice;
        return T{ .values = vals };
    }

    const slice: [size]E = values;
    const vals: @Vector(size, E) = slice;

    return T{ .values = vals };
}

pub fn adjustSaturation(color: vectors.F32x4, saturation: f32) vectors.F32x4 {
    const luminance = dot3(vectors.f32x4(0.2125, 0.7154, 0.0721, 0.0), color);
    var result = mulAdd(color - luminance, vectors.f32x4s(saturation), luminance);
    result[3] = color[3];
    return result;
}

pub fn adjustContrast(color: vectors.F32x4, contrast: f32) vectors.F32x4 {
    var result = mulAdd(color - vectors.f32x4s(0.5), vectors.f32x4s(contrast), vectors.f32x4s(0.5));
    result[3] = color[3];
    return result;
}

pub fn rgbToHsl(rgb: vectors.F32x4) vectors.F32x4 {
    const r = swizzle(rgb, .x, .x, .x, .x);
    const g = swizzle(rgb, .y, .y, .y, .y);
    const b = swizzle(rgb, .z, .z, .z, .z);

    const minv = min(r, min(g, b));
    const maxv = max(r, max(g, b));

    const l = (minv + maxv) * vectors.f32x4s(0.5);
    const d = maxv - minv;
    const la = select(vectors.boolx4(true, true, true, false), l, rgb);

    if (all(d < vectors.f32x4s(std.math.floatEps(f32)), 3)) {
        return select(vectors.boolx4(true, true, false, false), vectors.f32x4s(0.0), la);
    } else {
        var s: vectors.F32x4 = undefined;
        var h: vectors.F32x4 = undefined;

        const d2 = minv + maxv;

        if (all(l > vectors.f32x4s(0.5), 3)) {
            s = d / (vectors.f32x4s(2.0) - d2);
        } else {
            s = d / d2;
        }

        if (all(r == maxv, 3)) {
            h = (g - b) / d;
        } else if (all(g == maxv, 3)) {
            h = vectors.f32x4s(2.0) + (b - r) / d;
        } else {
            h = vectors.f32x4s(4.0) + (r - g) / d;
        }

        h /= vectors.f32x4s(6.0);

        if (all(h < vectors.f32x4s(0.0), 3)) {
            h += vectors.f32x4s(1.0);
        }

        const lha = select(vectors.boolx4(true, true, false, false), h, la);
        return select(vectors.boolx4(true, false, true, true), lha, s);
    }
}

fn hueToClr(p: vectors.F32x4, q: vectors.F32x4, h: vectors.F32x4) vectors.F32x4 {
    var t = h;

    if (all(t < vectors.f32x4s(0.0), 3))
        t += vectors.f32x4s(1.0);

    if (all(t > vectors.f32x4s(1.0), 3))
        t -= vectors.f32x4s(1.0);

    if (all(t < vectors.f32x4s(1.0 / 6.0), 3))
        return mulAdd(q - p, vectors.f32x4s(6.0) * t, p);

    if (all(t < vectors.f32x4s(0.5), 3))
        return q;

    if (all(t < vectors.f32x4s(2.0 / 3.0), 3))
        return mulAdd(q - p, vectors.f32x4s(6.0) * (vectors.f32x4s(2.0 / 3.0) - t), p);

    return p;
}

pub fn hslToRgb(hsl: vectors.F32x4) vectors.F32x4 {
    const s = swizzle(hsl, .y, .y, .y, .y);
    const l = swizzle(hsl, .z, .z, .z, .z);

    if (all(isNearEqual(s, vectors.f32x4s(0.0), vectors.f32x4s(std.math.floatEps(f32))), 3)) {
        return select(vectors.boolx4(true, true, true, false), l, hsl);
    } else {
        const h = swizzle(hsl, .x, .x, .x, .x);
        var q: vectors.F32x4 = undefined;
        if (all(l < vectors.f32x4s(0.5), 3)) {
            q = l * (vectors.f32x4s(1.0) + s);
        } else {
            q = (l + s) - (l * s);
        }

        const p = vectors.f32x4s(2.0) * l - q;

        const r = hueToClr(p, q, h + vectors.f32x4s(1.0 / 3.0));
        const g = hueToClr(p, q, h);
        const b = hueToClr(p, q, h - vectors.f32x4s(1.0 / 3.0));

        const rg = select(vectors.boolx4(true, false, false, false), r, g);
        const ba = select(vectors.boolx4(true, true, true, false), b, hsl);
        return select(vectors.boolx4(true, true, false, false), rg, ba);
    }
}

pub fn rgbToHsv(rgb: vectors.F32x4) vectors.F32x4 {
    const r = swizzle(rgb, .x, .x, .x, .x);
    const g = swizzle(rgb, .y, .y, .y, .y);
    const b = swizzle(rgb, .z, .z, .z, .z);

    const minv = min(r, min(g, b));
    const v = max(r, max(g, b));
    const d = v - minv;
    const s = if (all(isNearEqual(v, vectors.f32x4s(0.0), vectors.f32x4s(std.math.floatEps(f32))), 3)) vectors.f32x4s(0.0) else d / v;

    if (all(d < vectors.f32x4s(std.math.floatEps(f32)), 3)) {
        const hv = select(vectors.boolx4(true, false, false, false), vectors.f32x4s(0.0), v);
        const hva = select(vectors.boolx4(true, true, true, false), hv, rgb);
        return select(vectors.boolx4(true, false, true, true), hva, s);
    } else {
        var h: vectors.F32x4 = undefined;
        if (all(r == v, 3)) {
            h = (g - b) / d;
            if (all(g < b, 3))
                h += vectors.f32x4s(6.0);
        } else if (all(g == v, 3)) {
            h = vectors.f32x4s(2.0) + (b - r) / d;
        } else {
            h = vectors.f32x4s(4.0) + (r - g) / d;
        }

        h /= vectors.f32x4s(6.0);
        const hv = select(vectors.boolx4(true, false, false, false), h, v);
        const hva = select(vectors.boolx4(true, true, true, false), hv, rgb);
        return select(vectors.boolx4(true, false, true, true), hva, s);
    }
}

pub fn hsvToRgb(hsv: vectors.F32x4) vectors.F32x4 {
    const h = swizzle(hsv, .x, .x, .x, .x);
    const s = swizzle(hsv, .y, .y, .y, .y);
    const v = swizzle(hsv, .z, .z, .z, .z);

    const h6 = h * vectors.f32x4s(6.0);
    const i = floor(h6);
    const f = h6 - i;

    const p = v * (vectors.f32x4s(1.0) - s);
    const q = v * (vectors.f32x4s(1.0) - f * s);
    const t = v * (vectors.f32x4s(1.0) - (vectors.f32x4s(1.0) - f) * s);

    const ii = @as(i32, @intFromFloat(mod(i, vectors.f32x4s(6.0))[0]));
    const rgb = switch (ii) {
        0 => blk: {
            const vt = select(vectors.boolx4(true, false, false, false), v, t);
            break :blk select(vectors.boolx4(true, true, false, false), vt, p);
        },
        1 => blk: {
            const qv = select(vectors.boolx4(true, false, false, false), q, v);
            break :blk select(vectors.boolx4(true, true, false, false), qv, p);
        },
        2 => blk: {
            const pv = select(vectors.boolx4(true, false, false, false), p, v);
            break :blk select(vectors.boolx4(true, true, false, false), pv, t);
        },
        3 => blk: {
            const pq = select(vectors.boolx4(true, false, false, false), p, q);
            break :blk select(vectors.boolx4(true, true, false, false), pq, v);
        },
        4 => blk: {
            const tp = select(vectors.boolx4(true, false, false, false), t, p);
            break :blk select(vectors.boolx4(true, true, false, false), tp, v);
        },
        5 => blk: {
            const vp = select(vectors.boolx4(true, false, false, false), v, p);
            break :blk select(vectors.boolx4(true, true, false, false), vp, q);
        },
        else => unreachable,
    };
    return select(vectors.boolx4(true, true, true, false), rgb, hsv);
}

pub fn rgbToSrgb(rgb: vectors.F32x4) vectors.F32x4 {
    const static = struct {
        const cutoff = vectors.f32x4(0.0031308, 0.0031308, 0.0031308, 1.0);
        const linear = vectors.f32x4(12.92, 12.92, 12.92, 1.0);
        const scale = vectors.f32x4(1.055, 1.055, 1.055, 1.0);
        const bias = vectors.f32x4(0.055, 0.055, 0.055, 1.0);
        const rgamma = 1.0 / 2.4;
    };
    var v = saturate(rgb);
    const v0 = v * static.linear;
    const v1 = static.scale * vectors.f32x4(
        std.math.pow(f32, v[0], static.rgamma),
        std.math.pow(f32, v[1], static.rgamma),
        std.math.pow(f32, v[2], static.rgamma),
        v[3],
    ) - static.bias;
    v = select(v < static.cutoff, v0, v1);
    return select(vectors.boolx4(true, true, true, false), v, rgb);
}

pub fn srgbToRgb(srgb: vectors.F32x4) vectors.F32x4 {
    const static = struct {
        const cutoff = vectors.f32x4(0.04045, 0.04045, 0.04045, 1.0);
        const rlinear = vectors.f32x4(1.0 / 12.92, 1.0 / 12.92, 1.0 / 12.92, 1.0);
        const scale = vectors.f32x4(1.0 / 1.055, 1.0 / 1.055, 1.0 / 1.055, 1.0);
        const bias = vectors.f32x4(0.055, 0.055, 0.055, 1.0);
        const gamma = 2.4;
    };
    var v = saturate(srgb);
    const v0 = v * static.rlinear;
    var v1 = static.scale * (v + static.bias);
    v1 = vectors.f32x4(
        std.math.pow(f32, v1[0], static.gamma),
        std.math.pow(f32, v1[1], static.gamma),
        std.math.pow(f32, v1[2], static.gamma),
        v1[3],
    );
    v = select(v > static.cutoff, v1, v0);
    return select(vectors.boolx4(true, true, true, false), v, srgb);
}