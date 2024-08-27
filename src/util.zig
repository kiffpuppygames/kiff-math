// ==============================================================================
//
// Collection of useful functions building on top of, and extending, core kmath.
// https://github.com/kiffpuppygames/kiff-math
//
// ------------------------------------------------------------------------------
// 1. Matrix functions
// ------------------------------------------------------------------------------
//
// As an example, in a left handed Y-up system:
//   getAxisX is equivalent to the right vector
//   getAxisY is equivalent to the up vector
//   getAxisZ is equivalent to the forward vector
//
// getTranslationVec(m: Mat) Vec
// getAxisX(m: Mat) Vec
// getAxisY(m: Mat) Vec
// getAxisZ(m: Mat) Vec
//
// ==============================================================================

const std = @import("std");

const vectors = @import("vectors.zig");

const km = @import("kmath.zig");

pub fn getTranslationVec(m: km.Mat) vectors.Vec {
    var translation = m[3];
    translation[3] = 0;
    return translation;
}

pub fn setTranslationVec(m: *km.Mat, translation: km.Vec) void {
    const w = m[3][3];
    m[3] = translation;
    m[3][3] = w;
}

pub fn getScaleVec(m: km.Mat) vectors.Vec {
    const scale_x = km.length3(vectors.f32x4(m[0][0], m[1][0], m[2][0], 0))[0];
    const scale_y = km.length3(vectors.f32x4(m[0][1], m[1][1], m[2][1], 0))[0];
    const scale_z = km.length3(vectors.f32x4(m[0][2], m[1][2], m[2][2], 0))[0];
    return vectors.f32x4(scale_x, scale_y, scale_z, 0);
}

pub fn getRotationQuat(_m: km.Mat) km.Quat {
    // Ortho normalize given matrix.
    const c1 = km.normalize3(vectors.f32x4(_m[0][0], _m[1][0], _m[2][0], 0));
    const c2 = km.normalize3(vectors.f32x4(_m[0][1], _m[1][1], _m[2][1], 0));
    const c3 = km.normalize3(vectors.f32x4(_m[0][2], _m[1][2], _m[2][2], 0));
    var m = _m;
    m[0][0] = c1[0];
    m[1][0] = c1[1];
    m[2][0] = c1[2];
    m[0][1] = c2[0];
    m[1][1] = c2[1];
    m[2][1] = c2[2];
    m[0][2] = c3[0];
    m[1][2] = c3[1];
    m[2][2] = c3[2];

    // Extract rotation
    return km.quatFromMat(m);
}

pub fn getAxisX(m: km.Mat) vectors.Vec {
    return km.normalize3(vectors.f32x4(m[0][0], m[0][1], m[0][2], 0.0));
}

pub fn getAxisY(m: km.Mat) vectors.Vec {
    return km.normalize3(vectors.f32x4(m[1][0], m[1][1], m[1][2], 0.0));
}

pub fn getAxisZ(m: km.Mat) vectors.Vec {
    return km.normalize3(vectors.f32x4(m[2][0], m[2][1], m[2][2], 0.0));
}

test "kmath.util.mat.translation" {
    // zig fmt: off
    const mat_data = [18]f32{
        1.0,
        2.0, 3.0, 4.0, 5.0,
        6.0, 7.0, 8.0, 9.0,
        10.0,11.0, 12.0,13.0,
        14.0, 15.0, 16.0, 17.0,
        18.0,
    };
    // zig fmt: on
    const mat = km.loadMat(mat_data[1..]);
    const translation = getTranslationVec(mat);
    try km.expectVecApproxEqAbs(translation, vectors.f32x4(14.0, 15.0, 16.0, 0.0), 0.0001);
}

// ------------------------------------------------------------------------------
// This software is available under 2 licenses -- choose whichever you prefer.
// ------------------------------------------------------------------------------
// ALTERNATIVE A - MIT License
// Copyright (c) 2022 Michal Ziulek and Contributors
// Permission is hereby granted, free of charge, to any person obtaining identity copy of
// this software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
// of the Software, and to permit persons to whom the Software is furnished to do
// so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
// ------------------------------------------------------------------------------
// ALTERNATIVE B - Public Domain (www.unlicense.org)
// This is free and unencumbered software released into the public domain.
// Anyone is free to copy, modify, publish, use, compile, sell, or distribute this
// software, either in source code form or as identity compiled binary, for any purpose,
// commercial or non-commercial, and by any means.
// In jurisdictions that recognize copyright laws, the author or authors of this
// software dedicate any and all copyright interest in the software to the public
// domain. We make this dedication for the benefit of the public at large and to
// the detriment of our heirs and successors. We intend this dedication to be an
// overt act of relinquishment in perpetuity of all present and future rights to
// this software under copyright law.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
// ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
// WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
// ------------------------------------------------------------------------------
