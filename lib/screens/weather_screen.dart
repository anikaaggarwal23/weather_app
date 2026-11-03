import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_data.dart';
import '../services/weather_helpers.dart';
import '../services/weather_service.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController cityController = TextEditingController();
  final WeatherService weatherService = WeatherService();
  static const String savedWeatherKey = 'last_weather';

  WeatherData? weatherData;
  bool isLoading = false;
  bool isOfflineData = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    loadSavedWeather();
  }

  Future<void> loadSavedWeather() async {
    final preferences = await SharedPreferences.getInstance();
    final savedWeather = preferences.getString(savedWeatherKey);

    if (savedWeather != null && mounted) {
      try {
        setState(() {
          weatherData = WeatherData.fromJson(
            jsonDecode(savedWeather) as Map<String, dynamic>,
          );
          isOfflineData = true;
        });
      } catch (_) {
        // Ignore saved data if its format is not valid.
      }
    }
  }

  Future<void> searchWeather() async {
    final city = cityController.text.trim();

    if (city.isEmpty) {
      setState(() {
        errorMessage = 'Please enter a city name.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
      isOfflineData = false;
    });

    try {
      final result = await weatherService.getWeather(city);
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(savedWeatherKey, jsonEncode(result.toJson()));

      if (!mounted) return;
      setState(() {
        weatherData = result;
        isOfflineData = false;
        isLoading = false;
      });
    } catch (error) {
      final preferences = await SharedPreferences.getInstance();
      final savedWeather = preferences.getString(savedWeatherKey);

      if (!mounted) return;
      setState(() {
        isLoading = false;
        if (savedWeather != null) {
          try {
            weatherData = WeatherData.fromJson(
              jsonDecode(savedWeather) as Map<String, dynamic>,
            );
            isOfflineData = true;
            errorMessage = 'Could not refresh. Showing your last saved weather.';
          } catch (_) {
            errorMessage = 'Something went wrong. Please try again.';
          }
        } else {
          isOfflineData = false;
          if (error.toString().contains('TimeoutException')) {
            errorMessage = 'The request took too long. Check your connection.';
          } else {
            errorMessage = error.toString().replaceFirst('Exception: ', '');
          }
        }
      });
    }
  }

  @override
  void dispose() {
    cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: cityController,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => searchWeather(),
                decoration: InputDecoration(
                  hintText: 'Enter city name',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: isLoading ? null : searchWeather,
                child: const Text('Search Weather'),
              ),
              if (isLoading) ...[
                const SizedBox(height: 24),
                const Center(child: CircularProgressIndicator()),
                const Center(child: Text('Getting weather...')),
              ],
              if (errorMessage.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
              if (weatherData == null && !isLoading) ...[
                const SizedBox(height: 60),
                const Icon(Icons.cloud_outlined, size: 75, color: Colors.blueGrey),
                const SizedBox(height: 12),
                const Text(
                  'Search for a city to see its weather',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 17),
                ),
              ],
              if (weatherData != null) ...[
                const SizedBox(height: 24),
                if (isOfflineData)
                  Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Showing saved weather. This information may be outdated.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                buildCurrentWeather(weatherData!),
                const SizedBox(height: 24),
                const Text(
                  '5-Day Forecast',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ...weatherData!.forecast.map(buildForecastRow),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCurrentWeather(WeatherData data) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              '${data.cityName}, ${data.country}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(getWeatherIcon(data.weatherCode), style: const TextStyle(fontSize: 55)),
            Text(
              '${data.temperature.toStringAsFixed(1)} °C',
              style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w500),
            ),
            Text(getWeatherDescription(data.weatherCode),
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildWeatherDetail(Icons.water_drop, 'Humidity', '${data.humidity}%'),
                buildWeatherDetail(Icons.air, 'Wind', '${data.windSpeed} km/h'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildWeatherDetail(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(height: 5),
        Text(label),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget buildForecastRow(ForecastDay day) {
    return Card(
      child: ListTile(
        title: Text(day.date),
        leading: Text(getWeatherIcon(day.weatherCode),
            style: const TextStyle(fontSize: 27)),
        subtitle: Text(getWeatherDescription(day.weatherCode)),
        trailing: Text(
          '${day.minimumTemperature.toStringAsFixed(0)}° / '
          '${day.maximumTemperature.toStringAsFixed(0)}°',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
