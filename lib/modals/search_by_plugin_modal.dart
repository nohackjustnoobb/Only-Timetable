import 'package:flutter/cupertino.dart' hide Route;
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:only_timetable/extensions/shortcut.dart';
import 'package:only_timetable/models/route.dart';
import 'package:only_timetable/services/plugin/base_plugin.dart';
import 'package:only_timetable/services/plugin/plugin_service.dart';
import 'package:only_timetable/modals/modal_base.dart';
import 'package:only_timetable/widgets/routes_list.dart';
import 'package:provider/provider.dart';

class SearchByPluginModal extends StatefulWidget {
  final BasePlugin plugin;
  final String query;

  const SearchByPluginModal({
    super.key,
    required this.plugin,
    required this.query,
  });

  @override
  State<SearchByPluginModal> createState() => _SearchByPluginModalState();
}

class _SearchByPluginModalState extends State<SearchByPluginModal> {
  late final PluginService _pluginService;

  final List<Route> _results = [];
  bool reachingEnd = false;

  @override
  void initState() {
    super.initState();

    _pluginService = Provider.of<PluginService>(context, listen: false);

    loadMore();
  }

  Future<void> loadMore() async {
    final result = await _pluginService.searchRoute(
      widget.query,
      pluginId: widget.plugin.id,
      offset: _results.length,
    );

    setState(() {
      final routes = result[widget.plugin.id]!;

      if (routes.length < 50) reachingEnd = true;

      _results.addAll(routes);
    });
  }

  @override
  Widget build(BuildContext context) {
    final paddingBottom =
        20 +
        context.mediaQuery.padding.bottom +
        context.mediaQuery.viewInsets.bottom;

    return ModalBase(
      padding: EdgeInsets.only(left: 20, right: 20, top: 20),
      spacing: 10,
      titleWidget: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.plugin.name,
            style: context.textTheme.titleMedium?.copyWith(height: .8),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 3,
            children: [
              Icon(LucideIcons.search, color: context.subTextColor, size: 12),
              Text(
                widget.query,
                style: context.textTheme.titleSmall?.copyWith(
                  color: context.subTextColor,
                ),
              ),
            ],
          ),
        ],
      ),
      children: [
        if (_results.isEmpty)
          Padding(
            padding: EdgeInsets.only(top: 20, bottom: paddingBottom),
            child: Text(
              context.l10n.noRoutesFound,
              textAlign: TextAlign.center,
              style: context.textTheme.titleSmall?.copyWith(
                color: context.subTextColor,
              ),
            ),
          )
        else
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: paddingBottom),
              child: Column(
                children: [
                  RoutesList(
                    plugin: widget.plugin,
                    routes: _results,
                    showContainer: false,
                  ),
                  if (!reachingEnd)
                    CupertinoButton(
                      padding: EdgeInsets.only(top: 20),
                      minimumSize: Size.zero,
                      onPressed: () => loadMore(),
                      child: Text(context.l10n.loadMore),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
