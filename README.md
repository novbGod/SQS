# SQS：多体近邻约束的准随机结构生成与物性分析

本项目是一套基于 MATLAB 的科研代码集合，围绕**特殊准随机结构（Special Quasirandom Structures, SQS）**的构造、筛选与物性验证展开。

代码用周期性的 **0/1 序列**（或 k 进制序列、二维矩阵）表示格点上 A/B 原子的占位，借助 **De Bruijn 序列 / De Bruijn 阵列**保证所有 n 体局域构型以最均匀的方式出现，从而获得短程有序尽可能接近随机、但又不出现长程序的原子排布。项目还包含一维 Kronig–Penney 类周期势模型，用于计算能级分布、能量统计与局域化性质。

---

## 核心概念

| 概念 | 说明 |
|---|---|
| **序列表示** | 长度为 2^n 的循环 0/1 串，0 与 1 分别代表 A/B 原子占据 |
| **堆表示（pile）** | 将连续的同类原子压缩为「数量」，如 A³B¹A² → `[3,1,2]`，用于消除平移与交换冗余 |
| **N 体近邻** | 统计序列中长度为 N 的连续片段（构型）出现次数，N=3 时即 BBB、BBA、BAB 等 8 种 |
| **De Bruijn 序列** | 长度为 2^n 的循环序列，每个 n 位子串恰好出现一次——理论上最均匀的短程构型分布 |
| **环形等价** | 平移、翻转后相同的序列视为同一结构，用于去重 |
| **De Bruijn 阵列 / 环面** | De Bruijn 序列的二维推广：所有 m×n 子矩阵恰好出现一次 |
| **k 进制推广** | 将二元推广到三元（k=3）乃至任意 k，对应多组元合金 |

---

## 目录结构

```
SQS/
├── *.m                          # 根目录：一维序列工具函数（近邻统计、堆转换、对称判定等）
├── de_brujin/                   # 一维 De Bruijn 序列：生成、枚举、对称性筛选、绘图
│   ├── debrujinK3/              # 三元（k=3）De Bruijn 序列的生成与校验
│   ├── dimension2debrujin/      # 将一维 De Bruijn 序列折叠为二维阵列（如 16×16）
│   └── KP_Model/                # Kronig–Penney 周期势模型：能谱、能量统计、局域化分析
├── dimension2/                  # 二维 SQS / De Bruijn 阵列：4/5/8 体约束的回溯搜索
│   └── FFMS/                    # FFMS 方法：二维 De Bruijn 环面的系统构造与校验
└── n16.mat 等数据文件
```

### 各目录职责

| 目录 | 主要内容 |
|---|---|
| **根目录** | 一维基础工具：`countAdjacent`、`countAdjacentNbody`、`ballsToPile`、`pileToBalls`、`adjacentN`、`are_rings_equivalent`、`integer_partitions`、`generateInterleavedArrays` 等 |
| **`de_brujin/`** | De Bruijn 序列生成（欧拉回路 / Hierholzer）、全部不等价序列枚举、互换-反序对称筛选、序列可视化 |
| **`de_brujin/debrujinK3/`** | 三元 De Bruijn 序列生成、游程统计、对称性校验 |
| **`de_brujin/dimension2debrujin/`** | 利用 M-序列 + 本原多项式构造 (16,16;4,2) 阵列 |
| **`de_brujin/KP_Model/`** | 一维周期势量子模型：有限差分哈密顿量、`eigs` 求本征态、能级/能量方差统计、Lyapunov 指数与局域化长度 |
| **`dimension2/`** | 二维约束求解：4 体（2×2）、×形 5 体、方形 8 体的回溯/并行搜索与周期性等价判定 |
| **`dimension2/FFMS/`** | FFMS 构造法：`constructType1/2`、`eleK_constructType1/2`、`generateDeBruijnTorus`，以及 `check`/`check2` 校验与绘图 |

---

## 快速开始

### 环境要求

