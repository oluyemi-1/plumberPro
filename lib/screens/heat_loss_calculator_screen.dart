import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/heat_pump_data.dart';
import '../services/tts_service.dart';
import '../theme.dart';

class HeatLossCalculatorScreen extends StatefulWidget {
  const HeatLossCalculatorScreen({super.key});

  @override
  State<HeatLossCalculatorScreen> createState() =>
      _HeatLossCalculatorScreenState();
}

/// In-memory model for one room's input.
class _Room {
  String name;
  String type;
  double length;
  double width;
  double height;
  double designIndoor;
  double airChanges;
  double extWallArea;
  double extWallU;
  double windowArea;
  double windowU;
  double roofArea;
  double roofU;
  double floorArea;
  double floorU;
  double doorArea;
  double doorU;

  _Room({
    required this.name,
    required this.type,
    required this.length,
    required this.width,
    required this.height,
    required this.designIndoor,
    required this.airChanges,
    required this.extWallArea,
    required this.extWallU,
    required this.windowArea,
    required this.windowU,
    required this.roofArea,
    required this.roofU,
    required this.floorArea,
    required this.floorU,
    required this.doorArea,
    required this.doorU,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'type': type,
        'length': length,
        'width': width,
        'height': height,
        'designIndoor': designIndoor,
        'airChanges': airChanges,
        'extWallArea': extWallArea,
        'extWallU': extWallU,
        'windowArea': windowArea,
        'windowU': windowU,
        'roofArea': roofArea,
        'roofU': roofU,
        'floorArea': floorArea,
        'floorU': floorU,
        'doorArea': doorArea,
        'doorU': doorU,
      };

  factory _Room.fromJson(Map<String, dynamic> j) => _Room(
        name: j['name'] as String? ?? 'Room',
        type: j['type'] as String? ?? 'Lounge / living',
        length: (j['length'] as num?)?.toDouble() ?? 4,
        width: (j['width'] as num?)?.toDouble() ?? 4,
        height: (j['height'] as num?)?.toDouble() ?? 2.4,
        designIndoor: (j['designIndoor'] as num?)?.toDouble() ?? 21,
        airChanges: (j['airChanges'] as num?)?.toDouble() ?? 1.5,
        extWallArea: (j['extWallArea'] as num?)?.toDouble() ?? 10,
        extWallU: (j['extWallU'] as num?)?.toDouble() ?? 1.6,
        windowArea: (j['windowArea'] as num?)?.toDouble() ?? 2.5,
        windowU: (j['windowU'] as num?)?.toDouble() ?? 1.4,
        roofArea: (j['roofArea'] as num?)?.toDouble() ?? 0,
        roofU: (j['roofU'] as num?)?.toDouble() ?? 0.16,
        floorArea: (j['floorArea'] as num?)?.toDouble() ?? 0,
        floorU: (j['floorU'] as num?)?.toDouble() ?? 0.40,
        doorArea: (j['doorArea'] as num?)?.toDouble() ?? 0,
        doorU: (j['doorU'] as num?)?.toDouble() ?? 1.4,
      );

  double get volume => length * width * height;

  /// Returns heat loss in watts for this room given the OAT.
  double heatLoss(double designOAT) {
    final dt = designIndoor - designOAT;
    final fabric = extWallArea * extWallU +
        windowArea * windowU +
        roofArea * roofU +
        floorArea * floorU +
        doorArea * doorU;
    final fabricLossW = fabric * dt;
    final airLossW = volume * airChanges * 0.33 * dt;
    return fabricLossW + airLossW;
  }
}

class _HeatLossCalculatorScreenState extends State<HeatLossCalculatorScreen> {
  static const _kRoomsKey = 'heat_loss_rooms_v1';
  static const _kOATKey = 'heat_loss_oat_v1';
  static const _kRegionKey = 'heat_loss_region_v1';

