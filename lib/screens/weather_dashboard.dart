import 'package:flutter/material.dart';
import 'weather_service.dart';
import 'weather_model.dart';

class WeatherDashboard extends StatefulWidget {
  const WeatherDashboard({super.key});

  @override
  _WeatherDashboardState createState() => _WeatherDashboardState();
}

class _WeatherDashboardState extends State<WeatherDashboard> {
  final WeatherService _weatherService = WeatherService();
  Weather? _weather;
  final TextEditingController _cityController = TextEditingController();
  bool _isLoading = false;

  void _searchWeather() async {
    if (_cityController.text.isEmpty) return;
    
    setState(() => _isLoading = true);
    try {
      final weather = await _weatherService.getWeather(_cityController.text.trim());
      setState(() {
        _weather = weather;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('City not found. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Weather Forecast', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1B5E20), // Forest Green
              Color(0xFF4CAF50), // Leaf Green
              Color(0xFFFDFDF5), // Cream bottom
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // 1. Stylish Search Bar
                _buildSearchBar(),
                const SizedBox(height: 30),

                if (_isLoading)
                  const CircularProgressIndicator(color: Colors.white)
                else if (_weather != null)
                  _buildWeatherDisplay()
                else
                  _buildInitialState(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: _cityController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search City...',
          hintStyle: const TextStyle(color: Colors.white70),
          prefixIcon: const Icon(Icons.location_on, color: Colors.white),
          suffixIcon: IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: _searchWeather,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
        onSubmitted: (_) => _searchWeather(),
      ),
    );
  }

  Widget _buildWeatherDisplay() {
    return Column(
      children: [
        Text(
          _weather!.cityName.toUpperCase(),
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2),
        ),
        const Text(
          "Today",
          style: TextStyle(color: Colors.white70, fontSize: 18),
        ),
        const SizedBox(height: 10),
        
        // Main Weather Image
        Image.network(
          'https://openweathermap.org/img/wn/${_weather!.icon}@4x.png',
          height: 150,
        ),
        
        Text(
          '${_weather!.temperature.toStringAsFixed(0)}°',
          style: const TextStyle(fontSize: 80, fontWeight: FontWeight.w200, color: Colors.white),
        ),
        
        Text(
          _weather!.description.toUpperCase(),
          style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w500, letterSpacing: 1),
        ),
        
        const SizedBox(height: 40),

        // Weather Detail Row
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _infoTile(Icons.water_drop_outlined, "Humidity", "${_weather!.humidity}%"),
              const VerticalDivider(thickness: 1),
              _infoTile(Icons.cloud_outlined, "Condition", _weather!.description),
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF1B5E20)),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Widget _buildInitialState() {
    return Column(
      children: [
        const SizedBox(height: 100),
        Icon(Icons.cloud_queue, size: 100, color: Colors.white.withOpacity(0.5)),
        const SizedBox(height: 20),
        const Text(
          "Check the weather before you farm",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 18),
        ),
      ],
    );
  }
}