- **MATLAB**（建议 R2016b 及以上；`digraph` 需要 R2015b+）
- 可选工具箱：
  - **Communications Toolbox**：`primpoly`、`lfsr`（`d2debrujin16_16.m` 中有无工具箱的降级方案）
  - **Parallel Computing Toolbox**：`dimension2/dimension2body8_xin.m` 中的 `parpool`

### 加载路径

```matlab
% 在仓库根目录执行
addpath(genpath(pwd));
```

### 示例 1：生成序列并统计多体近邻

```matlab
seq  = generateDeBruijnSequence_v2(4);   % 长度 16 的 0/1 字符串
pile = ballsToPile(seq - '0');           % 转为堆表示
c3   = countAdjacentNbody(pile, 3);      % 三体近邻统计
c4   = countAdjacentNbody(pile, 4);      % 四体近邻统计
```

### 示例 2：枚举全部不等价的 De Bruijn 序列

```matlab
% 直接运行脚本
run('de_brujin/de_brujinAll.m');

% 或调用其中的函数
seqs = findAllUniqueDeBruijnSequences(4);
```

### 示例 3：生成满足二体约束的 SQS

```matlab
addpath('de_brujin/KP_Model');
seqs = generateTwoBodyOnly(8, 1);   % 生成长度 8 的 SQS，返回小球数组
```

### 示例 4：KP 模型能谱 / 局域化分析

```matlab
run('de_brujin/KP_Model/KPgmn3.m');   % 构造周期势、对角化哈密顿量、统计能级
run('de_brujin/KP_Model/KPTest.m');   % 传递矩阵法计算 Lyapunov 指数与局域化长度
```

### 示例 5：二维 De Bruijn 阵列

```matlab
run('de_brujin/dimension2debrujin/d2debrujin16_16.m');   % (16,16;4,2) 阵列

addpath('dimension2/FFMS');
run('dimension2/FFMS/MeshingTechnique.m');               % 生成 De Bruijn 环面并校验
```

---

## 主要函数速查

### 序列生成与判定

| 文件 | 功能 |
|---|---|
| `de_brujin/generateDeBruijnSequence_v2.m` | 修改版 Hierholzer 算法生成 n 阶二元 De Bruijn 序列 |
| `de_brujin/de_brujinAll.m` / `findAllUniqueDeBruijnSequences` | 枚举所有不环形等价的 De Bruijn 序列 |
| `de_brujin/generate_debruijn_sequence.m` | 生成 k 进制、n 阶 De Bruijn 序列 B(k,n) |
| `de_brujin/KP_Model/generateTwoBodyOnly.m` | 按分堆与二体比例筛选、生成 SQS |
| `de_brujin/checkDeBrujin.m` / `determineDeBrujin.m` | 校验序列是否为 De Bruijn 序列 |
| `de_brujin/generate_symmetric_debruijn*.m` | 生成满足互换-翻转对称性的序列 |

### 堆转换与近邻统计

| 文件 | 功能 |
|---|---|
| `ballsToPile.m` / `pileToBalls.m` | 小球排列 ↔ 堆表示互转 |
| `countAdjacent.m` | 计算 n 级二体近邻数 |
| `countAdjacentNbody.m` | 按二进制顺序统计 N 体构型出现次数 |
| `adjacentN.m` / `adjacent2.m` | 逐级近邻筛选 |
| `findAddB.m` | 识别可继续加球的 B 堆索引 |
| `highAdjacent*.m` | 高阶近邻主类生成 |

### 对称性与去重

| 文件 | 功能 |
|---|---|
| `are_rings_equivalent.m` | 判断两个序列是否环形等价（含翻转） |
| `symmetry01.m` | 判断 0/1 互换后是否与原序列等价 |
| `deleteSame.m`、`checkSameGroups.m`、`get_unique_matrices.m` | 去重与唯一结构筛选 |
| `check_periodic_equivalence.m` | 二维周期性边界下的矩阵等价判定 |
| `contains_subarray_periodic.m` | 周期性条件下的子数组包含检测 |

