// lib/widgets/progress_header.dart
//
// Widget sin estado que muestra el resumen de progreso de las tareas.

import 'package:flutter/material.dart';

/// Encabezado con métricas de progreso: total, completadas y barra.
class ProgressHeader extends StatelessWidget {
  final int total;
  final int completed;
  final double progress; // 0.0 a 1.0

  const ProgressHeader({
    super.key,
    required this.total,
    required this.completed,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = (progress * 100).toStringAsFixed(0);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progreso general',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$percent%',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: theme.colorScheme.onPrimaryContainer.withAlpha(40),
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _StatChip(
                icon: Icons.check_circle_outline,
                label: '$completed completadas',
                color: theme.colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: 12),
              _StatChip(
                icon: Icons.radio_button_unchecked,
                label: '${total - completed} pendientes',
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Chip pequeño de estadística interna al encabezado.
class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color.withAlpha(200)),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
        ),
      ],
    );
  }
}
