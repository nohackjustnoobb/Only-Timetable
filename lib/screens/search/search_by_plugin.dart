import 'package:flutter/cupertino.dart' hide Route;
import 'package:flutter/material.dart' hide Route;
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:only_timetable/extensions/shortcut.dart';
import 'package:only_timetable/extensions/theme.dart';
import 'package:only_timetable/models/route.dart';
import 'package:only_timetable/services/plugin/base_plugin.dart';
import 'package:only_timetable/services/plugin/plugin_service.dart';
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

  List<Route> _results = [];
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

    return SizedBox(
      child: Container(
        padding: EdgeInsets.only(left: 20, right: 20, top: 20),
        decoration: context.theme.boxDecoration.copyWith(
          border: Border.all(color: Colors.transparent),
        ),
        constraints: BoxConstraints(
          maxHeight:
              (context.mediaQuery.size.height -
                  context.mediaQuery.padding.top) *
              0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 10,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: double.infinity),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.plugin.name,
                          style: context.textTheme.titleMedium?.copyWith(
                            height: .7,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 3,
                          children: [
                            Icon(
                              LucideIcons.search,
                              color: context.textColor?.withValues(alpha: .5),
                              size: 12,
                            ),
                            Text(
                              widget.query,
                              style: context.textTheme.titleSmall?.copyWith(
                                color: context.textColor?.withValues(alpha: .5),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
            if (_results.isEmpty)
              Padding(
                padding: EdgeInsets.only(top: 20, bottom: paddingBottom),
                child: Text(
                  context.l10n.noRoutesFound,
                  textAlign: TextAlign.center,
                  style: context.textTheme.titleSmall?.copyWith(
                    color: context.textColor?.withValues(alpha: .5),
                  ),
                ),
              )
            else
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: paddingBottom),
                  child: Column(
                    children: [
                      RoutesList(routes: _results, showContainer: false),
                      // TODO automatically load more when reaching the end
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
        ),
      ),
    );
  }
}
