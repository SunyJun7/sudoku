import 'package:flutter/material.dart';

/// 새벽 2:00~8:00 시간대 플레이 차단 화면
///
/// PopScope(canPop: false)로 Android 뒤로가기를 막아
/// 사용자가 차단 화면을 우회할 수 없도록 한다.
class BlockedScreen extends StatelessWidget {
  const BlockedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.nightlight_round,
                    size: 80,
                    color: Color(0xFF5C6BC0),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    '지금은 쉬는 시간이에요',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212121),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '새벽 2시부터 8시까지는\n스도쿠를 즐길 수 없어요.\n8시 이후에 다시 만나요! 😴',
                    style: TextStyle(
                      fontSize: 20,
                      color: Color(0xFF424242),
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '이용 가능 시간: 오전 8시 ~ 새벽 2시',
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF1565C0),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
