import 'package:flutter/material.dart';
import '../../domain/models/cell_state.dart';
import '../theme/app_theme.dart';

class SudokuCell extends StatelessWidget {
  final int index;
  final CellState cell;
  /// 그리드에서 계산된 셀 크기 (LayoutBuilder 기반)
  final double cellSize;
  final bool isSelected;
  final bool isHighlighted;
  /// 마지막으로 숫자를 입력한 셀 여부 — 연한 초록으로 강조
  final bool isLastPlaced;
  final VoidCallback onTap;

  const SudokuCell({
    super.key,
    required this.index,
    required this.cell,
    required this.cellSize,
    required this.isSelected,
    required this.isHighlighted,
    this.isLastPlaced = false,
    required this.onTap,
  });

  Color _backgroundColor() {
    if (cell.isError) return AppColors.errorBackground;
    if (isSelected) return AppColors.selectedBackground;
    // lastPlaced는 선택되지 않은 상태에서만 강조 표시
    if (isLastPlaced) return AppColors.lastPlacedColor;
    if (isHighlighted) return AppColors.highlightBackground;
    return Colors.transparent;
  }

  Color _textColor() {
    if (cell.isError) return AppColors.errorNumber;
    if (cell.isGiven) return AppColors.givenNumber;
    return AppColors.userNumber;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cellSize,
        height: cellSize,
        color: _backgroundColor(),
        alignment: Alignment.center,
        child: cell.value == 0
            ? null
            : Text(
                '${cell.value}',
                style: TextStyle(
                  fontSize: AppTextStyles.cellNumber,
                  fontWeight:
                      cell.isGiven ? FontWeight.bold : FontWeight.normal,
                  color: _textColor(),
                ),
              ),
      ),
    );
  }
}
