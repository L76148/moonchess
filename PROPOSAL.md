# moonchess 项目申报书

## 基本信息

- 项目名称：MoonChess：纯 MoonBit 国际象棋核心库
- 参赛者：L76148
- 联系方式：2237501538@qq.com
- GitHub 仓库链接：https://github.com/L76148/moonchess
- 项目方向：新生态项目建设（数据结构与文件格式基础库）
- 是否为移植项目：否，原创实现，未复制第三方源代码
- 开源许可证：Apache-2.0
- Mooncakes 模块：`L76148/moonchess`

## 项目简介

MoonBit 生态缺少国际象棋的棋盘表示层。FEN 局面串、PGN 棋谱、SAN 记谱和 UCI 协议是这一领域的事实标准，
棋谱回放、题库索引、数据清洗、引擎对拍都要先有一个正确的位棋盘和走子生成，否则每个使用方都得重写一遍。

本项目用纯 MoonBit 补齐这一层：64 位位棋盘、严格 FEN 读写、攻击与合法走子生成、可复现 Zobrist 键，
后续加入 perft、SAN、PGN/EPD 与 UCI。它交付的是库而不是成品游戏——FEN、PGN、UCI 是任意应用都能
复用的交换格式与协议。

生态位核查：以本机 mooncakes 全量索引（3058 个模块，2026-10-17 快照）检索，`bitboard`、`pgn`、`uci`、
`zobrist`、`checkmate`、`castling`、`en passant` 均为 0 命中；`chess` 只命中两个中国象棋包
（`wbgxiaosu/xiangqi`、`guolei-dev/xiangqi`，9×10 棋盘、UCCI 协议、中文纵线记谱），另有一处是
`bobzhang/games` 图形游戏合集里的自走棋小游戏，与本项目没有可替代关系。

## 核心功能范围

- 坐标、颜色、棋子与王车易位权利；代数坐标解析与渲染；
- 64 位 `Bitboard`：行列掩码、并交差、位计数、最低位、升序迭代、图示；
- `Position`：十二个棋子位棋盘加行棋方、易位权、吃过路兵、半步计数、回合数；
- 严格 FEN 读写：四到六字段、缺省计数、容错空格、12 类结构化错误、规范化回写、规范文本逐字节往返；
- 棋盘渲染（FEN 字母图 / Unicode 棋子图）与可复现 Zobrist 键；
- 跳子与滑子攻击生成、被攻击格查询、将军判定；
- 伪合法走子（升变、吃过路兵、易位）与合法过滤（钉住、应将、易位经过被攻击格、吃过路兵暴露王）；
- 计划：perft 计数、将死/逼和/子力不足/五十步/三次重复、SAN、PGN/EPD、UCI 与更完整的命令行。

## 交付范围与工程边界

当前已完成核心数据模型、FEN、渲染、Zobrist、攻击与将军判定、伪合法与合法走子、执行着法；后续按
同样粒度逐个功能交付上述计划项。明确不做：搜索与评估引擎、开局库、残局库、图形界面、网络对局、
Chess960 与其它变体、Shredder-FEN 扩展。

边界理由：本项目定位是"格式与规则内核"。把棋力排除在外，才能把规则正确性做到用 perft 公开节点数
硬验证的程度；宁可在声明范围内做完整，也不交付两侧都不可依赖的半成品。

## 实现路径与技术理解

先做位棋盘与攻击表，再做走子生成，最后用 perft 公开节点数做正确性判据（起始局面 perft(1..6) =
20 / 400 / 8902 / 197281 / 4865609 / 119060324，另有 Kiwipete 等标准局面）。这是国际象棋领域公认的
做法：perft 能把"漏一个吃过路兵、易位少检查一格、升变漏一种"这类 bug 全部逼出来。

关键取舍：方格编号取 `rank * 8 + file`，位棋盘的位 `i` 恒等于 `Square(i)`；十二个位棋盘按颜色主序
排列，取某方某类棋子是一次数组下标；滑子攻击集包含阻挡子，走子生成只需减去己方棋子；FEN 严格但
容忍缺省，回写固定六字段；Zobrist 键表由固定种子经 SplitMix64 导出，跨运行、跨后端一致，并刻意
忽略半步计数与回合数（正是重复局面检测需要的语义）；先显式交付伪合法走子并写明不检查王的安全，
再用 `make_move` 的结果收敛为合法走子。

## 预期验收产物

- 可直接通过 `moon add L76148/moonchess` 使用的库；
- 可运行命令：`moon run cmd/moonchess -- board|unicode|fen|moves|validate "<FEN>"`；
- 覆盖核心路径的测试，并在 `wasm` 与 `wasm-gc` 上通过；
- README、接口文件、CI 工作流与 Apache-2.0 许可证；
- 发布到 mooncakes.io，版本随里程碑递增。

## 当前进展与验收证据

- 仓库公开：https://github.com/L76148/moonchess，提交历史完整，已满足不少于 10 个有效提交的要求，作者 L76148 <2237501538@qq.com>；
- `moon check --target all --deny-warn` 与 `moon fmt --check` 通过；
- `moon test` 77/77，在 `wasm` 与 `wasm-gc` 上同样 77/77；
- CI 首跑全绿：https://github.com/L76148/moonchess/actions/runs/39019801062 ；
- 已实现：FEN、渲染、Zobrist、攻击与将军、伪合法与合法走子、执行着法。

## 原创性与参考说明

本项目为原创实现，非移植，未复制任何第三方源代码。规则依据 FIDE 国际象棋规则；FEN 与 PGN 依据
Portable Game Notation Specification and Implementation Guide；哈希方案依据 Albert Zobrist 提出的
置换哈希思想；以上均为公开规范，不涉及代码复制。许可证为 Apache-2.0。