  final List<_Room> _rooms = [];
  double _oat = -2;
  String _region = 'London / South East';
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kRoomsKey);
    if (raw != null) {
      try {
        final list = (jsonDecode(raw) as List)
            .cast<Map<String, dynamic>>()
            .map(_Room.fromJson)
            .toList();
        _rooms.addAll(list);
      } catch (_) {}
    }
    _oat = prefs.getDouble(_kOATKey) ?? -2;
    _region = prefs.getString(_kRegionKey) ?? 'London / South East';
    if (mounted) setState(() => _loaded = true);
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _kRoomsKey, jsonEncode(_rooms.map((r) => r.toJson()).toList()));
    await prefs.setDouble(_kOATKey, _oat);
    await prefs.setString(_kRegionKey, _region);
  }

  Future<void> _addRoom() async {
    final preset = roomTypes.first;
    final r = _Room(
      name: 'Room ${_rooms.length + 1}',
      type: preset.label,
      length: 4,
      width: 4,
      height: 2.4,
      designIndoor: preset.designTemp,
      airChanges: preset.airChangesPerHour,
      extWallArea: 10,
      extWallU: 1.6,
      windowArea: 2.5,
      windowU: 1.4,
      roofArea: 0,
      roofU: 0.16,
      floorArea: 0,
      floorU: 0.40,
      doorArea: 0,
      doorU: 1.4,
    );
    final updated = await Navigator.push<_Room?>(
      context,
      MaterialPageRoute(builder: (_) => _RoomEditorScreen(room: r)),
    );
    if (updated != null) {
      setState(() => _rooms.add(updated));
      await _save();
    }
  }

  Future<void> _editRoom(int index) async {
    final updated = await Navigator.push<_Room?>(
      context,
      MaterialPageRoute(builder: (_) => _RoomEditorScreen(room: _rooms[index])),
    );
    if (updated != null) {
      setState(() => _rooms[index] = updated);
      await _save();
    }
  }

  Future<void> _deleteRoom(int index) async {
    setState(() => _rooms.removeAt(index));
    await _save();
  }

  Future<void> _resetAll() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear all rooms?'),
        content: const Text('Removes every room from this heat loss design.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Clear')),
        ],
      ),
    );
    if (ok == true) {
      setState(() => _rooms.clear());
      await _save();
    }
  }

  double get _totalKw =>
      _rooms.fold<double>(0, (a, r) => a + r.heatLoss(_oat)) / 1000.0;

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Heat loss calculator'),
        actions: [
          IconButton(
            tooltip: 'Speak summary',
            icon: const Icon(Icons.record_voice_over),
            onPressed: _speakSummary,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (v) {
              if (v == 'reset') _resetAll();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'reset', child: Text('Reset rooms')),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          _DesignBanner(
            region: _region,
            oat: _oat,
            totalKw: _totalKw,
            roomCount: _rooms.length,
            onRegion: (r) {
              final preset = designOATs.firstWhere(
                (d) => d.region == r,
                orElse: () => designOATs.first,
              );
              setState(() {
                _region = preset.region;
                _oat = preset.oat;
              });
              _save();
            },
            onOat: (v) {
              setState(() => _oat = v);
              _save();
            },
          ),
          const SizedBox(height: 12),
          if (_rooms.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(Icons.add_home_work,
                        size: 56, color: AppColors.primary),
                    const SizedBox(height: 8),
                    Text('No rooms yet',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 6),
                    Text(
                      'Add a room to start a room-by-room heat loss design.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            )
          else
            ..._rooms.asMap().entries.map((e) {
              return _RoomCard(
                room: e.value,
                designOAT: _oat,
                onEdit: () => _editRoom(e.key),
                onDelete: () => _deleteRoom(e.key),
              );
            }),
          const SizedBox(height: 12),
          if (_rooms.isNotEmpty) _SizingPreview(totalKw: _totalKw),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addRoom,
        icon: const Icon(Icons.add),
        label: const Text('Add room'),
      ),
    );
  }

  void _speakSummary() {
    if (_rooms.isEmpty) {
      TtsService.instance
          .speak('No rooms have been added yet. Tap the plus button to begin.');
      return;
    }
    final perRoom = _rooms.map((r) {
      final w = r.heatLoss(_oat).round();
      return '${r.name} ${(r.heatLoss(_oat) / 1000).toStringAsFixed(2)} kilowatts. That is $w watts.';
    }).join(' ');
    final total = _totalKw.toStringAsFixed(2);
    TtsService.instance.speak(
        'Heat loss summary at design outside temperature ${_oat.toStringAsFixed(0)} degrees. $perRoom Total design heat loss is $total kilowatts.');
  }
}

