import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../data/account.dart';
import '../../data/otpauth_uri.dart';
import '../../l10n/app_localizations.dart';
import '../app_theme.dart';
import 'add_account_flow.dart';

/// Reads an `otpauth://` QR with the camera and returns the parsed
/// [Account] to the caller.
///
/// Visuals follow the Samsung scanner: no closed box, just four wide
/// corner brackets. They animate inward on open, breathe gently while
/// scanning (no sweeping line), and snap shut on a hit.
class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> with TickerProviderStateMixin {
  final _controller = MobileScannerController();

  late final AnimationController _intro;
  late final AnimationController _pulse;
  late final AnimationController _lock;

  Account? _detected;
  bool _torchOn = false;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );
    _lock = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );

    _intro.forward().whenCompleteOrCancel(() {
      if (mounted && _detected == null) _pulse.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _intro.dispose();
    _pulse.dispose();
    _lock.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_detected != null) return;
    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue;
      if (raw == null) continue;
      try {
        final account =
            OtpAuthUri.parse(raw, id: AddAccountFlow.newAccountId());
        _detected = account;
        _pulse.stop();
        _lock.forward().whenComplete(() {
          if (mounted) Navigator.of(context).pop(account);
        });
        return;
      } on FormatException {
        // Non-otpauth QR: ignore and keep scanning.
      }
    }
  }

  Future<void> _toggleTorch() async {
    await _controller.toggleTorch();
    if (mounted) setState(() => _torchOn = !_torchOn);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = AppPalette.of(context);
    final media = MediaQuery.of(context);

    final side =
        (media.size.shortestSide * 0.68).clamp(220.0, 300.0).toDouble();
    final restingFrame = Rect.fromCenter(
      center: Offset(
        media.size.width / 2,
        media.size.height / 2 - media.padding.top / 2,
      ),
      width: side,
      height: side,
    );
    // The brackets start spread out and converge onto the resting frame.
    final openFrame = restingFrame.inflate(side * 0.22);

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text(l10n.addScanTitle),
        actions: [
          IconButton(
            onPressed: _toggleTorch,
            icon: Icon(_torchOn
                ? Icons.flash_on_rounded
                : Icons.flash_off_rounded),
            tooltip: 'Flash',
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: MobileScanner(
              controller: _controller,
              onDetect: _onDetect,
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: Listenable.merge([_intro, _pulse, _lock]),
                builder: (context, _) {
                  return CustomPaint(
                    painter: _CornerBracketsPainter(
                      frame: _currentFrame(restingFrame, openFrame),
                      color: palette.ring,
                      opacity: _currentOpacity(),
                    ),
                  );
                },
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            top: restingFrame.bottom + 36,
            child: Center(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _detected == null ? 1 : 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    l10n.scanInstruction,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Rect _currentFrame(Rect resting, Rect open) {
    if (_detected != null) {
      // Snap shut on a successful read.
      final t = Curves.easeInBack.transform(_lock.value).clamp(0.0, 1.0);
      return Rect.lerp(resting, resting.deflate(resting.width * 0.16), t)!;
    }
    if (_intro.status != AnimationStatus.completed) {
      final t = Curves.easeOutCubic.transform(_intro.value);
      return Rect.lerp(open, resting, t)!;
    }
    // Subtle breathing while scanning — no moving line.
    final p = Curves.easeInOut.transform(_pulse.value);
    return resting.inflate(p * 7);
  }

  double _currentOpacity() {
    if (_detected != null) return 1 - _lock.value;
    if (_intro.status != AnimationStatus.completed) {
      return Curves.easeOut.transform(_intro.value);
    }
    return 0.78 + 0.22 * Curves.easeInOut.transform(_pulse.value);
  }
}

/// Draws only four wide rounded corner brackets (no enclosing box).
class _CornerBracketsPainter extends CustomPainter {
  _CornerBracketsPainter({
    required this.frame,
    required this.color,
    required this.opacity,
  });

  final Rect frame;
  final Color color;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    // A faint, uniform scrim keeps the brackets readable without boxing
    // the camera in.
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = Colors.black.withValues(alpha: 0.18),
    );

    final arm = frame.width * 0.16;
    final radius = frame.width * 0.10;
    final paint = Paint()
      ..color = color.withValues(alpha: opacity.clamp(0.0, 1.0))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    void corner(Offset c, double sx, double sy) {
      canvas.drawPath(
        Path()
          ..moveTo(c.dx, c.dy + sy * arm)
          ..lineTo(c.dx, c.dy + sy * radius)
          // Control point at the exact vertex rounds the elbow correctly
          // for every corner orientation.
          ..quadraticBezierTo(
            c.dx,
            c.dy,
            c.dx + sx * radius,
            c.dy,
          )
          ..lineTo(c.dx + sx * arm, c.dy),
        paint,
      );
    }

    corner(frame.topLeft, 1, 1);
    corner(frame.topRight, -1, 1);
    corner(frame.bottomLeft, 1, -1);
    corner(frame.bottomRight, -1, -1);
  }

  @override
  bool shouldRepaint(_CornerBracketsPainter old) =>
      old.frame != frame ||
      old.color != color ||
      old.opacity != opacity;
}
