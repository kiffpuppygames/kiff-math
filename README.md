![Build Status](https://github.com/kiffpuppygames/kiff-math/actions/workflows/main.yml/badge.svg?branch=dev)

# kiff-math

A Linear Algebra Library with 64bit precision as its primary focus based on zmath (https://github.com/zig-gamedev/zig-gamedev/tree/main/libs/zmath). 

I want a linear algebra library that runs on zig latest and can be easily used on its own without having functionality you don't use or having to copy and paste folders around.

# Status

The library currently has base support for quaternions and 3d vectors.

# Benchmarks: 
*(Average value over 5 Runs of 500,000,000 iterations each, results may vary based on specs.)*

### Zig: 0.14.0-dev.1952+9f84f7f92

#### 12th Gen Intel i9-1200KS 3400 (16 Cores, 24 Logical), 64GB:
##### Quaternions:
  - Multiplication KMath (f64): 0.1958s
  - Multiplication ZMath (f32): 0.1966s
  - Inverse KMath (f64): 0.1960s
  - Inverse ZMath (f32): 0.1963s
  - Rotate Vec (f64): 0.2945s
  - Quat slerp (f64): 0.1974s

##### Vectors:
  - Multiply Scalar KMath (f64): 0.2877s
  - Magnitude KMath (f64): 0.2840s
  - Normalize KMath (f64): 0.2937s