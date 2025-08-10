import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'dart:html' as html;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:portofilio_website/ignore.dart';

import '../model/model.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final ScrollController _scrollController = ScrollController();
  late final ValueNotifier<double> _scrollNotifier;
  Timer? _throttle;
  final GlobalKey aboutKey = GlobalKey();
  final GlobalKey projectsKey = GlobalKey();

  void _scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollNotifier = ValueNotifier<double>(0);
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_throttle?.isActive ?? false) return;
    _throttle = Timer(const Duration(milliseconds: 16), () {
      _scrollNotifier.value = _scrollController.offset;
    });
  }

  @override
  void dispose() {
    _throttle?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _scrollNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isMobile = constraints.maxWidth < 600;
          final bool isTablet = constraints.maxWidth < 1000;

          return SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                MainBannerWidget(
                  scrollNotifier: _scrollNotifier,
                  onProjectsTap: () => _scrollToSection(projectsKey),
                  onAboutTap: () => _scrollToSection(aboutKey),
                  isMobile: isMobile,
                ),
                SizedBox(height: isMobile ? 30 : 60),

                KeyedSubtree(
                  key: aboutKey,
                  child: Text(
                    "About Me",
                    style: GoogleFonts.kalam(
                      color: Colors.white,
                      fontSize: isMobile ? 36 : 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: isMobile ? 30 : 60),
                AboutMeWidget(isMobile: isMobile),
                SizedBox(height: isMobile ? 24 : 48),
                KeyedSubtree(
                  key: projectsKey,
                  child: Text(
                    "Recent Projects",
                    style: GoogleFonts.kalam(
                      color: Colors.white,
                      fontSize: isMobile ? 36 : 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                RecentProjectsCarousel(isMobile: isMobile, isTablet: isTablet),
                SizedBox(height: isMobile ? 16 : 32),
                Text(
                  "Skills",
                  style: GoogleFonts.kalam(
                    color: Colors.white,
                    fontSize: isMobile ? 36 : 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: isMobile ? 16 : 32),
                SvgMarquee(
                  svgAssets: [
                    'assets/svgs/flutter.svg',
                    'assets/svgs/firebase.svg',
                    'assets/svgs/github.svg',
                    'assets/svgs/git.svg',
                    'assets/svgs/supabase.svg',
                    'assets/svgs/dart.svg',
                    'assets/svgs/flutter.svg',
                    'assets/svgs/firebase.svg',
                    'assets/svgs/github.svg',
                    'assets/svgs/git.svg',
                    'assets/svgs/supabase.svg',
                    'assets/svgs/dart.svg',
                  ],
                  spacing: isMobile ? 16 : 32,
                  size: isMobile ? 60 : 100,
                ),
                SizedBox(height: isMobile ? 16 : 32),
                SizedBox(width: 500,child: ContactForm(isMobile: isMobile)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class SvgMarquee extends StatefulWidget {
  final List<String> svgAssets;
  final double velocity;
  final double size;
  final double spacing;

  const SvgMarquee({
    Key? key,
    required this.svgAssets,
    this.velocity = 100.0,
    required this.size,
    this.spacing = 8.0,
  }) : super(key: key);

  @override
  _SvgMarqueeState createState() => _SvgMarqueeState();
}

class _SvgMarqueeState extends State<SvgMarquee>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final double _totalScrollWidth;
  late final List<Widget> _itemWidgets;

  @override
  void initState() {
    super.initState();

    _itemWidgets = [];
    for (var i = 0; i < widget.svgAssets.length; i++) {
      _itemWidgets.add(
        SvgPicture.asset(
          widget.svgAssets[i],
          width: widget.size,
          height: widget.size,
          fit: BoxFit.contain,
        ),
      );
      if (i < widget.svgAssets.length - 1) {
        _itemWidgets.add(SizedBox(width: widget.spacing));
      }
    }
    final iconsWidth = widget.svgAssets.length * widget.size;
    final totalSpacing = (widget.svgAssets.length - 1) * widget.spacing;
    _totalScrollWidth = iconsWidth + totalSpacing;

    final durationMs = (_totalScrollWidth / widget.velocity * 1000).round();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: durationMs),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildRow() {
    return Row(children: [..._itemWidgets, ..._itemWidgets]);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: SizedBox(
        height: widget.size,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, child) {
            final shift = _controller.value * _totalScrollWidth;
            final dx = -(shift % _totalScrollWidth);
            return Transform.translate(offset: Offset(dx, 0), child: child);
          },
          child: OverflowBox(
            maxWidth: double.infinity,
            alignment: Alignment.centerLeft,
            child: _buildRow(),
          ),
        ),
      ),
    );
  }
}

class AboutMeWidget extends StatelessWidget {
  final bool isMobile;
  const AboutMeWidget({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            RotatingDashedCircle(
              size: 300,
              borderThickness: 2,
              dotRadius: 4,
              dashGapFactor: 1,
              rotationDuration: Duration(seconds: 30),
              child: SizedBox(
                height: 280,
                width: 280,
                child: ClipOval(
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    "assets/cut avatar.png",
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "I'm Eddy, a Flutter developer passionate about building smooth, high-performance mobile applications with a focus on clean architecture and responsive design. "
              "I enjoy translating ideas into functional, user-friendly interfaces using modern development practices and tools like Dart, Flutter, and Firebase. "
              "My goal is to contribute to meaningful projects and grow alongside teams that value quality code, continuous learning, and thoughtful design. "
              "I'm currently open to new opportunities where I can apply my skills, take on real-world challenges, and continue developing as a mobile developer.",
              textAlign: TextAlign.center,
              style: GoogleFonts.kalam(
                color: Colors.white,
                fontSize: isMobile ? 18 : 26,
              ),
            ),
          ],
        ),
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RotatingDashedCircle(
            size: 500,
            borderThickness: 2,
            dotRadius: 4,
            dashGapFactor: 1,
            rotationDuration: Duration(seconds: 30),
            child: SizedBox(
              height: 450,
              width: 450,
              child: ClipOval(
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  "assets/cut avatar.png",
                  height: 450,
                  width: 450,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SizedBox(width: 60),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                "I'm Eddy, a Flutter developer passionate about building smooth, high-performance mobile applications with a focus on clean architecture and responsive design. "
                "I enjoy translating ideas into functional, user-friendly interfaces using modern development practices and tools like Dart, Flutter, and Firebase. "
                "My goal is to contribute to meaningful projects and grow alongside teams that value quality code, continuous learning, and thoughtful design. "
                "I'm currently open to new opportunities where I can apply my skills, take on real-world challenges, and continue developing as a mobile developer.",
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.start,
                style: GoogleFonts.kalam(color: Colors.white, fontSize: 26),
              ),
            ),
          ),
        ],
      );
    }
  }
}
class ContactForm extends StatefulWidget {
  final bool isMobile;

  const ContactForm({Key? key, required this.isMobile}) : super(key: key);

  @override
  State<ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<ContactForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Send Me a Message",
            style: GoogleFonts.kalam(
              color: Colors.white,
              fontSize: widget.isMobile ? 24 : 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: widget.isMobile ? TextAlign.center : TextAlign.left,
          ),
          SizedBox(height: 24),
          _buildTextField(
            controller: _nameController,
            label: "Your Name",
            hint: "Enter your full name",
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          SizedBox(height: 16),
          _buildTextField(
            controller: _emailController,
            label: "Email Address",
            hint: "your.email@example.com",
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          SizedBox(height: 16),
          _buildTextField(
            controller: _messageController,
            label: "Message",
            hint: "Tell me about your project or just say hello!",
            maxLines: 5,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a message';
              }
              if (value.length < 10) {
                return 'Message should be at least 10 characters';
              }
              return null;
            },
          ),
          SizedBox(height: 24),
          AnimatedContainer(
            duration: Duration(milliseconds: 200),
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 8,
              ),
              child: _isSubmitting
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          "Sending...",
                          style: GoogleFonts.kalam(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      "Send Message",
                      style: GoogleFonts.kalam(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.kalam(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          style: GoogleFonts.kalam(
            color: Colors.white,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.kalam(
              color: Colors.white38,
              fontSize: 16,
            ),
            filled: true,
            fillColor: Colors.black26,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white10),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: maxLines > 1 ? 16 : 12,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    
    await Future.delayed(Duration(seconds: 2));

   
    final String name = _nameController.text;
    final String email = _emailController.text;
    final String message = _messageController.text;
    
    final String subject = Uri.encodeComponent("Portfolio Contact from $name");
    final String body = Uri.encodeComponent(
      "Name: $name\nEmail: $email\n\nMessage:\n$message"
    );
    
    final String mailtoUrl = "mailto:${MyEmail.email}?subject=$subject&body=$body";
    
    html.window.open(mailtoUrl, '_self');

    setState(() => _isSubmitting = false);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Thank you for your message! Your email client should open now.",
          style: GoogleFonts.kalam(),
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );

    // Clear form
    _nameController.clear();
    _emailController.clear();
    _messageController.clear();
  }
}


class RotatingDashedCircle extends StatefulWidget {
  final double size;
  final double borderThickness;
  final double dotRadius;
  final double dashGapFactor;
  final Duration rotationDuration;
  final Widget child;

  const RotatingDashedCircle({
    super.key,
    required this.size,
    required this.borderThickness,
    required this.dotRadius,
    required this.dashGapFactor,
    required this.rotationDuration,
    required this.child,
  });

  @override
  State<RotatingDashedCircle> createState() => _RotatingDashedCircleState();
}

class _RotatingDashedCircleState extends State<RotatingDashedCircle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.rotationDuration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          RotationTransition(
            turns: _controller,
            child: CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _DashedCirclePainter(
                thickness: widget.borderThickness,
                dotRadius: widget.dotRadius,
                dashGapFactor: widget.dashGapFactor,
              ),
            ),
          ),
          widget.child,
        ],
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  final double thickness;
  final double dotRadius;
  final double dashGapFactor;

  _DashedCirclePainter({
    required this.thickness,
    required this.dotRadius,
    required this.dashGapFactor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (min(size.width, size.height) - thickness) / 2;

    final dotDiameter = dotRadius * 2;
    final dashArc = dotDiameter / radius;
    final dashGroupAngle = dashArc * 2;
    final gapAngle = (dotDiameter * dashGapFactor) / radius;

    double startAngle = 0;
    while (startAngle < 2 * pi) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        dashGroupAngle,
        false,
        paint,
      );
      startAngle += dashGroupAngle + gapAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter old) {
    return old.thickness != thickness ||
        old.dotRadius != dotRadius ||
        old.dashGapFactor != dashGapFactor;
  }
}

