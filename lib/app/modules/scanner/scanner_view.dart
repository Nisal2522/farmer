import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Full-screen QR / barcode scanner. Pops with the scanned value.
class ScannerView extends StatefulWidget {
  const ScannerView({super.key});

  @override
  State<ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView> {
  final _controller = MobileScannerController(detectionSpeed: DetectionSpeed.noDuplicates);
  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    final value = capture.barcodes.map((b) => b.rawValue).whereType<String>().firstOrNull;
    if (value == null || _handled) return;
    _handled = true;
    Get.back(result: value);
  }

  Future<void> _manualEntry() async {
    final ctrl = TextEditingController();
    final value = await Get.dialog<String>(
      AlertDialog(
        title: const Text('Enter seal number'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'e.g. 142321'),
          onSubmitted: (v) => Get.back(result: v.trim()),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Get.back(result: ctrl.text.trim()),
            child: const Text('Use'),
          ),
        ],
      ),
    );
    if (value != null && value.isNotEmpty) Get.back(result: value);
  }

  @override
  Widget build(BuildContext context) {
    const window = 260.0;
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text('Scan seal', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            tooltip: 'Flash',
            onPressed: _controller.toggleTorch,
            icon: const Icon(Icons.flashlight_on_rounded, color: Colors.white),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          // Dimmed overlay with a clear scan window.
          ColorFiltered(
            colorFilter: const ColorFilter.mode(Colors.black54, BlendMode.srcOut),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(color: Colors.transparent, backgroundBlendMode: BlendMode.dstOut),
                ),
                Center(
                  child: Container(
                    width: window,
                    height: window,
                    decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(28)),
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: Container(
              width: window,
              height: window,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white, width: 3),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Point the camera at the QR code on the seal',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white54),
                      ),
                      onPressed: _manualEntry,
                      icon: const Icon(Icons.keyboard_rounded),
                      label: const Text('Type it instead'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
