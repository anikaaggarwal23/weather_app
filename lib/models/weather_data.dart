class WeatherData {
  final String city;
  final String country;
  final double temperature;
  final int weatherCode;
  final int humidity;
  final double windSpeed;
  final List<ForecastDay> forecast;

  const WeatherData({
    required this.city,
    required this.country,
    required this.temperature,
    required this.weatherCode,
    required this.humidity,
    required this.windSpeed,
    required this.forecast,
  });
}

class ForecastDay {
  final String date;
  final int weatherCode;
  final double minTemperature;
  final double maxTemperature;

  const ForecastDay({
    required this.date,
    required this.weatherCode,
    required this.minTemperature,
    required this.maxTemperature,
  });
}
