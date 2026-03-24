import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/game_state_provider.dart';
import '../theme/app_theme.dart';
import 'sudoku_cell.dart';

class SudokuGrid extends ConsumerWidget {
  const SudokuGrid({super.key});

  /// 선택된 셀과 같은 행/열/3x3 박스에 있는지 판단
  bool _isHighlighted(int selectedIndex, int cellIndex) {
    if (selectedIndex == cellIndex) return false;
    final selectedRow = selectedIndex ~/ 9;
    final selectedCol = selectedIndex % 9;
    final cellRow = cellIndex ~/ 9;
    final cellCol = cellIndex % 9;

    if (selectedRow == cellRow || selectedCol == cellCol) return true;

    final selectedBoxRow = selectedRow ~/ 3;
    final selectedBoxCol = selectedCol ~/ 3;
    final cellBoxRow = cellRow ~/ 3;
    final cellBoxCol = cellCol ~/ 3;
    return selectedBoxRow == cellBoxRow && selectedBoxCol == cellBoxCol;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);

    if (gameState == null) {
      return const SizedBox.shrink();
    }

    final board = gameState.board;
    final selectedIndex = gameState.selectedIndex;

    return LayoutBuilder(
      builder: (context, constraints) {
        // 정사각형 그리드: 가로/세로 중 작은 값 사용
        final maxAvailable = math.min(
          constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : MediaQuery.of(context).size.width,
          constraints.maxHeight.isFinite
              ? constraints.maxHeight
              : MediaQuery.of(context).size.height,
        );

        // 외곽 border 2dp×2=4, 내부 세로(가로) 테두리 합계:
        // 굵은선(col 2,5 오른쪽) 2개×2dp=4, 얇은선 6개×1dp=6 → 합계 10dp
        // 총 공제: 4 + 10 = 14dp
        const double totalBorderWidth = 14.0;
        final cellSize = (maxAvailable - totalBorderWidth) / 9;

        return SizedBox(
          width: maxAvailable,
          height: maxAvailable,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.boxBorder, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(9, (row) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(9, (col) {
                    final index = row * 9 + col;
                    final isSelected = selectedIndex == index;
                    final isHighlighted = selectedIndex != null &&
                        _isHighlighted(selectedIndex, index);

                    return _CellWithBorder(
                      row: row,
                      col: col,
                      child: SudokuCell(
                        index: index,
                        cell: board[index],
                        cellSize: cellSize,
                        isSelected: isSelected,
                        isHighlighted: isHighlighted,
                        onTap: () => ref
                            .read(gameStateProvider.notifier)
                            .selectCell(index),
                      ),
                    );
                  }),
                );
              }),
            ),
          ),
        );
      },
    );
  }
}

/// 셀을 감싸는 테두리 위젯
/// 3x3 박스 경계(굵은 선)와 일반 셀 경계(얇은 선)를 구분
class _CellWithBorder extends StatelessWidget {
  final int row;
  final int col;
  final Widget child;

  const _CellWithBorder({
    required this.row,
    required this.col,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final rightIsBoxBoundary = (col + 1) % 3 == 0 && col != 8;
    final bottomIsBoxBoundary = (row + 1) % 3 == 0 && row != 8;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          right: col < 8
              ? BorderSide(
                  color: rightIsBoxBoundary
                      ? AppColors.boxBorder
                      : AppColors.gridBorder,
                  width: rightIsBoxBoundary ? 2 : 1,
                )
              : BorderSide.none,
          bottom: row < 8
              ? BorderSide(
                  color: bottomIsBoxBoundary
                      ? AppColors.boxBorder
                      : AppColors.gridBorder,
                  width: bottomIsBoxBoundary ? 2 : 1,
                )
              : BorderSide.none,
        ),
      ),
      child: child,
    );
  }
}
