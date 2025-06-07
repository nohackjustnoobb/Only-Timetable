import 'dart:io';

import 'package:apple_maps_flutter/apple_maps_flutter.dart'
    hide LatLng, Polyline;
import 'package:apple_maps_flutter/apple_maps_flutter.dart' as amf;
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart' hide Route;
import 'package:flutter/material.dart' hide Route;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:only_timetable/extensions/shortcut.dart';
import 'package:only_timetable/extensions/theme.dart';
import 'package:only_timetable/globals.dart';
import 'package:only_timetable/models/route.dart';
import 'package:only_timetable/models/stop.dart';
import 'package:only_timetable/services/plugin/base_plugin.dart';
import 'package:only_timetable/services/settings_service.dart';
import 'package:provider/provider.dart';
import 'package:split_view/split_view.dart';

extension AppleMapLatLng on LatLng {
  amf.LatLng toAppleMapLatLng() => amf.LatLng(latitude, longitude);
}

class RouteMap extends StatefulWidget {
  final Route route;
  final Stop origStop;
  final Stop destStop;
  final Function(Stop) onStopTapped;
  final Stop? selectedStop;
  final List<LatLng>? road;

  late final List<Stop> _stopsList;

  RouteMap({
    super.key,
    required this.route,
    required this.origStop,
    required this.destStop,
    required this.onStopTapped,
    this.selectedStop,
    this.road,
  }) {
    _stopsList = route.stops
        .where((stop) => stop.lat != null && stop.long != null)
        .sortedBy((stop) => route.stopsOrder.indexOf(stop.id))
        .toList();
  }

  @override
  State<RouteMap> createState() => _RouteMapState();
}

class _RouteMapState extends State<RouteMap> {
  dynamic _controller;