class _DesignBanner extends StatelessWidget {
  final String region;
  final double oat;
  final double totalKw;
  final int roomCount;
  final ValueChanged<String> onRegion;
  final ValueChanged<double> onOat;
  const _DesignBanner({
    required this.region,
    required this.oat,
    required this.totalKw,
    required this.roomCount,
    required this.onRegion,
    required this.onOat,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.primary.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.thermostat, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('Design conditions',
                  style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              Text('$roomCount room${roomCount == 1 ? '' : 's'}',
                  style: Theme.of(context).textTheme.bodySmall),
            ]),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: region,
              isDense: true,
              decoration: const InputDecoration(
                labelText: 'Region (CIBSE design OAT)',
                border: OutlineInputBorder(),
              ),
              items: designOATs
                  .map((d) => DropdownMenuItem(
                        value: d.region,
                        child:
                            Text('${d.region} (${d.oat.toStringAsFixed(1)}°C)'),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) onRegion(v);
              },
            ),
            const SizedBox(height: 10),
            Row(children: [
              Text('Design OAT', style: Theme.of(context).textTheme.bodyMedium),
              Expanded(
                child: Slider(
                  value: oat,
                  min: -10,
                  max: 5,
                  divisions: 30,
                  label: '${oat.toStringAsFixed(1)} °C',
                  onChanged: onOat,
                ),
              ),
              SizedBox(
                width: 60,
                child: Text('${oat.toStringAsFixed(1)} °C',
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
            ]),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.summarize, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Total design heat loss',
                        style:
                            Theme.of(context).textTheme.titleMedium),
                  ),
                  Text('${totalKw.toStringAsFixed(2)} kW',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  final _Room room;
  final double designOAT;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _RoomCard({
    required this.room,
    required this.designOAT,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final loss = room.heatLoss(designOAT);
    return Card(
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(room.name,
                        style: Theme.of(context).textTheme.titleMedium),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: AppColors.muted),
                    onPressed: onDelete,
                  ),
                ],
              ),
              Text(
                '${room.type} · ${room.length.toStringAsFixed(1)} × ${room.width.toStringAsFixed(1)} × ${room.height.toStringAsFixed(2)} m · ${room.designIndoor.toStringAsFixed(0)} °C',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Row(children: [
                _Metric(
                    label: 'Volume',
                    value: '${room.volume.toStringAsFixed(1)} m³'),
                const SizedBox(width: 12),
                _Metric(
                    label: 'ACH',
                    value: room.airChanges.toStringAsFixed(1)),
                const SizedBox(width: 12),
                _Metric(
                  label: 'Heat loss',
                  value: '${loss.toStringAsFixed(0)} W',
                  highlight: true,
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;
  const _Metric({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.accent.withValues(alpha: 0.12)
            : AppColors.cardBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 10, color: AppColors.muted)),
          Text(value,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: highlight ? AppColors.accent : AppColors.text,
                fontSize: 14,
              )),
        ],
      ),
    );
  }
}

class _SizingPreview extends StatelessWidget {
  final double totalKw;
  const _SizingPreview({required this.totalKw});

