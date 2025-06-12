import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:only_timetable/extensions/shortcut.dart';

class ModalBase extends StatelessWidget {
  final List<Widget> children;
  final String? title;
  final Widget? titleWidget;
  final EdgeInsetsGeometry? padding;
  final double spacing;

  const ModalBase({
    super.key,
    this.children = const [],
    this.title,
    this.titleWidget,
    this.padding,
    this.spacing = 20,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Container(
        padding:
            padding ??
            EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom:
                  20 +
                  context.mediaQuery.padding.bottom +
                  context.mediaQuery.viewInsets.bottom,
            ),
        constraints: BoxConstraints(
          maxHeight:
              (context.mediaQuery.size.height -
                  context.mediaQuery.padding.top) *
              0.85,
        ),
        decoration: context.containerDecoration.copyWith(
          border: Border.all(color: Colors.transparent),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: spacing,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: double.infinity),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child:
                        titleWidget ??
                        Text(title ?? "", style: context.textTheme.titleLarge),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      child: Icon(
                        LucideIcons.x200,
                        color: context.textColor,
                        size: 25,
                      ),
                      onPressed: () => context.pop(),
                    ),
                  ),
                ],
              ),
            ),
            ...children,
          ],
        ),
      ),
    );
  }
}
