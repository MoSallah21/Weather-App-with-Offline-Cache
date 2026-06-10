import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../presentation/cubit/weather_cubit.dart';
import '../../presentation/cubit/weather_state.dart';
import '../widgets/offline_banner.dart';
import '../widgets/theme_toggle_button.dart';
import '../widgets/weather_card.dart';
import '../widgets/weather_search_bar.dart';
import '../widgets/weather_shimmer.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<WeatherCubit>().init();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String city) =>
      context.read<WeatherCubit>().searchWeather(city);

  void _onCityTap(String city) {
    _searchController.text = city;
    context.read<WeatherCubit>().searchWeather(city);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context, context.watch<WeatherCubit>().state),
      body: BlocBuilder<WeatherCubit, WeatherState>(
        builder: (context, state) {
          final isLoading = state is WeatherLoading;
          final recentSearches = switch (state) {
            WeatherInitial s => s.recentSearches,
            WeatherLoaded s  => s.recentSearches,
            WeatherError s   => s.recentSearches,
            _                => <String>[],
          };

          return Column(
            children: [
              if (state is WeatherLoaded && state.isFromCache)
                const OfflineBanner(),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: WeatherSearchBar(
                  controller: _searchController,
                  enabled: !isLoading,
                  onSearch: _onSearch,
                ),
              ),

              Expanded(
                child: switch (state) {
                  WeatherLoading _ => const WeatherShimmer(),
                  WeatherLoaded s  => _LoadedBody(
                    state: s,
                    recentSearches: recentSearches,
                    onRecentTap: _onCityTap,
                  ),
                  WeatherError s   => _ErrorBody(
                    message: s.message,
                    recentSearches: recentSearches,
                    onRecentTap: _onCityTap,
                  ),
                  _                => _InitialBody(
                    recentSearches: recentSearches,
                    onCityTap: _onCityTap,
                  ),
                },
              ),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, WeatherState state) {
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wb_cloudy_rounded,
              color: Theme.of(context).colorScheme.primary, size: 22),
          const SizedBox(width: 8),
          const Text('Weather'),
        ],
      ),
      actions: [
        const ThemeToggleButton(),
        if (state is WeatherLoaded)
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () => context.read<WeatherCubit>().refresh(),
          ),
      ],
    );
  }
}

// ─── Loaded ───────────────────────────────────────────────────────────────────

class _LoadedBody extends StatelessWidget {
  final WeatherLoaded state;
  final List<String> recentSearches;
  final void Function(String) onRecentTap;

  const _LoadedBody({
    required this.state,
    required this.recentSearches,
    required this.onRecentTap,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<WeatherCubit>().refresh(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          WeatherCard(weather: state.weather),
          if (recentSearches.isNotEmpty) ...[
            const SizedBox(height: 24),
            _RecentSearchesSection(
              searches: recentSearches,
              onTap: onRecentTap,
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Error ────────────────────────────────────────────────────────────────────

class _ErrorBody extends StatelessWidget {
  final String message;
  final List<String> recentSearches;
  final void Function(String) onRecentTap;

  const _ErrorBody({
    required this.message,
    required this.recentSearches,
    required this.onRecentTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      children: [
        Card(
          elevation: 0,
          color: colorScheme.errorContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(Icons.error_outline_rounded,
                    size: 48, color: colorScheme.onErrorContainer),
                const SizedBox(height: 12),
                Text(
                  'Something went wrong',
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onErrorContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onErrorContainer.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (recentSearches.isNotEmpty) ...[
          const SizedBox(height: 24),
          _RecentSearchesSection(searches: recentSearches, onTap: onRecentTap),
        ],
      ],
    );
  }
}

// ─── Initial ──────────────────────────────────────────────────────────────────

class _InitialBody extends StatelessWidget {
  final List<String> recentSearches;
  final void Function(String) onCityTap;

  const _InitialBody({
    required this.recentSearches,
    required this.onCityTap,
  });

  // مدن مقترحة مع emoji علمها
  static const List<({String city, String country, String flag})>
  _suggestedCities = [
    (city: 'Dubai',    country: 'UAE',     flag: '🇦🇪'),
    (city: 'Riyadh',   country: 'KSA',     flag: '🇸🇦'),
    (city: 'London',   country: 'UK',      flag: '🇬🇧'),
    (city: 'New York', country: 'USA',     flag: '🇺🇸'),
    (city: 'Tokyo',    country: 'Japan',   flag: '🇯🇵'),
    (city: 'Paris',    country: 'France',  flag: '🇫🇷'),
    (city: 'Sydney',   country: 'AU',      flag: '🇦🇺'),
    (city: 'Cairo',    country: 'Egypt',   flag: '🇪🇬'),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      children: [
        // ── Header ────────────────────────────────────────────────────────
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cs.primaryContainer,
              ),
              child: Icon(Icons.travel_explore_rounded,
                  size: 48, color: cs.primary),
            ),
            const SizedBox(height: 16),
            Text(
              'Where are you?',
              style: tt.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Search above or tap a city to get started',
              textAlign: TextAlign.center,
              style: tt.bodyMedium?.copyWith(
                color: cs.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),

        const SizedBox(height: 28),

        // ── Recent searches (إن وُجدت تظهر أولاً) ─────────────────────────
        if (recentSearches.isNotEmpty) ...[
          _RecentSearchesSection(searches: recentSearches, onTap: onCityTap),
          const SizedBox(height: 24),
        ],

        // ── Suggested cities ──────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 14),
          child: Row(
            children: [
              Icon(Icons.public_rounded,
                  size: 16, color: cs.onSurface.withOpacity(0.5)),
              const SizedBox(width: 6),
              Text(
                'Popular Cities',
                style: tt.titleSmall?.copyWith(
                  color: cs.onSurface.withOpacity(0.5),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _suggestedCities.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.4,
          ),
          itemBuilder: (context, i) {
            final c = _suggestedCities[i];
            return _CityCard(
              city: c.city,
              country: c.country,
              flag: c.flag,
              onTap: () => onCityTap(c.city),
            );
          },
        ),
      ],
    );
  }
}

// ─── City card ────────────────────────────────────────────────────────────────

class _CityCard extends StatelessWidget {
  final String city;
  final String country;
  final String flag;
  final VoidCallback onTap;

  const _CityCard({
    required this.city,
    required this.country,
    required this.flag,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Material(
      color: cs.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Text(flag, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      city,
                      style: tt.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      country,
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 12, color: cs.onSurface.withOpacity(0.3)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Recent Searches ──────────────────────────────────────────────────────────

class _RecentSearchesSection extends StatelessWidget {
  final List<String> searches;
  final void Function(String) onTap;

  const _RecentSearchesSection({
    required this.searches,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Icon(Icons.history_rounded,
                  size: 16, color: cs.onSurface.withOpacity(0.5)),
              const SizedBox(width: 6),
              Text(
                'Recent Searches',
                style: tt.titleSmall?.copyWith(
                  color: cs.onSurface.withOpacity(0.5),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: searches
              .map(
                (city) => ActionChip(
              avatar: Icon(Icons.location_city_rounded,
                  size: 14, color: cs.primary),
              label: Text(city),
              onPressed: () => onTap(city),
              labelStyle: tt.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          )
              .toList(),
        ),
      ],
    );
  }
}