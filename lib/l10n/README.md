# How to Add a New Language

1. **Create the ARB file**

   - In the `lib/l10n` directory, create a new ARB file named `app_<languageCode>.arb` (e.g., `app_fr.arb` for French).
   - Copy the keys from the default ARB file (e.g., `app_en.arb`) and provide translations for each value.

2. **Add the locale to `locale_name.dart`**

   - Open `lib/l10n/locale_name.dart`.
   - Add an entry for the new locale with its language code and display name.

3. **Localizing for iOS: Updating the iOS app bundle**
   - Open your project's `ios/Runner.xcodeproj` in Xcode.
   - In the Project Navigator, select the Runner project file under Projects.
   - Select the Info tab in the project editor.
   - In the Localizations section, click the Add button (+) to add the supported languages and regions to your project. When asked to choose files and reference language, simply select Finish.
   - Xcode will create empty `.strings` files and update the project settings. These are used by the App Store to determine which languages and regions your app supports.
