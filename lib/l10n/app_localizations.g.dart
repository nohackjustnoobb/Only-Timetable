import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.g.dart';
import 'app_localizations_ja.g.dart';
import 'app_localizations_zh.g.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.g.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('zh'),
    Locale('zh', 'CN'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Only Timetable'**
  String get appName;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @nearby.
  ///
  /// In en, this message translates to:
  /// **'Nearby'**
  String get nearby;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @plugin.
  ///
  /// In en, this message translates to:
  /// **'Plugin'**
  String get plugin;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @addPlugin.
  ///
  /// In en, this message translates to:
  /// **'Add Plugin'**
  String get addPlugin;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @json.
  ///
  /// In en, this message translates to:
  /// **'JSON'**
  String get json;

  /// No description provided for @url.
  ///
  /// In en, this message translates to:
  /// **'URL'**
  String get url;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @noPluginAvailable.
  ///
  /// In en, this message translates to:
  /// **'No Plugin Available'**
  String get noPluginAvailable;

  /// No description provided for @noPluginAvailableDescription.
  ///
  /// In en, this message translates to:
  /// **'There are no plugins available. Please add a plugin to continue.'**
  String get noPluginAvailableDescription;

  /// No description provided for @addLater.
  ///
  /// In en, this message translates to:
  /// **'Add Later'**
  String get addLater;

  /// No description provided for @updatedOn.
  ///
  /// In en, this message translates to:
  /// **'Updated on {date}'**
  String updatedOn(DateTime date);

  /// No description provided for @neverUpdated.
  ///
  /// In en, this message translates to:
  /// **'Never Updated'**
  String get neverUpdated;

  /// No description provided for @pluginInfo.
  ///
  /// In en, this message translates to:
  /// **'Plugin Info'**
  String get pluginInfo;

  /// No description provided for @removePlugin.
  ///
  /// In en, this message translates to:
  /// **'Remove Plugin'**
  String get removePlugin;

  /// No description provided for @author.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get author;

  /// No description provided for @id.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get id;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @repository.
  ///
  /// In en, this message translates to:
  /// **'Repository'**
  String get repository;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @confirmation.
  ///
  /// In en, this message translates to:
  /// **'Confirmation'**
  String get confirmation;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @removePluginConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this plugin?'**
  String get removePluginConfirm;

  /// No description provided for @failedToUpdateRoutes.
  ///
  /// In en, this message translates to:
  /// **'Failed to update routes for {pluginName}.'**
  String failedToUpdateRoutes(String pluginName);

  /// No description provided for @noRoutesFound.
  ///
  /// In en, this message translates to:
  /// **'No Routes Found'**
  String get noRoutesFound;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @loadMore.
  ///
  /// In en, this message translates to:
  /// **'Load More'**
  String get loadMore;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @alwaysUseOSM.
  ///
  /// In en, this message translates to:
  /// **'Always use OpenStreetMap'**
  String get alwaysUseOSM;

  /// No description provided for @routeHasNoStops.
  ///
  /// In en, this message translates to:
  /// **'This route has no stops.'**
  String get routeHasNoStops;

  /// No description provided for @routeHasNoValidStops.
  ///
  /// In en, this message translates to:
  /// **'This route has no valid stops.'**
  String get routeHasNoValidStops;

  /// No description provided for @failedToLoadRoute.
  ///
  /// In en, this message translates to:
  /// **'Failed to load route.'**
  String get failedToLoadRoute;

  /// No description provided for @mins.
  ///
  /// In en, this message translates to:
  /// **'{minutes, plural, one {1 min} other {{minutes} mins}}'**
  String mins(int minutes);

  /// No description provided for @noEtaAvailable.
  ///
  /// In en, this message translates to:
  /// **'No ETA available'**
  String get noEtaAvailable;

  /// No description provided for @loadingEta.
  ///
  /// In en, this message translates to:
  /// **'Loading ETA...'**
  String get loadingEta;

  /// No description provided for @bookmark.
  ///
  /// In en, this message translates to:
  /// **'Bookmark'**
  String get bookmark;

  /// No description provided for @createBookmark.
  ///
  /// In en, this message translates to:
  /// **'Create Bookmark'**
  String get createBookmark;

  /// No description provided for @bookmarkName.
  ///
  /// In en, this message translates to:
  /// **'Bookmark Name'**
  String get bookmarkName;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @bookmarkNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Bookmark name is required.'**
  String get bookmarkNameRequired;

  /// No description provided for @defaultBookmark.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultBookmark;

  /// No description provided for @deleteBookmarkConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this bookmark?'**
  String get deleteBookmarkConfirm;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @bookmarkAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'A bookmark with this name already exists.'**
  String get bookmarkAlreadyExists;

  /// No description provided for @min.
  ///
  /// In en, this message translates to:
  /// **'min(s)'**
  String get min;

  /// No description provided for @hour.
  ///
  /// In en, this message translates to:
  /// **'hour(s)'**
  String get hour;

  /// No description provided for @license.
  ///
  /// In en, this message translates to:
  /// **'License'**
  String get license;

  /// No description provided for @themeMode.
  ///
  /// In en, this message translates to:
  /// **'Theme Mode'**
  String get themeMode;

  /// No description provided for @auto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get auto;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @primaryColor.
  ///
  /// In en, this message translates to:
  /// **'Primary Color'**
  String get primaryColor;

  /// No description provided for @colorPicker.
  ///
  /// In en, this message translates to:
  /// **'Color Picker'**
  String get colorPicker;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @showRoutesFrom.
  ///
  /// In en, this message translates to:
  /// **'Show Routes From:'**
  String get showRoutesFrom;

  /// No description provided for @failedToUpdateEta.
  ///
  /// In en, this message translates to:
  /// **'Failed to update ETA for {routeId}.'**
  String failedToUpdateEta(String routeId);

  /// No description provided for @routesUpdated.
  ///
  /// In en, this message translates to:
  /// **'Routes updated for {pluginName}.'**
  String routesUpdated(String pluginName);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.countryCode) {
          case 'CN':
            return AppLocalizationsZhCn();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