class RecentProjectsCarousel extends StatelessWidget {
  final bool isMobile;
  final bool isTablet;

  const RecentProjectsCarousel({
    Key? key,
    required this.isMobile,
    required this.isTablet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CarouselSliderController controller = CarouselSliderController();
    final List<Project> projects = [
      Project(
        name: "E‑commerce App",
        description:
            "A modern, scalable Flutter e‑commerce mobile application built using flutter_bloc for state management, get_it for dependency injection, and flutter_secure_storage for secure user data handling. It showcases clean architecture and domain‑driven design, supporting product browsing, cart management, Paymob payment integration, geolocation, responsive UI, and persistent app state via hydrated_bloc.",
        images: [
          "assets/E-commerce/one with laptop.png",
          "assets/E-commerce/Ecommerce.png",
          "assets/E-commerce/5 layed.png",
        ],
        link: "https://github.com/eddypencil/E-commerce",
        mainImagePath: "assets/E-commerce/Main.png",
        details: """
This Flutter e‑commerce app is built using clean architecture and domain‑driven design. It leverages flutter_bloc (and hydrated_bloc) to manage and persist state, while get_it handles dependency injection across layers. Sensitive data like tokens and credentials are secured using flutter_secure_storage.

Real‑world e‑commerce flow includes:
• Browse products and view detailed product pages.
• Add items to cart and manage quantities.
• Proceed to checkout and create an order via secure API.
• Authenticate with Paymob gateway.
• Generate a payment key for the order using Dio.
• Redirect user via url_launcher to the Paymob iframe for payment.
• Support Visa/Mastercard and e‑wallet payments.
• Handle payment success or failure callbacks securely over HTTPS.

Supporting features:
• Location access and map view to enhance UX.
• Responsive UI using flutter_screenutil across device sizes.
• Skeleton loaders during data fetch for smoother UX.

This structure demonstrates a full end‑to‑end app flow—from browsing to order, payment key generation, and iframe redirection—ideal as a template for production‑ready Flutter e‑commerce projects.
""",
      ),
      Project(
        images: ["assets/Maifa/layed.png", "assets/Maifa/ontop.png"],
        details:
            """This Flutter app delivers a polished gaming experience for Mafia, blending real‑time multiplayer via WebSockets with stunning in-app animations and fluid UI transitions. The app assigns secret roles to each player at game start, facilitating both online matches and fully offline, device-local gameplay using bloc for state management. Role logic, timer control, vote rounds, and win conditions are all handled deterministically—supporting seamless play whether connected or not.

Game Flow includes:
• Players join a game—locally via same device (offline) or online via WebSockets.
• At game start, each player is assigned a role (e.g. Mafia, Detective, Villager) silently.
• Animated transitions reveal roles with fade, scale, or slide effects.
• Night phase: players perform actions (e.g. Mafia kill, Detective investigate), managed via bloc (offline) or WebSocket messages (online).
• Day phase: players discuss and vote to eliminate a suspect. Votes are tallied in real time.
• Role reveals and result animations show who was eliminated and win/lose status.
• Repeat night/day phases until win conditions are met (e.g. Mafia eliminated or equal roles left).
• Users can start a new game, switch roles, or change player count mid‑session.

Supporting features:
• Works offline using local bloc state—and online with peer WebSocket communication.
• Slick in‑game animations: role reveal cards, countdown timers, vote tally visuals.
• Dependency‑free, self‑contained game logic layer.
• Responsive layout adapting to phones and tablets.
• Easily customizable for different role sets or animation themes.

This app is ideal if you’re looking for a local‑first, optionally online multiplayer game framework in Flutter, combining real‑time WebSocke""",
        name: "Mafia",
        description:
            "A dynamic Flutter app for MafAI, featuring real‑time gameplay via WebSockets, immersive animations, and role assignments for each player. It supports both offline (local multiplayer) via bloc and online multiplayer using WebSocket connectivity—all within a clean, responsive UI.",
        mainImagePath: "assets/Mafia/Mainhand.png",
      ),
      Project(
        name: "Food Ordring App",
        details:
            "This food ordering app offers a smooth, secure, and user-friendly experience for exploring and ordering your favorite dishes.\n"
            "Powered by Firebase Authentication, users can quickly sign up, log in, and manage their accounts with confidence.\n"
            "The app features a cart system for adding and reviewing items before checkout, as well as an order history section to easily track past purchases and reorder favorites.\n"
            "Each menu item includes a detailed food screen showcasing mouthwatering images, descriptions, and a clear list of ingredients, ensuring transparency and helping customers make informed choices.\n",
        mainImagePath: "assets/foodApp.png",
        link: "https://github.com/eddypencil/Menu_app_with_firebase",
        images: [],
        description:
            "This food ordering app makes exploring and ordering your favorite dishes easy and secure. With Firebase Authentication, users can sign up, log in, and manage accounts effortlessly. Features include a cart, order history, and detailed food screens with images and ingredients for informed choices. Whether it’s a snack or a full meal, ordering is fast, safe, and convenient.",
      ),
      Project(
        images: [],
        description:
            "A sleek Flutter app using flutter_map for interactive maps, custom markers, routes, and live GPS tracking.",
        name: "Map App",
        details:
            "FlutterMap Navigator is a sleek and responsive mobile application built with Flutter and powered by the flutter_map package, delivering fast and interactive mapping experiences across iOS and Android.\n\n"
            "With FlutterMap Navigator, users can:\n"
            "- Browse interactive maps with smooth zooming, panning, and rotation.\n"
            "- Display custom markers and icons for points of interest, events, or user locations.\n"
            "- Draw routes and polygons to visualize paths, regions, and boundaries.\n"
            "- Switch between map tile providers (such as OpenStreetMap, Mapbox, or custom tiles).\n"
            "- Track live location using device GPS for real-time navigation.\n\n"
            "Designed with a clean UI, intuitive gestures, and flexible customization, this app demonstrates the power of Flutter and the versatility of the flutter_map plugin for building modern location-based experiences.",
        mainImagePath: "assets/mapApp.png",
        link: "https://github.com/eddypencil/flutter_map_app",
      ),
    ];

    return MouseRegion(
      onEnter: (_) => controller.stopAutoPlay(),
      onExit: (_) => controller.startAutoPlay(),
      child: SizedBox(
        width: double.infinity,
        height: isMobile ? 400 : (isTablet ? 500 : 600),
        child: CarouselSlider.builder(
          itemCount: projects.length,
          carouselController: controller,
          options: CarouselOptions(
            aspectRatio: isMobile ? 0.8 : 1.0,
            enlargeCenterPage: isMobile,
            viewportFraction: isMobile ? 0.8 : (isTablet ? 0.6 : 0.4),
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            autoPlayAnimationDuration: const Duration(milliseconds: 1500),
            pauseAutoPlayOnTouch: true,
          ),
          itemBuilder: (context, index, realIdx) {
            return ProjectsWidget(project: projects[index], isMobile: isMobile);
          },
        ),
      ),
    );
  }
}

class MainBannerWidget extends StatelessWidget {
  final ValueListenable<double> scrollNotifier;
  final VoidCallback onProjectsTap;
  final VoidCallback onAboutTap;
  final bool isMobile;

