import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:aakashvani/features/admin/presentation/admin_provider.dart';

class ZoneEditorScreen extends ConsumerStatefulWidget {
  final String? zoneId;
  const ZoneEditorScreen({super.key, this.zoneId});

  @override
  ConsumerState<ZoneEditorScreen> createState() =>
      _ZoneEditorScreenState();
}

class _ZoneEditorScreenState extends ConsumerState<ZoneEditorScreen> {
  final _nameCtrl = TextEditingController();
  double _volume = 70;
  bool _saving = false, _deleting = false, _loaded = false;

  bool get isNew => widget.zoneId == null;

  void _load() {
    if (_loaded || isNew) return;
    final zones = ref.read(adminZonesProvider).value ?? [];
    final z =
        zones.where((z) => z.id == widget.zoneId).firstOrNull;
    if (z != null) {
      _nameCtrl.text = z.name;
      _volume = z.defaultVolume.toDouble();
      _loaded = true;
    }
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() => _saving = true);
    try {
      final repo = ref.read(adminRepositoryProvider);
      if (isNew) {
        await repo.createZone(
            name: name, defaultVolume: _volume.round());
      } else {
        await repo.updateZone(widget.zoneId!,
            name: name, defaultVolume: _volume.round());
      }
      ref.invalidate(adminZonesProvider);
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Zone'),
        content: const Text(
            'All devices in this zone will become unassigned. This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style:
                FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _deleting = true);
    try {
      await ref
          .read(adminRepositoryProvider)
          .deleteZone(widget.zoneId!);
      ref.invalidate(adminZonesProvider);
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _load();
    return Scaffold(
      appBar: AppBar(
        title: Text(isNew ? 'New Zone' : 'Edit Zone'),
        actions: [
          if (!isNew)
            IconButton(
              icon: _deleting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.delete_outline_rounded),
              onPressed: _deleting ? null : _delete,
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
                labelText: 'Zone Name', border: OutlineInputBorder()),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 20),
          Text('Default Volume',
              style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 4),
          Row(children: [
            const Icon(Icons.volume_down_rounded, size: 20),
            Expanded(
              child: Slider(
                value: _volume,
                min: 0,
                max: 100,
                divisions: 20,
                label: '${_volume.round()}%',
                onChanged: (v) => setState(() => _volume = v),
              ),
            ),
            const Icon(Icons.volume_up_rounded, size: 20),
            const SizedBox(width: 8),
            Text('${_volume.round()}%'),
          ]),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: (_nameCtrl.text.isNotEmpty && !_saving)
                ? _save
                : null,
            style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50)),
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : Text(isNew ? 'Create Zone' : 'Save Changes'),
          ),
        ],
      ),
    );
  }
}
