import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_data.dart';

class WeatherService {
  static const String geocodingUrl =
      'https://geocoding-api.open-meteo.com/v1/search';
  static const String forecastUrl = 'https://api.open-meteo.com/v1/forecast';

  Future<WeatherData> getWeather(String city) async {
    // Step 1: Find the city's latitude and longitude.
    final locationUri = Uri.parse(geocodingUrl).replace(queryParameters: {
      'name': city,
      'count': '5',
    });

    final locationResponse = await http
        .get(locationUri)
        .timeout(const Duration(seconds: 12));

    if (locationResponse.statusCode != 200) {
      throw Exception('Could not search for this city. Please try again.');
    }

    final locationData = jsonDecode(locationResponse.body);
    final results = locationData['results'] as List<dynamic>?;

    if (results == null || results.isEmpty) {
      throw Exception('City not found. Check the spelling and try again.');
    }

    // If multiple matches are returned, this app uses the first result.
    final firstResult = results.first as Map<String, dynamic>;
    final latitude = (firstResult['latitude'] as num).toDouble();
    final longitude = (firstResult['longitude'] as num).toDouble();

    // Step 2: Get the weather using the coordinates from step 1.
    final forecastUri = Uri.parse(forecastUrl).replace(queryParameters: {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'current':
          'temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m',
      'daily': 'weather_code,temperature_2m_max,temperature_2m_min',
      'forecast_days': '5',
      'timezone': 'auto',
    });

    final forecastResponse = await http
        .get(forecastUri)
        .timeout(const Duration(seconds: 12));

    if (forecastResponse.statusCode != 200) {
      throw Exception('Could not get weather data. Please try again.');
    }

    final forecastData = jsonDecode(forecastResponse.body);
    final current = forecastData['current'] as Map<String, dynamic>;
    final daily = forecastData['daily'] as Map<String, dynamic>;

    final dates = daily['time'] as List<dynamic>;
    final codes = daily['weather_code'] as List<dynamic>;
    final minimums = daily['temperature_2m_min'] as List<dynamic>;
    final maximums = daily['temperature_2m_max'] as List<dynamic>;

    final forecastDays = <ForecastDay>[];
    for (int i = 0; i < dates.length; i++) {
      forecastDays.add(ForecastDay(
        date: dates[i].toString(),
        weatherCode: (codes[i] as num).toInt(),
        minimumTemperature: (minimums[i] as num).toDouble(),
        maximumTemperature: (maximums[i] as num).toDouble(),
      ));
    }

    return WeatherData(
      cityName: firstResult['name']?.toString() ?? city,
      country: firstResult['country']?.toString() ?? '',
      temperature: (current['temperature_2m'] as num).toDouble(),
      humidity: (current['relative_humidity_2m'] as num).toInt(),
      windSpeed: (current['wind_speed_10m'] as num).toDouble(),
      weatherCode: (current['weather_code'] as num).toInt(),
      forecast: forecastDays,
    );
  }
}
