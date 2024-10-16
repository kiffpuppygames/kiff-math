![Build Status](https://github.com/kiffpuppygames/kiff-math/actions/workflows/main.yml/badge.svg?branch=dev)

# kiff-math

A Linear Algebra Library with 64bit precision as its primary focus based on zmath (https://github.com/zig-gamedev/zig-gamedev/tree/main/libs/kmath). 

I want a linear algebra library that runs on zig latest and can be easily used on its own without having functionality you don't use or having to copy and paste folders around.

# Status
The library currently has base support for quaternions and 3d vectors.

# Benchmarks (ZMath Comparison)

Average value over 3 Runs of 1,000,000,000 iterations each, results may vary based on specs

### Github Action:
#### Quaternion Multiplication (Quat32) :
- KMath: 0.6208s
- ZMath: 0.9287s  

### 12th Gen Intel i9-1200KS 3400 (16 Cores, 24 Logical), 64GB:
#### Quaternion Multiplication (Quat32)
  - KMath: 0.3928s
  - ZMath: 0.5882s  

# Benchmarks Overall

## 12th Gen Intel i9-1200KS 3400 (16 Cores, 24 Logical), 64GB:
#### Quaternion Multiplication: 0.3895s
#### Magnitude: 0.5869s
#### Normalize: 0.3956s
  