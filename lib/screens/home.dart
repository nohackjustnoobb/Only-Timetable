import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:only_timetable/extensions/shortcut.dart';
import 'package:only_timetable/globals.dart';
import 'package:only_timetable/screens/search.dart';
import 'package:only_timetable/screens/settings/settings.dart';
import 'package:only_timetable/widgets/simple_search_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

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
                automaticallyImplyLeading: false,
                title: Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Text(context.l10n.appName),
                ),
                centerTitle: false,
                actionsPadding: const EdgeInsets.only(right: 20),
                actions: [
                  CupertinoButton(
                    padding: const EdgeInsets.all(0),
                    minimumSize: const Size(0, 0),
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
            Row(
              children: [
                Expanded(
                  child: Row(
                    spacing: 20,
                    children: buttonText
                        .mapIndexed(
                          (idx, text) => CupertinoButton.filled(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color: selectedIndex == idx
                                ? context.colorScheme.primary
                                : context.colorScheme.shadow,
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 5,
                            ),
                            minimumSize: const Size(0, 0),
                            child: Text(
                              text,
                              style: TextStyle(
                                color: selectedIndex == idx
                                    ? context.colorScheme.inversePrimary
                                    : context.textColor?.withValues(alpha: .3),
                              ),
                            ),
                            onPressed: () {},
                          ),
                        )
                        .toList(),
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(25, 0),
                  onPressed: () {
                    showErrorSnackbar("This feature is not implemented yet.");
                  },
                  child: Icon(
                    LucideIcons.listFilter200,
                    weight: 250,
                    color: context.textColor,
                    size: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