### 二维求解与 FFMS 构造

| 文件 | 功能 |
|---|---|
| `dimension2/dimension2body4.m` | 2×2 四体约束求解 |
| `dimension2/dimensioin2body5HuiSu.m`、`dimension2body8*.m` | ×形 5 体 / 方形 8 体回溯搜索（含并行版本） |
| `dimension2/cross*bodyCount.m`、`square8bodyCount.m` | 二维多体近邻统计 |
| `dimension2/FFMS/constructType1.m` / `constructType2.m` | 由低维阵列构造高维 De Bruijn 阵列 |
| `dimension2/FFMS/MeshingTechnique.m` | 按论文方法生成 De Bruijn 环面 |
| `dimension2/FFMS/check.m` / `check2.m` / `check2AnyShape.m` | De Bruijn 阵列完备性校验 |

### 物理验证与可视化

| 文件 | 功能 |
|---|---|
| `de_brujin/KP_Model/KPgmn3.m` | 周期势哈密顿量构造、对角化、能级统计 |
| `de_brujin/KP_Model/KPTest.m` | 传递矩阵法计算 Lyapunov 指数与局域化长度 |
| `de_brujin/KP_Model/avgE_*.m` | SQS 与随机序列的能量均值/方差对比实验 |
| `de_brujin/KP_Model/CompareEfficient.m` | 图论贪心法与模拟退火法生成效率对比 |
| `debrujinDraw*.m`、`LuoXuanDLA.m`、`drawBalls.m` | 序列/阵列的可视化（圆环、螺旋、方形、小球） |

---

## 数据文件

| 文件 | 说明 |
|---|---|
| `de_brujin/n16.mat` | n=16 相关预生成数据 |
| `dimension2/allCross5body.mat` | ×形 5 体的全部构型数据 |
| `dimension2/FFMS/A44_256_256.mat` | (4,4; ...) 维度的 256×256 De Bruijn 阵列实例 |

---

## 使用注意事项

1. **大量文件是脚本而非函数**：许多 `.m` 以 `clear` 开头，直接运行会清空工作区；建议逐个打开、按需运行，而不是一次性 `run` 整个目录。
2. **同名副本**：根目录与子目录存在同名文件（如 `ballsToPile.m` 在三处出现）。MATLAB 按搜索路径顺序解析，建议用 `addpath` 明确指定目录，避免调用到旧版本。
3. **参数硬编码**：势垒高度 `U`、阶数 `n`、样本数 `num`、`StateNums` 等通常写在脚本开头，运行前请按需修改。
4. **超大文件**：`continiousABnum.m`、`debrujinDrawCircles.m`、`drawK01ballsTree.m`、`maxInterval.m`、`LuoXuanDLA.m` 体积达数百 KB 至 1 MB 以上，主要包含内嵌数据，编辑器打开可能较慢。
5. **函数名与文件名不一致**：`checkSameGroups.m` 内定义的函数为 `checkSameGroups1`；在 MATLAB 中直接调用 `checkSameGroups` 可能报错，需直接调用 `checkSameGroups1` 或重命名文件。
6. **实验性脚本**：`test.m`、`test2.m`、`testtt.m`、`Copy_of_*.m` 等为临时验证脚本，可忽略。
7. **版本记录**：仓库目前只有一次提交（Add files via upload），没有 LICENSE 文件。如需开源分发，建议补充许可证。

---

## 项目背景

代码面向计算材料学中的无序合金建模问题：如何在有限尺寸的超胞中，使局域多体构型（二体、三体乃至更高阶近邻）的分布尽可能接近理想随机合金，同时避免引入长程序。De Bruijn 序列/阵列为这一问题提供了严格的组合数学构造，而 KP 模型部分则用于检验所构造结构在量子层面上的能谱与局域化行为。

---

*本 README 基于对仓库源码的结构与注释分析整理而成。*
