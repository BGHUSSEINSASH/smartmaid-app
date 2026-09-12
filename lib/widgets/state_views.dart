import 'package:flutter/material.dart';
import '../core/theme/adaptive.dart';
import 'pro_components.dart';
import 'shimmer.dart';

enum AsyncPhase { loading, error, empty, ready }

class AsyncStateView extends StatelessWidget {
  final AsyncPhase phase;
  final Widget? child;
  final Widget? loadingChild;
  final String errorTitle;
  final String errorSubtitle;
  final String emptyTitle;
  final String emptySubtitle;
  final IconData emptyIcon;
  final Future<void> Function()? onRetry;
  final VoidCallback? onEmptyAction;
  final String? emptyActionLabel;

  const AsyncStateView({
    super.key,
    required this.phase,
    this.child,
    this.loadingChild,
    this.errorTitle = 'حدث خطأ ما',
    this.errorSubtitle = 'تعذر تحميل البيانات، تحقق من اتصالك وحاول مجدداً',
    this.emptyTitle = 'لا توجد بيانات',
    this.emptySubtitle = '',
    this.emptyIcon = Icons.inbox_rounded,
    this.onRetry,
    this.onEmptyAction,
    this.emptyActionLabel,
  });

  @override
  Widget build(BuildContext context) {
    switch (phase) {
      case AsyncPhase.loading:
        return loadingChild ??
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              itemCount: 4,
              itemBuilder: (_, _) => const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: ShimmerWorkerCard(),
              ),
            );
      case AsyncPhase.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppErrorPalette.color.withAlpha(22),
                  ),
                  child: const Icon(Icons.cloud_off_rounded,
                      size: 44, color: AppErrorPalette.color),
                ),
                const SizedBox(height: 20),
                Text(errorTitle,
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: context.ink)),
                const SizedBox(height: 8),
                Text(errorSubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 13, height: 1.6, color: context.mutedText)),
                if (onRetry != null) ...[
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded, size: 19),
                    label: const Text('إعادة المحاولة'),
                  ),
                ],
              ],
            ),
          ),
        );
      case AsyncPhase.empty:
        return EmptyState(
          title: emptyTitle,
          subtitle: emptySubtitle,
          icon: emptyIcon,
          onAction: onEmptyAction,
          actionLabel: emptyActionLabel,
        );
      case AsyncPhase.ready:
        return child ?? const SizedBox.shrink();
    }
  }
}

class AppErrorPalette {
  static const Color color = Color(0xFFEF4444);
}
