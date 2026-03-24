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
  final VoidCallback onTap;

  const SudokuCell({
    super.key,
    required this.index,
    required this.cell,
    required this.cellSize,
    required this.isSelected,
    required this.isHighlighted,
    required this.onTap,
  });

  Color _backgroundColor() {
    if (cell.isError) return AppColors.errorBackground;
    if (isSelected) return AppColors.selectedBackground;
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
