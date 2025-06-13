import 'package:flutter/cupertino.dart' hide Route;
import 'package:flutter/material.dart' hide Route;
import 'package:collection/collection.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mutex/mutex.dart';

import 'package:only_timetable/extensions/shortcut.dart';
import 'package:only_timetable/modals/filter_modal.dart';
import 'package:only_timetable/models/bookmark.dart';
import 'package:only_timetable/models/fast_hash.dart';
import 'package:only_timetable/models/route.dart';
import 'package:only_timetable/models/stop.dart';
import 'package:only_timetable/screens/search/search.dart';
import 'package:only_timetable/screens/settings/settings.dart';
import 'package:only_timetable/services/bookmark_service.dart';
import 'package:only_timetable/services/eta_service.dart';
import 'package:only_timetable/services/plugin/base_plugin.dart';
import 'package:only_timetable/services/plugin/plugin_service.dart';
import 'package:only_timetable/widgets/routes_list.dart';
import 'package:only_timetable/widgets/simple_search_bar.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _ItemDetail {
  final BasePlugin plugin;
  final Route route;
  final Stop stop;
  final Future<void> Function() unsubscribe;

  _ItemDetail({
    required this.plugin,
    required this.route,
    required this.stop,
    required this.unsubscribe,
  });

  static int getId(String pluginId, String routeId, String stopId) {
    return fastHash(pluginId + routeId + stopId);
  }

  int get id => getId(plugin.id, route.id, stop.id);
}

class _HomeScreenState extends State<HomeScreen> {
  String _selected = "default";

  late final BookmarkService _bookmarkService;
  late final PluginService _pluginService;
  late final EtaService _etaService;

  late List<String> _diaplayFromPlugins;
  final Map<int, _ItemDetail> _itemDetails = {};
  final _lock = Mutex();

  void _bookmarkServiceListener() async {
    await _lock.acquire();

    final toRemove = _itemDetails.keys.toList();

    if (_selected != "nearby") {
      final bookmark = _bookmarkService.getBookmark(_selected);
      if (bookmark == null) {
        _selected = "default";
        _lock.release();

        return _bookmarkServiceListener();
      }

      for (final bookmarked in bookmark.bookmarkeds.where(
        (b) => _diaplayFromPlugins.contains(b.pluginId),
      )) {
        final key = _ItemDetail.getId(
          bookmarked.pluginId,
          bookmarked.routeId,
          bookmarked.stopId,
        );
        toRemove.remove(key);

        if (_itemDetails.containsKey(key)) continue;

        final plugin = _pluginService.getPluginById(bookmarked.pluginId);
        if (plugin == null) continue;

        final route = await plugin.isar.routes.getById(bookmarked.routeId);
        if (route == null) continue;

        final stop = await plugin.isar.stops.getById(bookmarked.stopId);
        if (stop == null) continue;

        final unsubscribe = await _etaService.subscribe(plugin, route, stop);

        _itemDetails[key] = _ItemDetail(
          plugin: plugin,
          route: route,
          stop: stop,
          unsubscribe: unsubscribe,
        );
      }
    } else {
      // TODO: Implement nearby
    }

    for (final key in toRemove) {
      if (_itemDetails.containsKey(key)) {
        await _itemDetails[key]!.unsubscribe();
        _itemDetails.remove(key);
      }
    }

    setState(() {});

    _lock.release();
  }

  @override
  void initState() {
    super.initState();

    _bookmarkService = Provider.of<BookmarkService>(context, listen: false);
    _bookmarkService.addListener(_bookmarkServiceListener);

    _pluginService = Provider.of<PluginService>(context, listen: false);
    _etaService = Provider.of<EtaService>(context, listen: false);

    _diaplayFromPlugins = _pluginService.plugins.map((e) => e.id).toList();

    _bookmarkServiceListener();
  }

  @override
  void dispose() {
    _bookmarkService.removeListener(_bookmarkServiceListener);
    for (final itemDetail in _itemDetails.values) {
      itemDetail.unsubscribe();
    }

    super.dispose();
  }

