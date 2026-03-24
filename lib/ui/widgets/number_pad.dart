import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/game_state_provider.dart';
import '../theme/app_theme.dart';

class NumberPad extends ConsumerWidget {
  const NumberPad({super.key});

  static const double _buttonSize = 56.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    final isComplete = gameState?.isComplete ?? false;

    // 1~9 버튼 + 지우기 버튼 총 10개 → 2행 5열
    final buttons = <Widget>[
      ...List.generate(9, (i) {
        final number = i + 1;
        return _NumberButton(
          label: '$number',
          fontSize: AppTextStyles.numberPad,
          size: _buttonSize,
          enabled: !isComplete,
          onTap: () =>
              ref.read(gameStateProvider.notifier).placeNumber(number),
        );
      }),
      _NumberButton(
        label: '⌫',
        fontSize: AppTextStyles.numberPad,
        size: _buttonSize,
        enabled: !isComplete,
        onTap: () => ref.read(gameStateProvider.notifier).eraseNumber(),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: buttons,
      ),
    );
  }
}

class _NumberButton extends StatelessWidget {
  final String label;
  final double fontSize;
  final double size;
  final bool enabled;
  final VoidCallback onTap;

  const _NumberButton({
    required this.label,
    required this.fontSize,
    required this.size,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: enabled ? AppColors.primaryButton : AppColors.gridBorder,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: enabled ? onTap : null,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: enabled ? AppColors.primaryButtonText : Colors.white70,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