  const MainBannerWidget({
    Key? key,
    required this.scrollNotifier,
    required this.onProjectsTap,
    required this.onAboutTap,
    required this.isMobile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: isMobile ? 600 : 1000,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/landing.png',
              fit: BoxFit.cover,
              cacheHeight: isMobile ? 600 : 1000,
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.2)),
          ),
          ValueListenableBuilder<double>(
            valueListenable: scrollNotifier,
            builder: (_, offset, __) => Stack(
              children: [
                Positioned(
                  top: -100,
                  left: -100,
                  child: Transform.translate(
                    offset: Offset(-offset * 0.5, -offset),
                    child: IgnorePointer(
                      child: RepaintBoundary(
                        child: Image.asset(
                          'assets/topLeft.png',
                          width: isMobile ? 500 : 800,
                          height: isMobile ? 300 : 500,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Transform.translate(
                    offset: Offset(offset * 0.5, 0),
                    child: IgnorePointer(
                      child: RepaintBoundary(
                        child: Image.asset(
                          'assets/bottomRight.png',
                          width: isMobile ? 500 : 800,
                          height: isMobile ? 500 : 800,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 16.0 : 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: isMobile ? 8 : 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (!isMobile) SizedBox(width: 24),
                      AppBarButton(
                        icon: Icons.account_circle_outlined,
                        text: 'About',
                        voidCallback: onAboutTap,
                        isMobile: isMobile,
                      ),
                      SizedBox(width: isMobile ? 8 : 24),
                      AppBarButton(
                        icon: Icons.precision_manufacturing,
                        text: 'Projects',
                        voidCallback: onProjectsTap,
                        isMobile: isMobile,
                      ),
                      if (!isMobile) SizedBox(width: 200),
                    ],
                  ),
                  Spacer(),
                  Text(
                    "Hi, I'm Eddy",
                    style: GoogleFonts.kalam(
                      color: Colors.white,
                      fontSize: isMobile ? 32 : 42,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: isMobile ? 4 : 8),
                  Text(
                    "Flutter Developer & Tech Enthusiast",
                    style: GoogleFonts.kalam(
                      color: Colors.white70,
                      fontSize: isMobile ? 20 : 28,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  SizedBox(height: isMobile ? 12 : 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Spacer(flex: 1),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _launchURL(
                          'https://www.linkedin.com/in/eyad-elasser-b5b44b336',
                        ),
                        child: Container(
                          width: isMobile ? 48 : 64,
                          height: isMobile ? 48 : 64,
                          padding: const EdgeInsets.all(8),
                          child: SvgPicture.asset(
                            'assets/svgs/linkedin.svg',
                            height: isMobile ? 32 : 48,
                          ),
                        ),
                      ),
                      SizedBox(width: isMobile ? 12 : 16),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () =>
                            _launchURL('https://github.com/eddypencil'),
                        child: Container(
                          width: isMobile ? 48 : 64,
                          height: isMobile ? 48 : 64,
                          padding: const EdgeInsets.all(8),
                          child: SvgPicture.asset(
                            'assets/svgs/github.svg',
                            height: isMobile ? 32 : 48,
                          ),
                        ),
                      ),
                      Spacer(flex: 2),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: RepaintBoundary(
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
                    child: Container(
                      height: 80,
                      color: Colors.black.withOpacity(0.1),
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

  void _launchURL(String url) {
    html.window.open(url, '_blank');
  }
}

class ProjectsWidget extends StatefulWidget {
  final Project project;
  final bool isMobile;

  const ProjectsWidget({
    super.key,
    required this.project,
    required this.isMobile,
  });

  @override
  State<ProjectsWidget> createState() => _ProjectsWidgetState();
}

class _ProjectsWidgetState extends State<ProjectsWidget>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late final AnimationController _ctrl;
  late final Animation<double> _bounce;
  late final Animation<Offset> _nameOffset;
  late final Animation<Offset> _descOffset;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _bounce = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _nameOffset = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.5)));
    _descOffset = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.2, 0.7)));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onHover(bool hover) {
    setState(() => _isHovered = hover);
    hover ? _ctrl.forward(from: 0) : _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: AnimatedScale(
        scale: _isHovered ? 1.0 : (widget.isMobile ? 0.9 : 0.7),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: Alignment.center,
        child: AnimatedPhysicalModel(
          elevation: _isHovered ? 16 : 8,
          shape: BoxShape.rectangle,
          shadowColor: Colors.black54,
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          duration: const Duration(milliseconds: 300),
          child: SizeTransition(
            axis: Axis.vertical,
            axisAlignment: 0,
            sizeFactor: _bounce,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      widget.project.mainImagePath,
                      fit: BoxFit.cover,
                      cacheHeight: widget.isMobile ? 400 : 600,
                    ),
                  ),
                  AnimatedOpacity(
                    opacity: _isHovered || widget.isMobile ? 1 : 0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                    child: Container(
                      color: Colors.black.withOpacity(0.6),
                      padding: EdgeInsets.all(widget.isMobile ? 12 : 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SlideTransition(
                            position: _nameOffset,
                            child: Text(
                              widget.project.name,
                              style: GoogleFonts.kalam(
                                fontSize: widget.isMobile ? 24 : 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: widget.isMobile ? 4 : 8),
                          SlideTransition(
                            position: _descOffset,
                            child: Text(
                              widget.project.description,
                              style: GoogleFonts.kalam(
                                fontSize: widget.isMobile ? 16 : 22,
                                color: Colors.white70,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: widget.isMobile ? 3 : 5,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(height: widget.isMobile ? 16 : 16),
                          SlideFade(
                            delay: const Duration(milliseconds: 300),
                            child: ElevatedButton(
                              onPressed: () => _launchURL(widget.project.link!),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                padding: EdgeInsets.symmetric(
                                  horizontal: widget.isMobile ? 16 : 24,
                                  vertical: widget.isMobile ? 8 : 12,
                                ),
                              ),
                              child: Text(
                                "View Project",
                                style: GoogleFonts.kalam(
                                  fontSize: widget.isMobile ? 16 : 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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

  void _launchURL(String url) {
    html.window.open(url, '_blank');
  }
}

class SlideFade extends StatelessWidget {
  final Widget child;
  final Duration delay;

  const SlideFade({super.key, required this.child, required this.delay});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      builder: (context, Offset offset, _) {
        return Transform.translate(
          offset: offset,
          child: AnimatedOpacity(
            opacity: 1,
            duration: const Duration(milliseconds: 400),
            child: child,
          ),
        );
      },
    );
  }
}

class AppBarButton extends StatefulWidget {
  final String text;
  final IconData icon;
  final VoidCallback voidCallback;
  final bool isMobile;

  const AppBarButton({
    super.key,
    required this.text,
    required this.icon,
    required this.voidCallback,
    required this.isMobile,
  });

  @override
  State<AppBarButton> createState() => _AppBarButtonState();
}

class _AppBarButtonState extends State<AppBarButton>
    with TickerProviderStateMixin {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.voidCallback,
        child: AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: Alignment.centerLeft,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: widget.isMobile ? 8 : 12,
              vertical: widget.isMobile ? 6 : 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  widget.icon,
                  color: Colors.black,
                  size: widget.isMobile ? 24 : 30,
                ),
                if (_isHovered || !widget.isMobile) ...[
                  SizedBox(width: widget.isMobile ? 4 : 16),
                  Text(
                    widget.text,
                    style: GoogleFonts.kalam(
                      color: Colors.black,
                      fontSize: widget.isMobile ? 18 : 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
