import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'storage/storage_adapter.dart';

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
  final StorageAdapter _storage = StorageAdapter();

  @override
  void initState() {
    super.initState();
    _initStorage();
  }

  Future<void> _initStorage() async {
    await _storage.init();
    final data = await _storage.loadData();
    setState(() {
      _instagramCount = data['instagram'] ?? 0;
      _tikTokCount = data['tiktok'] ?? 0;
    });
  }

  Future<void> _saveData() async {
    await _storage.saveData(_instagramCount, _tikTokCount);
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
              child: FeedbackButton(
                onTap: _incrementInstagram,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Image.asset(
                    'assets/instagram-logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          // TikTok Side (Right)
          Expanded(
            child: Container(
              color: Colors.black,
              child: FeedbackButton(
                onTap: _incrementTikTok,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Image.asset(
                    'assets/tiktok-logo.png',
                    fit: BoxFit.contain,
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

class FeedbackButton extends StatefulWidget {
  final VoidCallback onTap;
  final Widget child;

  const FeedbackButton({
    super.key,
    required this.onTap,
    required this.child,
  });

  @override
  State<FeedbackButton> createState() => _FeedbackButtonState();
}

class _FeedbackButtonState extends State<FeedbackButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  late AnimationController _checkController;
  late Animation<double> _checkScaleAnimation;
  late Animation<double> _checkOpacityAnimation;

  @override
  void initState() {
    super.initState();
    // Scale Animation (Button shrink)
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    // Check Animation
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _checkScaleAnimation = Tween<double>(begin: 0.5, end: 1.2).animate(
      CurvedAnimation(
        parent: _checkController,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );
    _checkOpacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _checkController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _checkController.dispose();
    super.dispose();
  }

  void _handleTap() {
    // Trigger callbacks and animations
    widget.onTap();
    
    // Scale button
    _scaleController.forward().then((_) => _scaleController.reverse());
    
    // Play check animation
    _checkController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _handleTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // The main content (Logo) with scale effect
          ScaleTransition(
            scale: _scaleAnimation,
            child: SizedBox.expand(child: widget.child),
          ),
          // The Check Mark Overlay
          AnimatedBuilder(
            animation: _checkController,
            builder: (context, child) {
              if (_checkController.isDismissed || _checkController.isCompleted) {
                return const SizedBox.shrink();
              }
              return Opacity(
                opacity: _checkOpacityAnimation.value,
                child: Transform.scale(
                  scale: _checkScaleAnimation.value,
                  child: Container(
                    width: 500,
                    height: 500,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      FontAwesomeIcons.check, // Thicker icon
                      color: Colors.green,
                      size: 350, // Adjusted size for FontAwesome
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
