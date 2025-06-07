# Only Timetable

Only Timetable is a flexible, plugin-based timetable application for bus and other public transport systems. The name "Only Timetable" reflects the app's purpose: it is the **ONLY** app you need for bus and public transport timetables, and it is focused **ONLY** on providing timetable information. There are no distractions—just the essential features for managing and viewing transport schedules. The core app does not include any routes or ETA data by default; all transport information is provided via plugins. This design allows support for any bus company or region simply by adding or developing the appropriate plugin.

## Features

- **Plugin-based architecture:** Easily extend support to new transport providers or regions.
- **No built-in routes or ETAs:** All data is provided by plugins, making the app minimal and adaptable.
- **Supports multiple transport types:** Not limited to buses—can be extended for trains, ferries, etc.

## Getting Started

1. **Clone the repository:**

   ```sh
   git clone https://github.com/nohackjustnoobb/Only-Timetable.git
   cd Only-Timetable
   ```

2. **Install dependencies:**

   ```sh
   flutter pub get
   ```

3. **Run the app:**

   - For Android:
     ```sh
     flutter run -d android
     ```
   - For iOS:
     ```sh
     flutter run -d ios
     ```
   - For web:
     ```sh
     flutter run -d chrome
     ```

## Plugin Development

TODO
