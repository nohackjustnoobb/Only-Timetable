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
  String get repository => 'Repository';

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

  @override
  String get noRoutesFound => 'No Routes Found';

  @override
  String get viewAll => 'View All';

  @override
  String get loadMore => 'Load More';

  @override
  String get general => 'General';

  @override
  String get alwaysUseOSM => 'Always use OpenStreetMap';

  @override
  String get routeHasNoStops => 'This route has no stops.';

  @override
  String get routeHasNoValidStops => 'This route has no valid stops.';

  @override
  String get failedToLoadRoute => 'Failed to load route.';

  @override
  String mins(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes mins',
      one: '1 min',
    );
    return '$_temp0';
  }

  @override
  String get noEtaAvailable => 'No ETA available';

  @override
  String get loadingEta => 'Loading ETA...';

  @override
  String get bookmark => 'Bookmark';

  @override
  String get createBookmark => 'Create Bookmark';

  @override
  String get bookmarkName => 'Bookmark Name';

  @override
  String get create => 'Create';

  @override
  String get bookmarkNameRequired => 'Bookmark name is required.';

  @override
  String get defaultBookmark => 'Default';

  @override
  String get deleteBookmarkConfirm =>
      'Are you sure you want to delete this bookmark?';

  @override
  String get done => 'Done';

  @override
  String get bookmarkAlreadyExists =>
      'A bookmark with this name already exists.';

  @override
  String get min => 'min(s)';

  @override
  String get hour => 'hour(s)';

  @override
  String get license => 'License';

  @override
  String get themeMode => 'Theme Mode';

  @override
  String get auto => 'Auto';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get language => 'Language';

  @override
  String get primaryColor => 'Primary Color';

  @override
  String get colorPicker => 'Color Picker';

  @override
  String get filter => 'Filter';

  @override
  String get showRoutesFrom => 'Show Routes From:';

  @override
  String failedToUpdateEta(String routeId) {
    return 'Failed to update ETA for $routeId.';
  }
}
