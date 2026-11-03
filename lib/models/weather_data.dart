class WeatherData {
  final String cityName;
  final String country;
  final double temperature;
  final int humidity;
  final double windSpeed;
  final int weatherCode;
  final List<ForecastDay> forecast;

  WeatherData({
    required this.cityName,
    required this.country,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.weatherCode,
    required this.forecast,
  });

  Map<String, dynamic> toJson() {
    return {
      'cityName': cityName,
      'country': country,
      'temperature': temperature,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'weatherCode': weatherCode,
      'forecast': forecast.map((day) => day.toJson()).toList(),
    };
  }

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final forecastList = (json['forecast'] as List<dynamic>? ?? []);
    return WeatherData(
      cityName: json['cityName'] as String? ?? '',
      country: json['country'] as String? ?? '',
      temperature: (json['temperature'] as num).toDouble(),
      humidity: (json['humidity'] as num).toInt(),
      windSpeed: (json['windSpeed'] as num).toDouble(),
      weatherCode: (json['weatherCode'] as num).toInt(),
      forecast: forecastList
          .map((item) => ForecastDay.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ForecastDay {
  final String date;
  final int weatherCode;
  final double minimumTemperature;
  final double maximumTemperature;

  ForecastDay({
    required this.date,
    required this.weatherCode,
    required this.minimumTemperature,
    required this.maximumTemperature,
  });

  Map<String, dynamic> toJson() => {
        'date': date,
        'weatherCode': weatherCode,
        'minimumTemperature': minimumTemperature,
        'maximumTemperature': maximumTemperature,
      };

  factory ForecastDay.fromJson(Map<String, dynamic> json) {
    return ForecastDay(
      date: json['date'] as String,
      weatherCode: (json['weatherCode'] as num).toInt(),
      minimumTemperature: (json['minimumTemperature'] as num).toDouble(),
      maximumTemperature: (json['maximumTemperature'] as num).toDouble(),
    );
  }
}
