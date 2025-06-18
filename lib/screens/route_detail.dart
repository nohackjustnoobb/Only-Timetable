import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:apple_maps_flutter/apple_maps_flutter.dart'
    hide LatLng, Polyline;
import 'package:apple_maps_flutter/apple_maps_flutter.dart' as amf;
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart' hide Route;
import 'package:flutter/material.dart' hide Route;
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mutex/mutex.dart';
import 'package:only_timetable/extensions/shortcut.dart';
import 'package:only_timetable/globals.dart';
import 'package:only_timetable/models/route.dart';
import 'package:only_timetable/models/stop.dart';
import 'package:only_timetable/services/bookmark_service.dart';
import 'package:only_timetable/services/eta_service.dart';
import 'package:only_timetable/services/plugin/base_plugin.dart';
import 'package:only_timetable/services/settings_service.dart';
import 'package:only_timetable/modals/add_bookmark_modal.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
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
  final bool showUserLocation;

  late final List<Stop> _stopsList;

  RouteMap({
    super.key,
    required this.route,
    required this.origStop,
    required this.destStop,
    required this.onStopTapped,
    required this.showUserLocation,
    this.selectedStop,
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

  Stream<LocationMarkerPosition?>? _positionStream;
  StreamSubscription? _subscription;
  LatLng? _location;

  @override
  void dispose() {
    super.dispose();

    _subscription?.cancel();

    if (_controller is MapController) {
      (_controller as MapController).dispose();
    }
  }

  @override
  void didUpdateWidget(covariant RouteMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.selectedStop != null) _toStop(widget.selectedStop!);
  }

  void _toStop(Stop stop) {
    if (stop.lat == null || stop.long == null) return;

    if (_controller is MapController) {
      (_controller as MapController).move(LatLng(stop.lat!, stop.long!), 15);
    } else if (_controller is AppleMapController) {
      (_controller as AppleMapController).showMarkerInfoWindow(
        AnnotationId(stop.id),
      );

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
      decoration: context.containerDecoration,
      child: Consumer<SettingsService>(
        builder: (context, settingsService, child) {
          final alwaysUseOSM = settingsService.getSync<bool>(
            SettingsKey.alwaysUseOSM,
          );
          final useOSM = alwaysUseOSM || !Platform.isIOS;

          if (useOSM &&
              (_controller == null || _controller is! MapController)) {
            _controller = MapController();

            _positionStream ??= LocationMarkerDataStreamFactory()
                .fromGeolocatorPositionStream()
                .asBroadcastStream();

            _subscription ??= _positionStream!.listen(
              (location) => _location ??= location?.latLng,
            );
          }

          return useOSM
              ? Stack(
                  children: [
                    FlutterMap(
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
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: widget._stopsList
                                  .map((stop) => LatLng(stop.lat!, stop.long!))
                                  .toList(),
                              strokeWidth: 5,
                              color: Colors.red,
                            ),
                          ],
                        ),
                        MarkerLayer(
                          markers: [
                            ...widget._stopsList.map(
                              (stop) => Marker(
                                alignment: Alignment.topCenter,
                                rotate: true,
                                point: LatLng(stop.lat!, stop.long!),
                                child: GestureDetector(
                                  onTap: () {
                                    _toStop(stop);
                                    widget.onStopTapped(stop);
                                  },
                                  child: Icon(
                                    Icons.location_on,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black,
                                        blurRadius: 5,
                                      ),
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
                            ),
                            if (widget.selectedStop != null &&
                                widget.selectedStop!.lat != null &&
                                widget.selectedStop!.long != null &&
                                widget.selectedStop!.name != null)
                              Marker(
                                width: 200,
                                rotate: true,
                                alignment: Alignment.bottomCenter,
                                point: LatLng(
                                  widget.selectedStop!.lat!,
                                  widget.selectedStop!.long!,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(
                                          sigmaX: 5,
                                          sigmaY: 5,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(5),
                                          child: Text(
                                            context.getLocalizedString(
                                              widget.selectedStop!.name!,
                                            ),
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (widget.showUserLocation)
                          CurrentLocationLayer(positionStream: _positionStream),
                        SimpleAttributionWidget(
                          source: Text('OpenStreetMap contributors'),
                          backgroundColor: context.colorScheme.surfaceContainer
                              .withValues(alpha: 0.75),
                        ),
                      ],
                    ),
                    if (widget.showUserLocation && _location != null)
                      Positioned(
                        top: 15,
                        right: 15,
                        child: CupertinoButton(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          onPressed: () {
                            if (_controller is! MapController) return;

                            (_controller as MapController).move(_location!, 15);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: context.colorScheme.surfaceContainer
                                  .withValues(alpha: 0.85),
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(5),
                            child: Icon(LucideIcons.locateFixed, size: 25),
                          ),
                        ),
                      ),
                  ],
                )
              : AppleMap(
                  onMapCreated: (controller) {
                    _controller = controller;
                    if (widget.selectedStop != null) {
                      _toStop(widget.selectedStop!);
                    }
                  },
                  minMaxZoomPreference: MinMaxZoomPreference(10, null),
                  initialCameraPosition: CameraPosition(
                    zoom: 15,
                    target: LatLng(
                      widget.selectedStop?.lat ?? widget.origStop.lat!,
                      widget.selectedStop?.long ?? widget.origStop.long!,
                    ).toAppleMapLatLng(),
                  ),
                  myLocationEnabled: widget.showUserLocation,
                  annotations: widget._stopsList
                      .map(
                        (stop) => Annotation(
                          annotationId: AnnotationId(stop.id),
                          icon: BitmapDescriptor.markerAnnotation,
                          infoWindow: InfoWindow(
                            title: context.getLocalizedString(
                              stop.name ?? stop.id,
                            ),
                          ),
                          position: LatLng(
                            stop.lat!,
                            stop.long!,
                          ).toAppleMapLatLng(),
                          onTap: () {
                            _toStop(stop);

                            widget.onStopTapped(stop);
                          },
                        ),
                      )
                      .toSet(),
                  polylines: {
                    amf.Polyline(
                      polylineId: PolylineId(widget.route.id),
                      points: widget._stopsList
                          .map(
                            (stop) => LatLng(
                              stop.lat!,
                              stop.long!,
                            ).toAppleMapLatLng(),
                          )
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

class StopsList extends StatefulWidget {
  final BasePlugin plugin;
  final Route route;
  final List<Stop> sortedStops;
  final Stop? selectedStop;
  final Function(Stop) setSelectedStop;

  const StopsList({
    super.key,
    required this.plugin,
    required this.route,
    required this.sortedStops,
    required this.selectedStop,
    required this.setSelectedStop,
  });

  @override
  State<StopsList> createState() => _StopsListState();
}

class _StopsListState extends State<StopsList> {
  final _controller = AutoScrollController();

  @override
  void initState() {
    super.initState();

    if (widget.selectedStop != null) _toStop(widget.selectedStop!);
  }

  @override
  void didUpdateWidget(covariant StopsList oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.selectedStop != null) _toStop(widget.selectedStop!);
  }

  void _toStop(Stop stop) {
    final index = widget.sortedStops.indexWhere(
      (stop) => stop.id == widget.selectedStop!.id,
    );
    _controller.scrollToIndex(index, preferPosition: AutoScrollPosition.middle);
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: context.containerDecoration,
      child: ListView.separated(
        controller: _controller,
        padding: EdgeInsets.symmetric(vertical: 20),
        separatorBuilder: (context, index) => IntrinsicHeight(
          child: Row(
            spacing: 20,
            children: [
              SizedBox(
                width: 25,
                child: Center(
                  child: Container(
                    width: 5,
                    color: context.primaryColor.withValues(alpha: .5),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Divider(
                    color: context.textColor.withValues(alpha: .1),
                    height: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
        itemCount: widget.sortedStops.length,
        itemBuilder: (context, index) {
          final stop = widget.sortedStops[index];
          final isSelected = widget.selectedStop?.id == stop.id;

          return AutoScrollTag(
            key: ValueKey(stop.id),
            controller: _controller,
            index: index,
            child: IntrinsicHeight(
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
                        child: SizedBox(
                          height: index == widget.sortedStops.length - 1
                              ? 12.5
                              : double.infinity,
                          child: Padding(
                            padding: EdgeInsets.only(
                              top: index == 0 ? 12.5 : 0,
                            ),
                            child: Container(
                              width: 5,
                              color: context.primaryColor.withValues(alpha: .5),
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topCenter,
                        child: GestureDetector(
                          onTap: () => widget.setSelectedStop(stop),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 12.5),
                            child: Container(
                              height: 25,
                              width: 25,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? context.primaryColor
                                    : context.colorScheme.surfaceContainer,
                                border: BoxBorder.all(
                                  color: isSelected
                                      ? Colors.transparent
                                      : context.primaryColor,
                                  width: 3,
                                ),
                                borderRadius: BorderRadius.circular(12.5),
                              ),
                              child: Center(
                                child: Text(
                                  (index + 1).toString(),
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : context.primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.visible,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: CupertinoButton(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              alignment: Alignment.centerLeft,
                              onPressed: () => widget.setSelectedStop(stop),
                              child: Text(
                                context.getLocalizedString(
                                  stop.name ?? stop.id,
                                ),
                                style: context.textTheme.titleMedium?.copyWith(
                                  color: isSelected
                                      ? context.primaryColor
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
                              padding: const EdgeInsets.only(top: 5),
                              child: IntrinsicHeight(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Consumer<EtaService>(
                                      builder: (context, etaService, child) {
                                        final etas = etaService.getEta(
                                          widget.plugin,
                                          widget.route,
                                          stop,
                                        );

                                        final now = DateTime.now();

                                        return etas == null || etas.isEmpty
                                            ? Text(
                                                etas == null
                                                    ? context.l10n.loadingEta
                                                    : context
                                                          .l10n
                                                          .noEtaAvailable,
                                                style: TextStyle(
                                                  color: context.subTextColor,
                                                ),
                                              )
                                            : Row(
                                                spacing: 10,
                                                children: [
                                                  Column(
                                                    spacing: 5,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: etas
                                                        .map(
                                                          (eta) => Row(
                                                            spacing: 5,
                                                            children: [
                                                              Icon(
                                                                eta.isRealTime
                                                                    ? LucideIcons
                                                                          .clock
                                                                    : LucideIcons
                                                                          .calendar,
                                                                color: context
                                                                    .subTextColor,
                                                                size: 16,
                                                              ),
                                                              Text(
                                                                context.l10n.mins(
                                                                  DateTime.fromMillisecondsSinceEpoch(
                                                                        eta.arrivalTime,
                                                                        isUtc:
                                                                            true,
                                                                      )
                                                                      .difference(
                                                                        now,
                                                                      )
                                                                      .inMinutes,
                                                                ),
                                                                style: TextStyle(
                                                                  fontFeatures: [
                                                                    FontFeature.tabularFigures(),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                        .toList(),
                                                  ),
                                                  Column(
                                                    spacing: 5,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: etas
                                                        .map(
                                                          (eta) => Text(
                                                            '(${DateFormat.Hm().format(DateTime.fromMillisecondsSinceEpoch(eta.arrivalTime, isUtc: true).toLocal())})',
                                                            style: TextStyle(
                                                              fontFeatures: [
                                                                FontFeature.tabularFigures(),
                                                              ],
                                                            ),
                                                          ),
                                                        )
                                                        .toList(),
                                                  ),
                                                ],
                                              );
                                      },
                                    ),
                                    Consumer<BookmarkService>(
                                      builder:
                                          (
                                            context,
                                            bookmarkService,
                                            child,
                                          ) => SizedBox(
                                            height: double.infinity,
                                            child: CupertinoButton(
                                              padding: EdgeInsets.zero,
                                              minimumSize: Size(50, 0),
                                              alignment: Alignment.topRight,
                                              onPressed: () =>
                                                  showModalBottomSheet(
                                                    context: context,
                                                    builder: (context) =>
                                                        AddBookmarkModal(
                                                          plugin: widget.plugin,
                                                          route: widget.route,
                                                          stop: stop,
                                                        ),
                                                  ),
                                              child: Icon(
                                                bookmarkService.isBookmarked(
                                                      plugin: widget.plugin,
                                                      route: widget.route,
                                                      stop: stop,
                                                    )
                                                    ? LucideIcons
                                                          .bookmarkCheck200
                                                    : LucideIcons.bookmark200,
                                                color: context.textColor,
                                              ),
                                            ),
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class RouteDetailScreen extends StatefulWidget {
  final BasePlugin plugin;
  final Route route;
  final Stop? stop;

  const RouteDetailScreen({
    super.key,
    required this.plugin,
    required this.route,
    this.stop,
  });

  @override
  State<RouteDetailScreen> createState() => _RouteDetailScreenState();
}

class _RouteDetailScreenState extends State<RouteDetailScreen> {
  Stop? _destStop;
  Stop? _origStop;
  Stop? _selectedStop;
  bool _showUserLocation = false;

  late final List<Stop> _sortedStops;

  final _subscriptionLock = Mutex();
  late final EtaService _etaService;
  Future<void> Function()? _unsubscribeToEta;

  List<double> _weights = [.3, .7];

  @override
  void initState() {
    super.initState();

    //  --------- Check if Route Valid ---------

    // Check if the route has any stops
    if (widget.route.stops.isEmpty) return;

    _sortedStops = widget.route.stops.sortedBy(
      (stop) => widget.route.stopsOrder.indexOf(stop.id),
    );

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

    // --------- Initialize  ---------

    _etaService = Provider.of<EtaService>(context, listen: false);

    // If a stop is provided, check if it is valid and set it as selected
    if (widget.stop != null &&
        _sortedStops.firstWhereOrNull((stop) => stop.id == widget.stop!.id) !=
            null) {
      setSelectedStop(widget.stop!);
    }
  }

  void setSelectedStop(Stop stop) async {
    setState(() => _selectedStop = stop);

    await _subscriptionLock.acquire();

    if (_unsubscribeToEta != null) await _unsubscribeToEta!();

    _unsubscribeToEta = await _etaService.subscribe(
      widget.plugin,
      widget.route,
      stop,
    );

    _subscriptionLock.release();
  }

  @override
  void dispose() {
    super.dispose();

    if (_unsubscribeToEta != null) _unsubscribeToEta!();
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
            crossAxisAlignment: Platform.isAndroid
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
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
                    color: context.subTextColor,
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
        actions: [
          CupertinoButton(
            child: Icon(
              _showUserLocation
                  ? LucideIcons.mapPin200
                  : LucideIcons.mapPinOff200,
              size: 25,
              color: context.textColor,
            ),
            onPressed: () =>
                setState(() => _showUserLocation = !_showUserLocation),
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SplitView(
            onWeightChanged: (value) =>
                _weights = value.whereType<double>().toList(),
            controller: SplitViewController(
              weights: _weights,
              limits: [
                WeightLimit(min: .1, max: .9),
                WeightLimit(min: .1, max: .9),
              ],
            ),
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
                  showUserLocation: _showUserLocation,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: StopsList(
                  plugin: widget.plugin,
                  route: widget.route,
                  sortedStops: _sortedStops,
                  selectedStop: _selectedStop,
                  setSelectedStop: setSelectedStop,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
