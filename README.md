# sv-multifunction-accelerator
A combined SystemVerilog accelerator repository: includes a rich `accel_custom_top` composite accelerator plus small 2×2/vector primitives for demos and learning.   Single-file design plus a single testbench for easy simulation and verification.
---

## 🚀 Short description

This project groups a comprehensive accelerator (`accel_custom_top`) and several small primitives (matmul2x2, conv2x2, dot4, dot2, transpose, det/inv, systolic2x2) into one portable SystemVerilog file. The testbench runs example vectors and 2×2 matrices and prints results for quick verification.

---

## 🔧 Modules (high-level)
- `accel_custom_top` — primary composite accelerator (add, mul, div, min/max, mac, vdot, transpose, det/inv, …). Use this as the top-level accelerator instance.
- `matmul2x2`, `conv2x2` — 2×2 matrix ops and inner product.
- `dot4`, `dot2` — small vector dot products.
- `systolic2x2` — tiny demo of systolic-like MAC pipeline.
- `det_inv2x2`, `transpose2x2` — matrix utilities.

---

## ▶️ Simulation

### Compile
```bash
ncvlog accel.sv tb_accel.sv