  @override
  Widget build(BuildContext context) {
    final s = sizeHeatPump(heatLossKw: totalKw, occupants: 4);
    return Card(
      color: AppColors.accent.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.heat_pump, color: AppColors.accent),
              const SizedBox(width: 8),
              Text('Suggested heat pump capacity',
                  style: Theme.of(context).textTheme.titleMedium),
            ]),
            const SizedBox(height: 8),
            Text(
              'Heat loss ${s.designHeatLossKw.toStringAsFixed(2)} kW · DHW allowance ${s.dhwAllowanceKw.toStringAsFixed(1)} kW',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Recommended capacity ${s.recommendedCapacityKw.toStringAsFixed(1)} kW — band ${s.capacityBand}',
              style: const TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoomEditorScreen extends StatefulWidget {
  final _Room room;
  const _RoomEditorScreen({required this.room});

  @override
  State<_RoomEditorScreen> createState() => _RoomEditorScreenState();
}

class _RoomEditorScreenState extends State<_RoomEditorScreen> {
  late _Room _room;
  late TextEditingController _name;
  late TextEditingController _length;
  late TextEditingController _width;
  late TextEditingController _height;
  late TextEditingController _extWallArea;
  late TextEditingController _windowArea;
  late TextEditingController _roofArea;
  late TextEditingController _floorArea;
  late TextEditingController _doorArea;

  @override
  void initState() {
    super.initState();
    _room = _Room(
      name: widget.room.name,
      type: widget.room.type,
      length: widget.room.length,
      width: widget.room.width,
      height: widget.room.height,
      designIndoor: widget.room.designIndoor,
      airChanges: widget.room.airChanges,
      extWallArea: widget.room.extWallArea,
      extWallU: widget.room.extWallU,
      windowArea: widget.room.windowArea,
      windowU: widget.room.windowU,
      roofArea: widget.room.roofArea,
      roofU: widget.room.roofU,
      floorArea: widget.room.floorArea,
      floorU: widget.room.floorU,
      doorArea: widget.room.doorArea,
      doorU: widget.room.doorU,
    );
    _name = TextEditingController(text: _room.name);
    _length = TextEditingController(text: _room.length.toString());
    _width = TextEditingController(text: _room.width.toString());
    _height = TextEditingController(text: _room.height.toString());
    _extWallArea = TextEditingController(text: _room.extWallArea.toString());
    _windowArea = TextEditingController(text: _room.windowArea.toString());
    _roofArea = TextEditingController(text: _room.roofArea.toString());
    _floorArea = TextEditingController(text: _room.floorArea.toString());
    _doorArea = TextEditingController(text: _room.doorArea.toString());
  }

  @override
  void dispose() {
    _name.dispose();
    _length.dispose();
    _width.dispose();
    _height.dispose();
    _extWallArea.dispose();
    _windowArea.dispose();
    _roofArea.dispose();
    _floorArea.dispose();
    _doorArea.dispose();
    super.dispose();
  }

  void _commit() {
    _room.name = _name.text.trim().isEmpty ? 'Room' : _name.text.trim();
    _room.length = double.tryParse(_length.text) ?? _room.length;
    _room.width = double.tryParse(_width.text) ?? _room.width;
    _room.height = double.tryParse(_height.text) ?? _room.height;
    _room.extWallArea =
        double.tryParse(_extWallArea.text) ?? _room.extWallArea;
    _room.windowArea = double.tryParse(_windowArea.text) ?? _room.windowArea;
    _room.roofArea = double.tryParse(_roofArea.text) ?? _room.roofArea;
    _room.floorArea = double.tryParse(_floorArea.text) ?? _room.floorArea;
    _room.doorArea = double.tryParse(_doorArea.text) ?? _room.doorArea;
    Navigator.pop(context, _room);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit room'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: 'Save room',
            onPressed: _commit,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          _section('Identity'),
          TextField(
            controller: _name,
            decoration: const InputDecoration(
              labelText: 'Room name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: _room.type,
            decoration: const InputDecoration(
              labelText: 'Room type',
              border: OutlineInputBorder(),
            ),
            items: roomTypes
                .map((t) => DropdownMenuItem(
                      value: t.label,
                      child: Text(
                          '${t.label} — ${t.designTemp.toStringAsFixed(0)} °C, ACH ${t.airChangesPerHour.toStringAsFixed(1)}'),
                    ))
                .toList(),
            onChanged: (v) {
              if (v == null) return;
              final preset = roomTypes.firstWhere((t) => t.label == v);
              setState(() {
                _room.type = preset.label;
                _room.designIndoor = preset.designTemp;
                _room.airChanges = preset.airChangesPerHour;
              });
            },
          ),
          const SizedBox(height: 16),
          _section('Dimensions (metres)'),
          Row(children: [
            Expanded(
                child: _numberField('Length', _length,
                    onChange: (v) => _room.length = v)),
            const SizedBox(width: 8),
            Expanded(
                child: _numberField('Width', _width,
                    onChange: (v) => _room.width = v)),
            const SizedBox(width: 8),
            Expanded(
                child: _numberField('Height', _height,
                    onChange: (v) => _room.height = v)),
          ]),
          const SizedBox(height: 8),
          _DesignSliders(
            indoor: _room.designIndoor,
            airChanges: _room.airChanges,
            onIndoor: (v) => setState(() => _room.designIndoor = v),
            onAch: (v) => setState(() => _room.airChanges = v),
          ),
          const SizedBox(height: 16),
          _section('External walls'),
          _numberField('Exposed wall area (m²)', _extWallArea,
              onChange: (v) => _room.extWallArea = v),
          _UPicker(
            label: 'Wall U-value',
            options: wallUValues,
            value: _room.extWallU,
            onChange: (v) => setState(() => _room.extWallU = v),
          ),
          const SizedBox(height: 16),
          _section('Glazing'),
          _numberField('Window area (m²)', _windowArea,
              onChange: (v) => _room.windowArea = v),
          _UPicker(
            label: 'Window U-value',
            options: windowUValues,
            value: _room.windowU,
            onChange: (v) => setState(() => _room.windowU = v),
          ),
          const SizedBox(height: 16),
          _section('Roof / ceiling'),
          _numberField('Exposed roof area (m²)', _roofArea,
              onChange: (v) => _room.roofArea = v,
              hint: 'Use 0 if room is below an unheated room rather than the roof'),
          _UPicker(
            label: 'Roof U-value',
            options: roofUValues,
            value: _room.roofU,
            onChange: (v) => setState(() => _room.roofU = v),
          ),
          const SizedBox(height: 16),
          _section('Ground floor'),
          _numberField('Exposed floor area (m²)', _floorArea,
              onChange: (v) => _room.floorArea = v,
              hint: 'Use 0 if floor is over a heated room'),
          _UPicker(
            label: 'Floor U-value',
            options: floorUValues,
            value: _room.floorU,
            onChange: (v) => setState(() => _room.floorU = v),
          ),
          const SizedBox(height: 16),
          _section('Doors'),
          _numberField('External door area (m²)', _doorArea,
              onChange: (v) => _room.doorArea = v),
          _UPicker(
            label: 'Door U-value',
            options: doorUValues,
            value: _room.doorU,
            onChange: (v) => setState(() => _room.doorU = v),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _commit,
            icon: const Icon(Icons.check),
            label: const Text('Save room'),
          ),
        ],
      ),
    );
  }

  Widget _section(String s) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(s, style: Theme.of(context).textTheme.titleMedium),
      );

  Widget _numberField(
    String label,
    TextEditingController c, {
    String? hint,
    required void Function(double) onChange,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: c,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
        ],
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          helperText: hint,
          border: const OutlineInputBorder(),
        ),
        onChanged: (s) {
          final v = double.tryParse(s);
          if (v != null) onChange(v);
        },
      ),
    );
  }
}

