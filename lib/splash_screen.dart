import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'main_shell.dart';
import 'services/sync_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late final AnimationController _controller;
  final SyncService _sync = SyncService();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _init();
  }

  Future<void> _init() async {
    try {
      await _sync.syncAll(); // 🔥 FIRST SYNC ON START
    } catch (_) {
      // offline? ignore
    }

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainShell()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = Tween<double>(begin: 0.85, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF1976D2),
      body: Center(
        child: FadeTransition(
          opacity: _controller,
          child: ScaleTransition(
            scale: scale,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/images/sudanrx_logo.svg',
                  width: 160,
                  height: 160,
                ),
                const SizedBox(height: 28),
                const Text('SudanRx',
                    style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: Colors.white)),
                const SizedBox(height: 10),
                const CircularProgressIndicator(color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}