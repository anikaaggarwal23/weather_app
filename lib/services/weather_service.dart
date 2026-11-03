import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_data.dart';

class WeatherService {
  static const _geocodingUrl =
      'https://geocoding-api.open-meteo.com/v1/search';
  static const _forecastUrl = 'https://api.open-meteo.com/v1/forecast';

  Future<WeatherData> fetchWeather(String city) async {
    final locationUri = Uri.parse(_geocodingUrl).replace(
      queryParameters: {'name': city, 'count': '5'},
    );

    final locationResponse = await http
        .get(locationUri)
        .timeout(const Duration(seconds: 12));

    if (locationResponse.statusCode != 200) {
      throw Exception('Could not search for this city. Please try again.');
    }

    final locationJson = jsonDecode(locationResponse.body)
        as Map<String, dynamic>;
    final results = locationJson['results'] as List<dynamic>?;
    if (results == null || results.isEmpty) {
      throw Exception('City not found. Check the spelling and try again.');
    }

    // If there are multiple matches, use the first result.
    final place = results.first as Map<String, dynamic>;
    final latitude = (place['latitude'] as num).toDouble();
    final longitude = (place['longitude'] as num).toDouble();

    final forecastUri = Uri.parse(_forecastUrl).replace(
      queryParameters: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'current':
            'temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m',
        'daily': 'weather_code,temperature_2m_max,temperature_2m_min',
        'forecast_days': '5',
        'timezone': 'auto',
      },
    );

    final forecastResponse = await http
        .get(forecastUri)
        .timeout(const Duration(seconds: 12));

    if (forecastResponse.statusCode != 200) {
      throw Exception('Could not get weather data. Please try again.');
    }

    final forecastJson = jsonDecode(forecastResponse.body)
        as Map<String, dynamic>;
    final current = forecastJson['current'] as Map<String, dynamic>;
    final daily = forecastJson['daily'] as Map<String, dynamic>;

    final dates = daily['time'] as List<dynamic>;
    final codes = daily['weather_code'] as List<dynamic>;
    final minimums = daily['temperature_2m_min'] as List<dynamic>;
    final maximums = daily['temperature_2m_max'] as List<dynamic>;

    final days = <ForecastDay>[];
    for (var i = 0; i < dates.length; i++) {
      days.add(ForecastDay(
        date: dates[i].toString(),
        weatherCode: (codes[i] as num).toInt(),
        minTemperature: (minimums[i] as num).toDouble(),
        maxTemperature: (maximums[i] as num).toDouble(),
      ));
    }

    return WeatherData(
      city: place['name']?.toString() ?? city,
      country: place['country']?.toString() ?? '',
      temperature: (current['temperature_2m'] as num).toDouble(),
      weatherCode: (current['weather_code'] as num).toInt(),
      humidity: (current['relative_humidity_2m'] as num).toInt(),
      windSpeed: (current['wind_speed_10m'] as num).toDouble(),
      forecast: days,
    );
  }
}