  @override
  void didUpdateWidget(covariant RouteMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.selectedStop != null) _toStop(widget.selectedStop!);
  }

  void _toStop(Stop stop) {
    if (_controller is MapController) {
      (_controller as MapController).move(LatLng(stop.lat!, stop.long!), 15);
    } else if (_controller is AppleMapController) {
      (_controller as AppleMapController).animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(stop.lat!, stop.long!).toAppleMapLatLng(),
          15,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: context.theme.boxDecoration,
      child: Consumer<SettingsService>(
        builder: (context, settingsService, child) {
          final alwaysUseOSM = settingsService.getSync<bool>(
            SettingsKey.alwaysUseOSM,
          );
          final useOSM = alwaysUseOSM || !Platform.isIOS;

          if (useOSM &&
              (_controller == null || _controller is! MapController)) {
            _controller = MapController();
          }

          return useOSM
              ? FlutterMap(
                  mapController: _controller,
                  options: MapOptions(
                    initialCenter: LatLng(
                      widget.selectedStop?.lat ?? widget.origStop.lat!,
                      widget.selectedStop?.long ?? widget.origStop.long!,
                    ),
                    initialZoom: 15,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    ),
                    if (widget.road != null)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: widget.road!,
                            strokeWidth: 5,
                            color: Colors.red,
                          ),
                        ],
                      ),
                    MarkerLayer(
                      markers: widget._stopsList
                          .map(
                            (stop) => Marker(
                              point: LatLng(stop.lat!, stop.long!),
                              child: GestureDetector(
                                onTap: () => widget.onStopTapped(stop),
                                child: Icon(
                                  Icons.location_on,
                                  shadows: [
                                    Shadow(color: Colors.black, blurRadius: 5),
                                  ],
                                  color:
                                      widget.selectedStop == null ||
                                          widget._stopsList.indexOf(
                                                widget.selectedStop!,
                                              ) <=
                                              widget._stopsList.indexOf(stop)
                                      ? Colors.red
                                      : Colors.grey,
                                  size: 35,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                )
              : AppleMap(
                  onMapCreated: (controller) => _controller = controller,
                  minMaxZoomPreference: MinMaxZoomPreference(10, null),
                  initialCameraPosition: CameraPosition(
                    zoom: 15,
                    target: LatLng(
                      widget.selectedStop?.lat ?? widget.origStop.lat!,
                      widget.selectedStop?.long ?? widget.origStop.long!,
                    ).toAppleMapLatLng(),
                  ),
                  annotations: widget._stopsList
                      .map(
                        (stop) => Annotation(
                          // FIXME the color of the icon is not changing
                          icon: BitmapDescriptor.defaultAnnotationWithHue(
                            widget.selectedStop == null ||
                                    widget._stopsList.indexOf(
                                          widget.selectedStop!,
                                        ) <=
                                        widget._stopsList.indexOf(stop)
                                ? BitmapDescriptor.hueRed
                                : BitmapDescriptor.hueGreen,
                          ),
                          annotationId: AnnotationId(stop.id),
                          position: LatLng(
                            stop.lat!,
                            stop.long!,
                          ).toAppleMapLatLng(),
                          onTap: () => widget.onStopTapped(stop),
                        ),
                      )
                      .toSet(),
                  polylines: {
                    if (widget.road != null)
                      amf.Polyline(
                        polylineId: PolylineId(widget.route.id),
                        points: widget.road!
                            .map((e) => e.toAppleMapLatLng())
                            .toList(),
                        color: Colors.red,
                        width: 5,
                      ),
                  },
                );
        },
      ),
    );
  }
}

class RouteDetailScreen extends StatefulWidget {
  final BasePlugin plugin;
  final Route route;

  const RouteDetailScreen({
    super.key,
    required this.plugin,
    required this.route,
  });

  @override
  State<RouteDetailScreen> createState() => _RouteDetailScreenState();
}

class _RouteDetailScreenState extends State<RouteDetailScreen> {
  Stop? _destStop;
  Stop? _origStop;
  Stop? _selectedStop;
  List<LatLng>? _road;

  late final List<Stop> _sortedStops;

  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    _sortedStops = widget.route.stops.sortedBy(
      (stop) => widget.route.stopsOrder.indexOf(stop.id),
    );

    // Check if the route has any stops
    if (widget.route.stops.isEmpty) return;

    final String? dest =
        widget.route.dest ?? widget.route.stopsOrder.lastOrNull;
    _destStop = widget.route.stops.firstWhereOrNull(
      (stop) => stop.id == dest && stop.lat != null && stop.long != null,
    );

    final String? orig =
        widget.route.orig ?? widget.route.stopsOrder.firstOrNull;
    _origStop = widget.route.stops.firstWhereOrNull(
      (stop) => stop.id == orig && stop.lat != null && stop.long != null,
    );

    // If the destination stop is not found, show an error and return
    if (_destStop == null || _origStop == null) return;

    _scrollController = ScrollController();

    _road = _sortedStops
        .where((stop) => stop.lat != null && stop.long != null)
        .map((stop) => LatLng(stop.lat!, stop.long!))
        .toList();
  }

  void setSelectedStop(Stop stop) {
    setState(() => _selectedStop = stop);

    // TODO subscribe to the eta
  }

  @override
  Widget build(BuildContext context) {
    if (widget.route.stops.isEmpty) {
      context.pop();
      showErrorSnackbar(context.l10n.routeHasNoStops);

      return Container();
    }

    if (_destStop == null || _origStop == null) {
      context.pop();
      showErrorSnackbar(context.l10n.routeHasNoValidStops);

      return Container();
    }

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: context.colorScheme.surface,
        title: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width - 125,
          ),
          child: Column(
            children: [
              Text(
                widget.route.displayId ?? widget.route.id,
                style: context.textTheme.titleMedium?.copyWith(height: .8),
                overflow: TextOverflow.ellipsis,
              ),
              if (_destStop!.name != null)
                Text(
                  context.getLocalizedString(_destStop!.name!),
                  style: context.textTheme.titleSmall?.copyWith(
                    color: context.textColor?.withValues(alpha: .5),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        leading: CupertinoButton(
          child: Icon(
            LucideIcons.chevronLeft200,
            color: context.textColor,
            size: 25,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SplitView(
            controller: SplitViewController(weights: [.3, .7]),
            viewMode: SplitViewMode.Vertical,
            gripColor: Colors.transparent,
            gripColorActive: Colors.transparent,
            indicator: Center(
              child: Container(
                width: 80,
                height: 5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2.5),
                  color: context.colorScheme.inverseSurface.withValues(
                    alpha: 0.2,
                  ),
                ),
              ),
            ),
            activeIndicator: Center(
              child: Container(
                width: 80,
                height: 5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2.5),
                  color: context.colorScheme.inverseSurface.withValues(
                    alpha: 0.25,
                  ),
                ),
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: RouteMap(
                  route: widget.route,
                  origStop: _origStop!,
                  destStop: _destStop!,
                  onStopTapped: setSelectedStop,
                  selectedStop: _selectedStop,
                  road: _road,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: context.theme.boxDecoration,
                  child: ListView.separated(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(vertical: 20),
                    separatorBuilder: (context, index) => IntrinsicHeight(
                      child: Row(
                        spacing: 20,
                        children: [
                          SizedBox(
                            width: 30,
                            child: Center(
                              child: Container(
                                width: 5,
                                color: context.colorScheme.primary.withValues(
                                  alpha: .5,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Divider(
                                color: context.textColor?.withValues(alpha: .1),
                                height: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    itemCount: _sortedStops.length,
                    itemBuilder: (context, index) {
                      final stop = _sortedStops[index];
                      final isSelected = _selectedStop == stop;

                      return IntrinsicHeight(
                        child: Row(
                          spacing: 20,
                          children: [
                            Stack(
                              alignment: AlignmentDirectional.topCenter,
                              children: [
                                Align(
                                  alignment: index == 0
                                      ? Alignment.bottomCenter
                                      : Alignment.topCenter,
                                  child: FractionallySizedBox(
                                    heightFactor:
                                        index == 0 ||
                                            index == _sortedStops.length - 1
                                        ? .5
                                        : 1,
                                    child: Container(
                                      width: 5,
                                      color: context.colorScheme.primary
                                          .withValues(alpha: .5),
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.center,
                                  child: Container(
                                    height: 30,
                                    width: 30,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? context.colorScheme.primary
                                          : context
                                                .colorScheme
                                                .surfaceContainer,
                                      border: BoxBorder.all(
                                        color: isSelected
                                            ? Colors.transparent
                                            : context.colorScheme.primary,
                                        width: 3,
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Center(
                                      child: Text(
                                        (index + 1).toString(),
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : context.colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.visible,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: double.infinity,
                                      child: CupertinoButton(
                                        padding: EdgeInsets.zero,
                                        minimumSize: Size.zero,
                                        alignment: Alignment.centerLeft,
                                        onPressed: () => setSelectedStop(stop),
                                        child: Text(
                                          context.getLocalizedString(
                                            stop.name ?? stop.id,
                                          ),
                                          style: context.textTheme.titleMedium
                                              ?.copyWith(
                                                color: isSelected
                                                    ? context
                                                          .colorScheme
                                                          .primary
                                                    : null,
                                                fontWeight: isSelected
                                                    ? FontWeight.normal
                                                    : null,
                                              ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(),
                                            CupertinoButton(
                                              padding: EdgeInsets.zero,
                                              minimumSize: Size.zero,
                                              onPressed: () {},
                                              child: Icon(
                                                LucideIcons.bookmark200,
                                                color: context.textColor,
                                                size: 25,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
