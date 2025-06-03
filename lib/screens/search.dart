import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:only_timetable/extensions/shortcut.dart';
import 'package:only_timetable/services/plugin/plugin_service.dart';
import 'package:only_timetable/widgets/simple_search_bar.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String? selectedPlugin;

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
                      child: SimpleSearchBar(onChanged: (query) {}),
                    ),
                  ),
                  CupertinoButton(
                    padding: const EdgeInsets.all(0),
                    minimumSize: const Size(0, 0),
                    child: Text(context.l10n.close),
                    onPressed: () => context.pop(),
                  ),
                ],
              ),
              SizedBox(
                width: double.infinity,
                child: Consumer<PluginService>(
                  builder: (context, pluginService, child) =>
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: pluginService.plugins
                              .map(
                                (plugin) => CupertinoButton.filled(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                  color: selectedPlugin == plugin.id
                                      ? context.colorScheme.primary
                                      : context.colorScheme.shadow,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 5,
                                  ),
                                  minimumSize: const Size(0, 0),
                                  onPressed: () {},
                                  child: Text(
                                    plugin.name,
                                    style: TextStyle(
                                      color: selectedPlugin == plugin.id
                                          ? context.colorScheme.inversePrimary
                                          : context.textColor?.withValues(
                                              alpha: .3,
                                            ),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                ),
              ),
              Expanded(child: GestureDetector(onTap: () => context.pop())),
            ],
          ),
        ),
      ),
    );
  }
}
