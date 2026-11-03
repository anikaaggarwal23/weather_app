# Weather App

A beginner-friendly Flutter weather app made for the Mobile Application Developer internship assignment.

## Technology used

- Flutter: use the version installed on your computer (`flutter --version`). This source package uses Dart 3 syntax.
- Dart SDK: `>=3.0.0 <4.0.0`
- Open-Meteo Geocoding API and Forecast API (no API key required)
- `http: ^1.2.2` for API requests
- `shared_preferences: ^2.3.2` for saving the last successful weather result

## Features completed

- Search for a city by typing its name and pressing Search or the keyboard search action.
- Empty or whitespace-only input is checked before making an API request.
- Geocoding is called first; the first matching city is used if multiple matches are returned.
- Forecast API is called with the latitude and longitude from geocoding.
- Current temperature, weather description/icon, humidity, and wind speed are displayed.
- Five-day forecast displays date, condition, and minimum/maximum temperature.
- Loading indicator while requests are running.
- Friendly messages for an unknown city, request failure, and timeout.
- The last successful result is saved locally. If a later request fails, saved data is displayed with an outdated-data message.
- Unknown weather codes use a fallback description and icon.

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

The app uses a simple screen + service + model structure. `WeatherScreen` contains the UI and basic screen state using Flutter's built-in `setState`. `WeatherService` makes the HTTP requests and converts the response into model objects. `WeatherData` and `ForecastDay` hold the weather information. This keeps the code straightforward without adding a separate state-management package.

## How to set up and run

1. Install Flutter and Android Studio, including an Android emulator or connect an Android phone with USB debugging enabled.
2. Open a terminal in this project folder.
3. If this folder was downloaded as the source ZIP and does not contain an Android platform folder yet, run:

   ```bash
   flutter create --platforms=android .
   ```

   If you already created the Flutter project and copied these files into it, skip this step.
4. Get the packages:

   ```bash
   flutter pub get
   ```
5. Check the setup:

   ```bash
   flutter doctor
   ```

6. Start an emulator or connect your Android phone, then run:

   ```bash
   flutter run
   ```

## Assumptions and known limitations

- If the geocoding API returns more than one city with the same name, the first result is selected. The app does not show a city selection list.
- The app displays temperatures in Celsius and wind speed in km/h. There is no unit switch.
- The app stores only the most recent successful result, not a search history.
- Saved weather is shown after a failed refresh, but the app does not determine the exact age of the saved data.
- The app has not been tested on a physical device as part of preparing this source package. Please run it and check the UI/API behaviour on your own device before submitting.

## What I would improve with more time

- Add a city selection screen when the search returns multiple matches.
- Add pull-to-refresh and a Celsius/Fahrenheit switch.
- Add unit tests for weather-code mapping and JSON parsing.
- Improve the forecast date display and add more detailed network error handling.
- Test on different screen sizes and on a physical Android device.
