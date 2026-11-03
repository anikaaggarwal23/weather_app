String weatherDescription(int code) {
  if (code == 0) return 'Clear sky';
  if ([1, 2, 3].contains(code)) return 'Partly cloudy';
  if ([45, 48].contains(code)) return 'Fog';
  if ([51, 53, 55].contains(code)) return 'Drizzle';
  if ([61, 63, 65, 80, 81, 82].contains(code)) return 'Rain';
  if ([71, 73, 75].contains(code)) return 'Snow';
  if ([95, 96, 99].contains(code)) return 'Thunderstorm';
  return 'Unknown';
}

String weatherEmoji(int code) {
  if (code == 0) return '☀️';
  if ([1, 2, 3].contains(code)) return '⛅';
  if ([45, 48].contains(code)) return '🌫️';
  if ([51, 53, 55, 61, 63, 65, 80, 81, 82].contains(code)) return '🌧️';
  if ([71, 73, 75].contains(code)) return '❄️';
  if ([95, 96, 99].contains(code)) return '⛈️';
  return '🌡️';
}
