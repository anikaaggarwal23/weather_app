import 'package:flutter/material.dart';
import '../models/weather_data.dart';
import '../services/weather_helpers.dart';
import '../services/weather_service.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final _cityController = TextEditingController();
  final _weatherService = WeatherService();
  WeatherData? _weather;
  bool _isLoading = false;
  String _error = '';

  Future<void> _searchWeather() async {
    final city = _cityController.text.trim();
    if (city.isEmpty) {
      setState(() => _error = 'Please enter a city name.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final result = await _weatherService.fetchWeather(city);
      if (!mounted) return;
      setState(() {
        _weather = result;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  void dispose() {
    _cityController.dispose();
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
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextField(
              controller: _cityController,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _searchWeather(),
              decoration: const InputDecoration(
                hintText: 'Enter city name',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _isLoading ? null : _searchWeather,
              child: const Text('Search'),
            ),
            if (_isLoading) ...[
              const SizedBox(height: 28),
              const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 8),
              const Center(child: Text('Loading weather...')),
            ],
            if (_error.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                _error,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ],
            if (_weather == null && !_isLoading) ...[
              const SizedBox(height: 64),
              const Icon(Icons.cloud_outlined, size: 64, color: Colors.blueGrey),
              const SizedBox(height: 12),
              const Text(
                'Search for a city to see its weather',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ],
            if (_weather != null) ...[
              const SizedBox(height: 28),
              _buildCurrentWeather(_weather!),
              const SizedBox(height: 24),
              const Text(
                '5-Day Forecast',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ..._weather!.forecast.map(_buildForecastRow),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentWeather(WeatherData weather) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              '${weather.city}, ${weather.country}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(weatherEmoji(weather.weatherCode),
                style: const TextStyle(fontSize: 52)),
            Text(
              '${weather.temperature.toStringAsFixed(1)} °C',
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w500),
            ),
            Text(weatherDescription(weather.weatherCode),
                style: const TextStyle(fontSize: 17)),
            const SizedBox(height: 16),
            Text('Humidity: ${weather.humidity}%'),
            Text('Wind: ${weather.windSpeed.toStringAsFixed(1)} km/h'),
          ],
        ),
      ),
    );
  }

  Widget _buildForecastRow(ForecastDay day) {
    return Card(
      child: ListTile(
        leading: Text(weatherEmoji(day.weatherCode),
            style: const TextStyle(fontSize: 25)),
        title: Text(day.date),
        subtitle: Text(weatherDescription(day.weatherCode)),
        trailing: Text(
          '${day.minTemperature.toStringAsFixed(0)}° / '
          '${day.maxTemperature.toStringAsFixed(0)}°',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
