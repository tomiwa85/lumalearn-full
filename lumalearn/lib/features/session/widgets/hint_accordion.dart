import 'package:flutter/material.dart';
import 'package:lumalearn/core/theme/app_theme.dart';

class HintAccordion extends StatefulWidget {
  final int hintNumber;
  final String title;
  final String content;
  final bool isLocked;
  final VoidCallback? onUnlock;

  const HintAccordion({
    super.key,
    required this.hintNumber,
    required this.title,
    required this.content,
    this.isLocked = true,
    this.onUnlock,
  });

  @override
  State<HintAccordion> createState() => _HintAccordionState();
}

class _HintAccordionState extends State<HintAccordion> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceGrey,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isLocked
              ? Colors.transparent
              : AppTheme.neonGreen.withOpacity(_isExpanded ? 0.5 : 0.2),
        ),
        boxShadow: _isExpanded && !widget.isLocked
            ? [
          BoxShadow(
            color: AppTheme.neonGreen.withOpacity(0.1),
            blurRadius: 12,
            spreadRadius: 2,
          )
        ]
            : [],
      ),
      child: Column(
        children: [
          // HEADER ROW
          InkWell(
            onTap: widget.isLocked
                ? widget.onUnlock // If locked, clicking tries to unlock
                : () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  // Icon Change based on State
                  Icon(
                    widget.isLocked
                        ? Icons.lock_outline
                        : (_isExpanded ? Icons.lightbulb : Icons.lightbulb_outline),
                    color: widget.isLocked ? Colors.grey : AppTheme.neonGreen,
                  ),
                  const SizedBox(width: 12),

                  // Text
                  Expanded(
                    child: Text(
                      widget.isLocked ? "Hint ${widget.hintNumber} (Locked)" : widget.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: widget.isLocked ? Colors.grey : Colors.white,
                      ),
                    ),
                  ),

                  // Arrow or Lock Icon
                  Icon(
                    widget.isLocked
                        ? Icons.lock
                        : (_isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),

          // EXPANDED CONTENT
          AnimatedCrossFade(
            firstChild: Container(height: 0),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 8),
                  Text(
                    widget.content,
                    style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.white70),
                  ),
                ],
              ),
            ),
            crossFadeState: _isExpanded && !widget.isLocked
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}