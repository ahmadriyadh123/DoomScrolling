import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    runApp(const SocialCounterApp());
  });
}

class SocialCounterApp extends StatelessWidget {
  const SocialCounterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Social Media Counter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SocialCounterHome(),
    );
  }
}

class SocialCounterHome extends StatefulWidget {
  const SocialCounterHome({super.key});

  @override
  State<SocialCounterHome> createState() => _SocialCounterHomeState();
}

class _SocialCounterHomeState extends State<SocialCounterHome> {
  int _instagramCount = 0;
  int _tikTokCount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/hp');
      if (await file.exists()) {
        final contents = await file.readAsString();
        final parts = contents.split(',');
        if (parts.length == 2) {
          setState(() {
            _instagramCount = int.parse(parts[0]);
            _tikTokCount = int.parse(parts[1]);
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
    }
  }

  Future<void> _saveData() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/hp');
      await file.writeAsString('$_instagramCount,$_tikTokCount');
    } catch (e) {
      debugPrint('Error saving data: $e');
    }
  }

  void _incrementInstagram() {
    setState(() {
      _instagramCount++;
    });
    _saveData();
  }

  void _incrementTikTok() {
    setState(() {
      _tikTokCount++;
    });
    _saveData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Instagram Side (Left)
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF833AB4), // Purple
                    Color(0xFFFD1D1D), // Red
                    Color(0xFFFCAF45), // Orange
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: ScaleButton(
                onTap: _incrementInstagram,
                child: SizedBox.expand(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0), // Padding to avoid edge clipping
                    child: Image.asset(
                      'assets/instagram-logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // TikTok Side (Right)
          Expanded(
            child: Container(
              color: Colors.black,
              child: ScaleButton(
                onTap: _incrementTikTok,
                child: SizedBox.expand(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0), // Padding to avoid edge clipping
                    child: Image.asset(
                      'assets/tiktok-logo.png',
                      fit: BoxFit.contain,
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
}

class ScaleButton extends StatefulWidget {
  final VoidCallback onTap;
  final Widget child;
  final Duration duration;
  final double scale;

  const ScaleButton({
    super.key,
    required this.onTap,
    required this.child,
    this.duration = const Duration(milliseconds: 100),
    this.scale = 0.9,
  });

  @override
  State<ScaleButton> createState() => _ScaleButtonState();
}

class _ScaleButtonState extends State<ScaleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.scale).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque, // Ensures the entire area is consistently tappable
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}
