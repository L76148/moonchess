# 选题重合核查记录

核查日期：2026-10-17

## 方法

1. 使用本机 mooncakes 全量索引快照：864 个作者目录、3058 个模块（索引于 2026-10-17 10:41 更新）。
2. 对每个模块的 `name`、`description`、`keywords` 做正则检索，而不是依赖模糊搜索。
3. 再用 `moon search` 在线复核，并对相邻项目做 API 级检查（包列表、公开接口）。
4. 最后按模块名末段精确比对 `moonchess` / `chess` / `moon-chess` / `mbtchess`。

## 结果

| 检索词 | 命中 | 说明 |
| --- | --- | --- |
| `chess` | 1 | `wbgxiaosu/xiangqi`（中国象棋） |
| `xiangqi` | 2 | `wbgxiaosu/xiangqi`、`guolei-dev/xiangqi` |
| `fen` | 1 | 同上，象棋的 FEN |
| `bitboard` | 0 | 无 |
| `stockfish` | 0 | 无 |
| `zobrist` | 0 | 无 |
| `perft` | 0 | 无 |
| `pgn` | 0 | 无 |
| `uci` | 0 | 无 |
| `checkmate` / `stalemate` / `castling` / `en passant` | 0 | 无 |
| `san` / `epd` / `movetext` / `algebraic notation` | 0 | 无 |
| `minimax` / `alpha-beta` / `negamax` / `mcts` | 0 | 无 |
| `board` / `piece` / `move generation` / `promotion` | 0 | 无 |

## 相邻项目

### `wbgxiaosu/xiangqi@0.2.3`

中国象棋规则引擎（9x10 棋盘）。5 个包：`cmd`、`ucci`、`module_index`、`package_data`。
使用 UCCI（Universal Chinese Chess Interface）与中文纵线记谱，棋子为将/士/象/马/车/炮/兵。

与本项目的差异：棋种、棋盘尺寸、棋子集合、走子规则、记谱与协议全部不同，不存在可复用或可替代关系。

### `guolei-dev/xiangqi@0.4.0`

中国象棋规则与本地搜索，同样面向 9x10 棋盘与象棋规则。

### `bobzhang/games`

raylib 图形游戏合集（388 个子包，native only）。其中 `auto_chess_micro_2026` 是自走棋小游戏，
公开接口只有一个 `Piece` 类型，没有公开函数，也不是规则或格式库。

### `sacckey/mahjong`

日本麻将算点库，与棋类无关。

## 名称

- `moonchess`、`chess`、`moon-chess`、`mbtchess` 作为模块名末段均不存在；
- `moon search L76148/moonchess` 返回 `No modules found`；
- `L76148` 名下此前只有 `L76148/moon-ron`。

## 结论

国际象棋的规则与文件格式层在 mooncakes 上是空白。现有唯一相关的两个包面向中国象棋，
规则、坐标系与协议均不同，不构成功能重合。