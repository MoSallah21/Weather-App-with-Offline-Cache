import 'package:flutter/material.dart';

import '../../core/theme/weather_condition_style.dart';
import '../../domain/entities/weather_entity.dart';

class WeatherCard extends StatelessWidget {
  final WeatherEntity weather;

  const WeatherCard({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    final style = WeatherConditionStyle.fromCondition(weather.condition);
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Main gradient card ──────────────────────────────────────────────
        _GradientCard(
          gradientColors: style.gradientColors,
          isDark: isDark,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Location row
              Row(
                children: [
                  const Icon(Icons.location_on_rounded,
                      size: 16, color: Colors.white70),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${weather.cityName}, ${weather.country}',
                      style: textTheme.titleSmall?.copyWith(
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Temperature + icon row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${weather.temperatureCelsius.toStringAsFixed(1)}°',
                          style: textTheme.displayLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w300,
                            fontSize: 80,
                            height: 1,
                          ),
                        ),
                        Text(
                          '${weather.temperatureFahrenheit.toStringAsFixed(1)}°F',
                          style: textTheme.titleMedium?.copyWith(
                            color: Colors.white60,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _AnimatedWeatherIcon(
                    iconUrl: weather.conditionIconUrl,
                    fallbackIcon: style.icon,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Condition pill
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(style.emoji,
                            style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Text(
                          weather.condition,
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Feels like ${weather.feelsLikeCelsius.toStringAsFixed(1)}°C',
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // ── Detail tiles ───────────────────────────────────────────────────
        _DetailGrid(weather: weather),

        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Updated ${_formatTime(weather.lastUpdated)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color:
              Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day}/${dt.month}/${dt.year}  $h:$m';
  }
}

// ─── Gradient card container ──────────────────────────────────────────────────

class _GradientCard extends StatelessWidget {
  final List<Color> gradientColors;
  final bool isDark;
  final Widget child;

  const _GradientCard({
    required this.gradientColors,
    required this.isDark,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: isDark
              ? gradientColors
              .map((c) => c.withOpacity(0.75))
              .toList()
              : gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: child,
    );
  }
}

// ─── Animated weather icon ────────────────────────────────────────────────────

class _AnimatedWeatherIcon extends StatefulWidget {
  final String iconUrl;
  final IconData fallbackIcon;

  const _AnimatedWeatherIcon({
    required this.iconUrl,
    required this.fallbackIcon,
  });

  @override
  State<_AnimatedWeatherIcon> createState() => _AnimatedWeatherIconState();
}

class _AnimatedWeatherIconState extends State<_AnimatedWeatherIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _float;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _float = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _float,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, _float.value),
        child: child,
      ),
      child: widget.iconUrl.isNotEmpty
          ? Image.network(
        widget.iconUrl,
        width: 90,
        height: 90,
        errorBuilder: (_, __, ___) => Icon(
          widget.fallbackIcon,
          size: 80,
          color: Colors.white,
        ),
        loadingBuilder: (_, child, progress) => progress == null
            ? child
            : SizedBox(
          width: 90,
          height: 90,
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ),
      )
          : Icon(widget.fallbackIcon, size: 80, color: Colors.white),
    );
  }
}

// ─── Detail grid ──────────────────────────────────────────────────────────────

class _DetailGrid extends StatelessWidget {
  final WeatherEntity weather;

  const _DetailGrid({required this.weather});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.65,
      children: [
        _DetailTile(
          icon: Icons.water_drop_rounded,
          label: 'Humidity',
          value: '${weather.humidity.toStringAsFixed(0)}%',
          accent: Colors.blue,
        ),
        _DetailTile(
          icon: Icons.air_rounded,
          label: 'Wind',
          value: '${weather.windSpeedKph.toStringAsFixed(1)} km/h',
          accent: Colors.teal,
        ),
        _DetailTile(
          icon: Icons.thermostat_rounded,
          label: 'Feels Like',
          value: '${weather.feelsLikeCelsius.toStringAsFixed(1)}°C',
          accent: Colors.orange,
        ),
        _DetailTile(
          icon: Icons.speed_rounded,
          label: 'Wind (mph)',
          value: '${weather.windSpeedMph.toStringAsFixed(1)} mph',
          accent: Colors.purple,
        ),
      ],
    );
  }
}

class _DetailTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accent;

  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 14, color: accent),
              ),
              const SizedBox(width: 7),
              Text(
                label,
                style: tt.bodySmall?.copyWith(
                  color: cs.onSurface.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: tt.titleMedium?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}