import 'package:flutter/material.dart';
import '../services/license_service.dart';
import '../theme/app_colors.dart';
import '../widgets/larc_logo.dart';

class LicenseGate extends StatefulWidget {
  const LicenseGate({super.key, required this.child});
  final Widget child;

  @override
  State<LicenseGate> createState() => _LicenseGateState();
}

class _LicenseGateState extends State<LicenseGate> {
  final _controller = TextEditingController();
  bool _checking = true;
  bool _licensed = false;
  bool _activating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final valid = await LicenseService.validate();
    if (!mounted) return;
    setState(() {
      _checking = false;
      _licensed = valid;
    });
  }

  Future<void> _activate() async {
    final key = _controller.text.trim();
    if (key.isEmpty) {
      setState(() => _error = 'Enter your FITIN license key.');
      return;
    }
    setState(() {
      _activating = true;
      _error = null;
    });
    try {
      await LicenseService.activate(key);
      final valid = await LicenseService.validate();
      if (!mounted) return;
      setState(() {
        _licensed = valid;
        _activating = false;
        if (!valid) _error = 'Activation could not be verified.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _activating = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        backgroundColor: AppColors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_licensed) return widget.child;

    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const LarcLogo(size: 120),
                  const SizedBox(height: 22),
                  const Text(
                    'Activate FITIN',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This installation must be licensed before FITIN can be used.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _controller,
                    autocorrect: false,
                    textCapitalization: TextCapitalization.characters,
                    style: const TextStyle(color: AppColors.white),
                    decoration: const InputDecoration(
                      labelText: 'License key',
                      hintText: 'FITIN-XXXXXX-XXXXXX-XXXXXX-XXXXXX',
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _activating ? null : _activate,
                      child: _activating
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Activate'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
