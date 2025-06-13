import 'package:flutter/cupertino.dart' hide Route;
import 'package:flutter/material.dart' hide Route;
import 'package:only_timetable/extensions/shortcut.dart';
import 'package:only_timetable/models/route.dart';
import 'package:only_timetable/modals/search_by_plugin_modal.dart';
import 'package:only_timetable/services/plugin/plugin_service.dart';
import 'package:only_timetable/widgets/routes_list.dart';
import 'package:only_timetable/widgets/simple_search_bar.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  Map<String, List<Route>>? _searchResults;
  PluginService? _pluginService;
  String? _query;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
          child: Column(
            spacing: 20,
            children: [
              Row(
                spacing: 10,
                children: [
                  Expanded(
                    child: Hero(
                      tag: "searchbar",
                      child: SimpleSearchBar(
                        onChanged: (query) async {
                          _pluginService ??= Provider.of<PluginService>(
                            context,
                            listen: false,
                          );

                          _searchResults = await _pluginService!.searchRoute(
                            query,
                            limit: 5,
                          );
                          _query = query;

                          setState(() {});
                        },
                      ),
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    child: Text(context.l10n.close),
                    onPressed: () => context.pop(),
                  ),
                ],
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => context.pop(),
                  child: _searchResults == null || _searchResults!.isEmpty
                      ? Container(color: Colors.transparent)
                      : SingleChildScrollView(
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          child: Padding(
                            padding: EdgeInsets.only(
                              bottom: context.mediaQuery.padding.bottom,
                            ),
                            child: Consumer<PluginService>(
                              builder: (context, pluginService, _) => Column(
                                spacing: 20,
                                children: _searchResults!.entries.map((entry) {
                                  final plugin = pluginService.getPluginById(
                                    entry.key,
                                  )!;

                                  return GestureDetector(
                                    // Make it not dissmissible
                                    onTap: () {},
                                    child: Column(
                                      spacing: 5,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                          ),
                                          child: IntrinsicHeight(
                                            child: Row(
                                              children: [
                                                Text(
                                                  plugin.name,
                                                  style: context
                                                      .textTheme
                                                      .titleMedium
                                                      ?.copyWith(
                                                        color: context
                                                            .primaryColor,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                      ),
                                                ),
                                                Expanded(
                                                  child: CupertinoButton(
                                                    padding: EdgeInsets.zero,
                                                    minimumSize: Size.zero,
                                                    alignment:
                                                        Alignment.bottomRight,
                                                    onPressed: () =>
                                                        showModalBottomSheet(
                                                          context: context,
                                                          isScrollControlled:
                                                              true,
                                                          builder: (context) =>
                                                              SearchByPluginModal(
                                                                plugin: plugin,
                                                                query: _query!,
                                                              ),
                                                        ),
                                                    child: Text(
                                                      context.l10n.viewAll,

                                                      style: context
                                                          .textTheme
                                                          .titleSmall
                                                          ?.copyWith(
                                                            color: context
                                                                .primaryColor,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        RoutesList(
                                          plugin: plugin,
                                          routes: entry.value,
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
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
