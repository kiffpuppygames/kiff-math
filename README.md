![Build Status](https://github.com/kiffpuppygames/kiff-math/actions/workflows/main.yml/badge.svg?branch=dev)

# kiff-math

A Linear Algebra Library with 64bit precision as its primary focus based on zmath (https://github.com/zig-gamedev/zig-gamedev/tree/main/libs/kmath). 

I want a linear algebra library that runs on zig latest and can be easily used on its own without having functionality you don't use or having to copy and paste folders around.

# Status
The library currently has base support for quaternions and 3d vectors.

# Benchmarks (ZMath Comparison)

### Test Case 1: Average value over 6 Runs of 500,000,000 iterations each, results may vary based on specs

### Benchmakrs: *(Average value over 5 Runs of 500,000,000 iterations each, results may vary based on specs.)*

#### Github Action:
##### Quaternion Multiplication (Quat32) :
  - KMath: 0.6208s
  - ZMath: 0.9287s  

#### 12th Gen Intel i9-1200KS 3400 (16 Cores, 24 Logical), 64GB:
##### Quaternions:
  - Multiplication KMath (f64): 0.2895s
  - Multiplication ZMath (f32): 0.2886s
  - Inverse KMath (f64): 0.2905s
  - Inverse ZMath (f32): 0.2928s

##### Vectors:
  - Multiply Scalar KMath (f64): 0.2877s
  - Magnitude KMath (f64): 0.2840s
  - Normalize KMath (f64): 0.2937s