  Future<void> select(String key) async {
    setState(() => _selected = key);

    _bookmarkServiceListener();
  }

  @override
  Widget build(BuildContext context) {
    final buttonText = [context.l10n.saved, context.l10n.nearby];

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AppBar(
                scrolledUnderElevation: 0,
                backgroundColor: context.colorScheme.surface,
                automaticallyImplyLeading: false,
                title: Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Text(context.l10n.appName),
                ),
                centerTitle: false,
                actionsPadding: const EdgeInsets.only(right: 20),
                actions: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerRight,
                    child: Icon(
                      LucideIcons.settings200,
                      color: context.textColor,
                      size: 25,
                    ),
                    onPressed: () => context.push(
                      MaterialPageRoute(builder: (context) => SettingsScreen()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          spacing: 20,
          children: [
            GestureDetector(
              onTap: () => context.push(
                PageRouteBuilder(
                  pageBuilder: (_, _, _) => const SearchScreen(),
                  transitionsBuilder: (_, animation, __, child) =>
                      FadeTransition(opacity: animation, child: child),
                ),
              ),
              child: Hero(
                tag: "searchbar",
                child: SimpleSearchBar(appearanceOnly: true),
              ),
            ),
            IntrinsicHeight(
              child: Row(
                spacing:
                    _diaplayFromPlugins.length != _pluginService.plugins.length
                    ? 10
                    : 0,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Consumer<BookmarkService>(
                        builder: (context, bookmarkService, child) => Row(
                          spacing: 15,
                          children:
                              [
                                ...buttonText,
                                ...bookmarkService.bookmarks.skip(1),
                              ].mapIndexed((idx, obj) {
                                final text = idx < 2
                                    ? obj as String
                                    : (obj as Bookmark).name;

                                final String key;
                                switch (idx) {
                                  case 0:
                                    key = "default";
                                    break;
                                  case 1:
                                    key = "nearby";
                                    break;
                                  default:
                                    key = (obj as Bookmark).name;
                                }

                                return CupertinoButton.filled(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                  color: _selected == key
                                      ? context.primaryColor
                                      : context.colorScheme.shadow,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 5,
                                  ),
                                  minimumSize: Size.zero,
                                  child: Text(
                                    text,
                                    style: TextStyle(
                                      color: _selected == key
                                          ? context.colorScheme.inversePrimary
                                          : context.textColor.withValues(
                                              alpha: .3,
                                            ),
                                    ),
                                  ),
                                  onPressed: () => select(key),
                                );
                              }).toList(),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: double.infinity,
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerRight,
                      minimumSize: const Size(40, 0),
                      onPressed: () => showModalBottomSheet(
                        context: context,
                        builder: (context) => FilterModal(
                          options: _pluginService.plugins,
                          selectedOptions: _diaplayFromPlugins,
                          onFilterChanged: (filter) => setState(() {
                            _diaplayFromPlugins = filter;
                            _bookmarkServiceListener();
                          }),
                        ),
                      ),
                      child: Row(
                        spacing: 5,
                        children: [
                          if (_diaplayFromPlugins.length !=
                              _pluginService.plugins.length)
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: context.primaryColor,
                              ),
                              child: Text(
                                (_pluginService.plugins.length -
                                        _diaplayFromPlugins.length)
                                    .toString(),
                                style: TextStyle(
                                  color: context.colorScheme.inversePrimary,
                                  fontSize: 8,
                                ),
                              ),
                            ),
                          Icon(
                            LucideIcons.listFilter200,
                            weight: 250,
                            color: context.textColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: context.mediaQuery.padding.bottom,
                ),
                child: Builder(
                  builder: (context) {
                    final items = _itemDetails.values;
                    final routes = items.map((item) => item.route).toList();
                    final stops = items.map((item) => item.stop).toList();
                    final plugins = items.map((item) => item.plugin).toList();

                    return RoutesList(
                      routes: routes,
                      stops: stops,
                      plugins: plugins,
                      showContainer: false,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
