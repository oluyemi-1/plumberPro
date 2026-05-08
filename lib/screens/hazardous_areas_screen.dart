import 'package:flutter/material.dart';

import '../data/hazardous_areas_data.dart';
import '../services/tts_service.dart';
import '../theme.dart';

/// Browseable IGEM/UP/16 hazardous area reference with two tabs:
///   1. Zones — the four classification categories.
///   2. Locations — searchable list of typical installation features and
///      the zone in which they sit.
class HazardousAreasScreen extends StatefulWidget {
  const HazardousAreasScreen({super.key});

  @override
  State<HazardousAreasScreen> createState() => _HazardousAreasScreenState();
}

class _HazardousAreasScreenState extends State<HazardousAreasScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    TtsService.instance.stop();
    super.dispose();
  }

  HazardousZone _zoneFor(String label) {
    return hazardousZones.firstWhere(
      (z) => z.label == label,
      orElse: () => hazardousZones.last,
    );
  }

  List<HazardLocation> get _filteredLocations {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return typicalLocations;
    return typicalLocations
        .where((l) =>
            l.label.toLowerCase().contains(q) ||
            l.zone.toLowerCase().contains(q) ||
            l.reasoning.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBg,
      appBar: AppBar(
        title: const Text('Hazardous areas (IGEM/UP/16)'),
        bottom: TabBar(
          controller: _tab,
          indicatorColor: AppColors.accent,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Zones', icon: Icon(Icons.layers_outlined)),
            Tab(text: 'Locations', icon: Icon(Icons.place_outlined)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _buildZonesTab(),
          _buildLocationsTab(),
        ],
      ),
    );
  }

  Widget _buildZonesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: hazardousZones.length,
      itemBuilder: (_, i) => _ZoneCard(zone: hazardousZones[i]),
    );
  }

  Widget _buildLocationsTab() {
    final results = _filteredLocations;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: TextField(
            onChanged: (v) => setState(() => _query = v),
            style: const TextStyle(color: AppColors.text),
            decoration: InputDecoration(
              hintText: 'Search a location, e.g. relief, meter, cabinet',
              hintStyle: const TextStyle(color: AppColors.muted),
              prefixIcon: const Icon(Icons.search, color: AppColors.muted),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Expanded(
          child: results.isEmpty
              ? const Center(
                  child: Text(
                    'No matching locations',
                    style: TextStyle(color: AppColors.muted),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  itemCount: results.length,
                  itemBuilder: (_, i) {
                    final loc = results[i];
                    final zone = _zoneFor(loc.zone);
                    return _LocationCard(
                      location: loc,
                      zone: zone,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                _LocationDetailScreen(location: loc, zone: zone),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _ZoneCard extends StatelessWidget {
  final HazardousZone zone;
  const _ZoneCard({required this.zone});

  @override
  Widget build(BuildContext context) {
    final colour = Color(zone.colourArgb);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 10, color: colour),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: colour.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: colour.withValues(alpha: 0.6),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            zone.label,
                            style: TextStyle(
                              color: colour,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          tooltip: 'Speak this zone',
                          icon: const Icon(Icons.volume_up,
                              color: AppColors.primary),
                          onPressed: () =>
                              TtsService.instance.speak(zone.speakable),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _Section(title: 'Definition', body: zone.definition),
                    const SizedBox(height: 10),
                    _Section(title: 'Typical examples', body: zone.examples),
                    const SizedBox(height: 10),
                    _Section(
                        title: 'Required equipment', body: zone.equipment),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  final HazardLocation location;
  final HazardousZone zone;
  final VoidCallback onTap;
  const _LocationCard({
    required this.location,
    required this.zone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colour = Color(zone.colourArgb);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      location.label,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: colour.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: colour.withValues(alpha: 0.7),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      zone.label,
                      style: TextStyle(
                        color: colour,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(location.reasoning,
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () => TtsService.instance.speak(
                      '${location.label}. ${zone.label}. ${location.reasoning}',
                    ),
                    icon: const Icon(Icons.volume_up),
                    label: const Text('Speak'),
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right, color: AppColors.muted),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocationDetailScreen extends StatelessWidget {
  final HazardLocation location;
  final HazardousZone zone;
  const _LocationDetailScreen({required this.location, required this.zone});

  @override
  Widget build(BuildContext context) {
    final colour = Color(zone.colourArgb);
    return Scaffold(
      backgroundColor: AppColors.cardBg,
      appBar: AppBar(
        title: const Text('Location detail'),
        actions: [
          IconButton(
            tooltip: 'Speak',
            icon: const Icon(Icons.volume_up),
            onPressed: () => TtsService.instance.speak(
              '${location.label}. ${zone.speakable} Reasoning. ${location.reasoning}',
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(location.label,
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: colour.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: colour.withValues(alpha: 0.7),
                      ),
                    ),
                    child: Text(
                      zone.label,
                      style: TextStyle(
                        color: colour,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _Section(title: 'Reasoning', body: location.reasoning),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            clipBehavior: Clip.antiAlias,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(width: 10, color: colour),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('About ${zone.label}',
                              style:
                                  Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          _Section(
                              title: 'Definition', body: zone.definition),
                          const SizedBox(height: 8),
                          _Section(
                              title: 'Typical examples', body: zone.examples),
                          const SizedBox(height: 8),
                          _Section(
                              title: 'Required equipment',
                              body: zone.equipment),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String body;
  const _Section({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
            color: AppColors.muted,
          ),
        ),
        const SizedBox(height: 2),
        Text(body, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
