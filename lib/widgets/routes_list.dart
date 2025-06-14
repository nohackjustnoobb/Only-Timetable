import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart' hide Route;
import 'package:flutter/material.dart' hide Route;
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:only_timetable/extensions/shortcut.dart';
import 'package:only_timetable/models/route.dart';
import 'package:only_timetable/models/stop.dart';
import 'package:only_timetable/screens/route_detail.dart';
import 'package:only_timetable/services/eta_service.dart';
import 'package:only_timetable/services/plugin/base_plugin.dart';
import 'package:provider/provider.dart';

class RoutesList extends StatelessWidget {
  final List<Route> routes;
  final List<Stop>? stops;
  final List<BasePlugin>? plugins;
  final BasePlugin? plugin;
  final bool showContainer;

  const RoutesList({
    super.key,
    required this.routes,
    this.plugin,
    this.plugins,
    this.stops,
    this.showContainer = true,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Container(
      padding: showContainer
          ? EdgeInsets.symmetric(horizontal: 20, vertical: 10)
          : EdgeInsets.zero,
      decoration: showContainer ? context.containerDecoration : null,
      child: routes.isEmpty
          ? SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  context.l10n.noRoutesFound,
                  textAlign: TextAlign.center,
                  style: context.textTheme.titleSmall?.copyWith(
                    color: context.subTextColor,
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
                  color: context.textColor.withValues(alpha: .1),
                  height: 1,
                ),
              ),
              itemBuilder: (context, index) {
                final route = routes[index];

                final String? dest = route.dest ?? route.stopsOrder.lastOrNull;
                final destName = route.stops
                    .firstWhereOrNull((stop) => stop.id == dest)
                    ?.name;

                String? origName;
                if (stops != null) {
                  origName = stops![index].name;
                } else {
                  final String? orig =
                      route.orig ?? route.stopsOrder.firstOrNull;
                  origName = route.stops
                      .firstWhereOrNull((stop) => stop.id == orig)
                      ?.name;
                }

                return CupertinoButton(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  minimumSize: Size.zero,
                  onPressed: () => context.push(
                    MaterialPageRoute(
                      builder: (context) => RouteDetailScreen(
                        plugin: plugin ?? plugins![index],
                        route: route,
                        stop: stops != null ? stops![index] : null,
                      ),
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
                                  color: context.subTextColor,
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
                                  color: context.subTextColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                      if (stops != null && plugins != null)
                        SizedBox(
                          width: 40,
                          child: Consumer<EtaService>(
                            builder: (context, etaService, child) {
                              final etas = etaService.getEta(
                                plugins![index],
                                route,
                                stops![index],
                              );

                              if (etas == null) {
                                return CupertinoActivityIndicator();
                              }

                              if (etas.isEmpty) {
                                return Icon(LucideIcons.clockAlert200);
                              }

                              final duration =
                                  DateTime.fromMillisecondsSinceEpoch(
                                    etas.first.arrivalTime,
                                    isUtc: true,
                                  ).difference(now);

                              final inHour = duration.inMinutes > 99;

                              return Column(
                                children: [
                                  Text(
                                    (inHour
                                            ? duration.inHours
                                            : duration.inMinutes)
                                        .toString(),
                                    style: context.textTheme.titleLarge
                                        ?.copyWith(color: context.primaryColor),
                                    overflow: TextOverflow.visible,
                                    softWrap: false,
                                  ),
                                  Text(
                                    inHour
                                        ? context.l10n.hour
                                        : context.l10n.min,
                                    style: context.textTheme.titleSmall
                                        ?.copyWith(color: context.subTextColor),
                                    overflow: TextOverflow.visible,
                                    softWrap: false,
                                  ),
                                ],
                              );
                            },
                          ),
                        )
                      else
                        Icon(LucideIcons.route200, color: context.textColor),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
