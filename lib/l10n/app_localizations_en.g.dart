// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.g.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Only Timetable';

  @override
  String get saved => 'Saved';

  @override
  String get nearby => 'Nearby';

  @override
  String get settings => 'Settings';

  @override
  String get plugin => 'Plugin';

  @override
  String get about => 'About';

  @override
  String get addPlugin => 'Add Plugin';

  @override
  String get add => 'Add';

  @override
  String get json => 'JSON';

  @override
  String get url => 'URL';

  @override
  String get failed => 'Failed';

  @override
  String get close => 'Close';

  @override
  String get noPluginAvailable => 'No Plugin Available';

  @override
  String updatedOn(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Updated on $dateString';
  }

  @override
  String get neverUpdated => 'Never Updated';

  @override
  String get pluginInfo => 'Plugin Info';

  @override
  String get removePlugin => 'Remove Plugin';

  @override
  String get author => 'Author';

  @override
  String get id => 'ID';

  @override
  String get name => 'Name';

  @override
  String get version => 'Version';

  @override
  String get repositoryUrl => 'Repository URL';

  @override
  String get description => 'Description';

  @override
  String get confirmation => 'Confirmation';

  @override
  String get confirm => 'Confirm';

  @override
  String get cancel => 'Cancel';

  @override
  String get removePluginConfirm =>
      'Are you sure you want to remove this plugin?';

  @override
  String failedToUpdateRoutes(String pluginName) {
    return 'Failed to update routes for $pluginName.';
  }
}
