import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:aakashvani/domain/models/zone.dart';
import 'package:aakashvani/features/admin/presentation/admin_provider.dart';

class RegisterDeviceScreen extends ConsumerStatefulWidget {
  const RegisterDeviceScreen({super.key});

  @override
  ConsumerState<RegisterDeviceScreen> createState() =>
      _RegisterDeviceScreenState();
}

class _RegisterDeviceScreenState
    extends ConsumerState<RegisterDeviceScreen> {
  final _nameCtrl = TextEditingController();
  String _model = 'esp32';
  String? _zoneId;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _register(List<Zone> zones) async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty || _zoneId == null) return;
    setState(() => _saving = true);
    try {
      await ref.read(adminRepositoryProvider).registerDevice(
          name: name, zoneId: _zoneId!, model: _model);
      ref.invalidate(adminDevicesProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$name registered successfully')));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final zonesAsync = ref.watch(adminZonesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Register Device')),
      body: zonesAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (zones) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _StepHeader(step: '1', label: 'Device Info'),
            const SizedBox(height: 12),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Device Name',
                hintText: 'e.g. Hallway Speaker 3',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _model,
              decoration: const InputDecoration(
                  labelText: 'Model', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'esp32', child: Text('ESP32')),
                DropdownMenuItem(
                    value: 'esp8266', child: Text('ESP8266')),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _model = v);
              },
            ),
            const SizedBox(height: 20),
            const _StepHeader(step: '2', label: 'Assign Zone'),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _zoneId,
              decoration: const InputDecoration(
                  labelText: 'Zone', border: OutlineInputBorder()),
              items: zones
                  .map((z) =>
                      DropdownMenuItem(value: z.id, child: Text(z.name)))
                  .toList(),
              onChanged: (v) => setState(() => _zoneId = v),
              hint: const Text('Select a zone'),
            ),
            const SizedBox(height: 20),
            const _StepHeader(step: '3', label: 'Pair'),
            const SizedBox(height: 8),
            Text(
              'Ensure the device is powered on and in pairing mode (hold the BOOT button for 3 seconds).',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.outline,
                  fontSize: 13),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: (_nameCtrl.text.isNotEmpty &&
                      _zoneId != null &&
                      !_saving)
                  ? () => _register(zones)
                  : null,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.link_rounded),
              label: Text(_saving ? 'Registering…' : 'Pair & Register'),
              style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(50)),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepHeader extends StatelessWidget {
  final String step;
  final String label;
  const _StepHeader({required this.step, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(children: [
      Container(
        width: 24,
        height: 24,
        decoration:
            BoxDecoration(color: cs.primary, shape: BoxShape.circle),
        child: Center(
            child: Text(step,
                style: TextStyle(
                    color: cs.onPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold))),
      ),
      const SizedBox(width: 10),
      Text(label,
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.w700)),
    ]);
  }
}
