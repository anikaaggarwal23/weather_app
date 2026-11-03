# Weather App (Flutter)

A small, single-screen weather app that uses the free Open-Meteo API.

## Technology

- Flutter (Dart 3 or later)
- `http: ^1.2.2` for REST API requests
- Open-Meteo Geocoding API and Forecast API (no API key required)

## Features included

- Search for a city by name
- Fetch city coordinates using the geocoding endpoint
- Fetch and display current temperature, condition, humidity, and wind speed
- Display a five-day forecast with condition and minimum/maximum temperatures
- Loading indicator, empty state, and basic error messages
- Request timeout handling

## Simplified scope / limitations

- Offline caching is not implemented in this simplified version.
- If several cities match the search, the first result is used.
- There is no search history, unit switch, or current-location feature.
- This source package has not been built or tested on an emulator or physical device. It should be run and checked before being treated as a working release.

## Project structure

```text
lib/
  main.dart
  models/
    weather_data.dart
  screens/
    weather_screen.dart
  services/
    weather_helpers.dart
    weather_service.dart
```

The app uses one screen for the interface and state, a service for API requests, and model classes for the weather response data.

## Setup and run

1. Install Flutter (Dart 3 or later) and the Android toolchain.
2. Open a terminal in the project directory.
3. If the Android platform folder is not present, generate it with:

   ```bash
   flutter create --platforms=android .
   ```

4. Install dependencies:

   ```bash
   flutter pub get
   ```

5. Run on an emulator or connected Android device:

   ```bash
   flutter run
   ```

## API flow

1. The app sends the entered city name to the Open-Meteo Geocoding API.
2. It takes the first matching result's latitude and longitude.
3. It requests current conditions and five days of daily forecast data from the Open-Meteo Forecast API.
4. Weather codes are converted to short descriptions and emoji icons in `weather_helpers.dart`.