class _DesignSliders extends StatelessWidget {
  final double indoor;
  final double airChanges;
  final ValueChanged<double> onIndoor;
  final ValueChanged<double> onAch;
  const _DesignSliders({
    required this.indoor,
    required this.airChanges,
    required this.onIndoor,
    required this.onAch,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(children: [
          Text('Indoor design ',
              style: Theme.of(context).textTheme.bodyMedium),
          Expanded(
            child: Slider(
              value: indoor.clamp(15.0, 24.0),
              min: 15,
              max: 24,
              divisions: 9,
              label: '${indoor.toStringAsFixed(0)} °C',
              onChanged: onIndoor,
            ),
          ),
          SizedBox(
            width: 60,
            child: Text('${indoor.toStringAsFixed(0)} °C',
                textAlign: TextAlign.right,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ]),
        Row(children: [
          Text('Air changes ',
              style: Theme.of(context).textTheme.bodyMedium),
          Expanded(
            child: Slider(
              value: airChanges.clamp(0.5, 4.0),
              min: 0.5,
              max: 4,
              divisions: 14,
              label: airChanges.toStringAsFixed(1),
              onChanged: onAch,
            ),
          ),
          SizedBox(
            width: 60,
            child: Text(airChanges.toStringAsFixed(1),
                textAlign: TextAlign.right,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ]),
      ],
    );
  }
}

class _UPicker extends StatelessWidget {
  final String label;
  final List<UValuePreset> options;
  final double value;
  final ValueChanged<double> onChange;
  const _UPicker({
    required this.label,
    required this.options,
    required this.value,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    final match = options.firstWhere(
      (o) => (o.uValue - value).abs() < 0.01,
      orElse: () => UValuePreset('Custom: ${value.toStringAsFixed(2)}', value),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: DropdownButtonFormField<String>(
        initialValue: match.label,
        isDense: true,
        decoration: InputDecoration(
          labelText: '$label (W/m²·K)',
          border: const OutlineInputBorder(),
        ),
        items: options
            .map((o) => DropdownMenuItem(
                  value: o.label,
                  child: Text('${o.label} — ${o.uValue.toStringAsFixed(2)}'),
                ))
            .toList(),
        onChanged: (v) {
          if (v == null) return;
          final picked = options.firstWhere((o) => o.label == v);
          onChange(picked.uValue);
        },
      ),
    );
  }
}
