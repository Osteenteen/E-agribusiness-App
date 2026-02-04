class Weather {
  final String cityName;
  final double temperature;
  final String description;
  final int humidity;
  final String icon;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.humidity,
    required this.icon,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'],
      temperature: json['main']['temp'].toDouble(),
      description: json['weather'][0]['description'],
      humidity: json['main']['humidity'],
      icon: json['weather'][0]['icon'],
    );
  }
}
