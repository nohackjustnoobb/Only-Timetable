import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart' hide Route;
import 'package:flutter/material.dart' hide Route;
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:only_timetable/extensions/shortcut.dart';
import 'package:only_timetable/extensions/theme.dart';
import 'package:only_timetable/models/route.dart';
import 'package:only_timetable/screens/route_detail.dart';
import 'package:only_timetable/services/plugin/base_plugin.dart';

class RoutesList extends StatelessWidget {
  final List<Route> routes;
  final BasePlugin plugin;
  final bool showContainer;

  const RoutesList({
    super.key,
    required this.routes,
    required this.plugin,
    this.showContainer = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: showContainer
          ? EdgeInsets.symmetric(horizontal: 20, vertical: 10)
          : EdgeInsets.zero,
      decoration: showContainer ? context.theme.boxDecoration : null,
      child: routes.isEmpty
          ? SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  context.l10n.noRoutesFound,
                  textAlign: TextAlign.center,
                  style: context.textTheme.titleSmall?.copyWith(
                    color: context.textColor?.withValues(alpha: .5),
                  ),
                ),
              ),
            )
          : ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: routes.length,
              separatorBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Divider(
                  color: context.textColor?.withValues(alpha: .1),
                  height: 1,
                ),
              ),
              itemBuilder: (context, index) {
                final route = routes[index];

                final String? dest = route.dest ?? route.stopsOrder.lastOrNull;
                final String? orig = route.orig ?? route.stopsOrder.firstOrNull;

                final destName = route.stops
                    .firstWhereOrNull((stop) => stop.id == dest)
                    ?.name;
                final origName = route.stops
                    .firstWhereOrNull((stop) => stop.id == orig)
                    ?.name;

                return CupertinoButton(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  minimumSize: Size.zero,
                  onPressed: () => context.push(
                    MaterialPageRoute(
                      builder: (context) =>
                          RouteDetailScreen(plugin: plugin, route: route),
                    ),
                  ),
                  child: Row(
                    spacing: 20,
                    children: [
                      SizedBox(
                        width: 45,
                        child: Column(
                          children: [
                            Text(
                              route.displayId ?? route.id,
                              style: context.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (route.source != null)
                              Text(
                                context.getLocalizedString(route.source!),
                                style: context.textTheme.titleSmall?.copyWith(
                                  color: context.textColor?.withValues(
                                    alpha: .5,
                                  ),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (destName != null)
                              Text(
                                context.getLocalizedString(destName),
                                style: context.textTheme.titleMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                            if (destName != null && origName != null)
                              Text(
                                context.getLocalizedString(origName),
                                style: context.textTheme.titleSmall?.copyWith(
                                  color: context.textColor?.withValues(
                                    alpha: .5,
                                  ),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                      Icon(LucideIcons.route200, color: context.textColor),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
