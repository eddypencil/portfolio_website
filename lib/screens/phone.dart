import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'dart:html' as html;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:portofilio_website/model/model.dart';
import 'package:portofilio_website/screens/desktop.dart';


class PhoneScreen extends StatefulWidget {
  const PhoneScreen({super.key});

  @override
  State<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen> {
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
    final CarouselSliderController _carouselController = CarouselSliderController();

    final List<Project> projects = [
      Project(
        name: "E‑commerce App",
        description: "A modern, scalable Flutter e‑commerce mobile application built using flutter_bloc for state management...",
        images: [
          "assets/E-commerce/one with laptop.png",
          "assets/E-commerce/Ecommerce.png",
          "assets/E-commerce/5 layed.png",
        ],
        link: "https://github.com/eddypencil/E-commerce",
        mainImagePath: "assets/E-commerce/Main.png",
        details: "This Flutter e‑commerce app is built using clean architecture and domain‑driven design...",
      ),
      Project(
        images: ["assets/Maifa/layed.png", "assets/Maifa/ontop.png"],
        details: "This Flutter app delivers a polished gaming experience for Mafia...",
        name: "Mafia",
        description: "A dynamic Flutter app for MafAI, featuring real‑time gameplay via WebSockets...",
        mainImagePath: "assets/Mafia/Mainhand.png",
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            MobileMainBannerWidget(
              scrollNotifier: _scrollNotifier,
              onProjectsTap: () => _scrollToSection(projectsKey),
              onAboutTap: () => _scrollToSection(aboutKey),
            ),
            const SizedBox(height: 40),
            
            KeyedSubtree(
              key: aboutKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "About Me",
                  style: GoogleFonts.kalam(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            
            MobileAboutMeWidget(),
            const SizedBox(height: 40),
            
            KeyedSubtree(
              key: projectsKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Recent Projects",
                  style: GoogleFonts.kalam(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            MobileProjectsCarousel(projects: projects),
            const SizedBox(height: 30),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Skills",
                style: GoogleFonts.kalam(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            
            MobileSvgMarquee(
              svgAssets: [
                'assets/svgs/flutter.svg',
                'assets/svgs/firebase.svg',
                'assets/svgs/github.svg',
                'assets/svgs/git.svg',
                'assets/svgs/supabase.svg',
                'assets/svgs/dart.svg',
              ],
              size: 60,
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class MobileMainBannerWidget extends StatelessWidget {
  final ValueListenable<double> scrollNotifier;
  final VoidCallback onProjectsTap;
  final VoidCallback onAboutTap;

  const MobileMainBannerWidget({
    Key? key,
    required this.scrollNotifier,
    required this.onProjectsTap,
    required this.onAboutTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/landing.png',
              fit: BoxFit.cover,
            ),
          ),
          
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),
          
          Positioned(
            top: 40,
            right: 20,
            child: Column(
              children: [
                MobileAppBarButton(
                  icon: Icons.account_circle_outlined,
                  text: 'About',
                  voidCallback: onAboutTap,
                ),
                SizedBox(height: 10),
                MobileAppBarButton(
                  icon: Icons.precision_manufacturing,
                  text: 'Projects',
                  voidCallback: onProjectsTap,
                ),
              ],
            ),
          ),
          
          Positioned(
            bottom: 100,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hi, I'm Eddy",
                  style: GoogleFonts.kalam(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Flutter Developer & Tech Enthusiast",
                  style: GoogleFonts.kalam(
                    color: Colors.white70,
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MobileAboutMeWidget extends StatelessWidget {
  const MobileAboutMeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            width: 200,
            child: RotatingDashedCircle(
              size: 200,
              borderThickness: 2,
              dotRadius: 4,
              dashGapFactor: 1,
              rotationDuration: Duration(seconds: 30),
              child: ClipOval(

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
              fontSize: 16
            ),
          ),
        ],
      ),
    );
  }
}

class MobileProjectsCarousel extends StatelessWidget {
  final List<Project> projects;
  
  const MobileProjectsCarousel({Key? key, required this.projects}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: CarouselSlider.builder(
        itemCount: projects.length,
        options: CarouselOptions(
          aspectRatio: 0.8,
          enlargeCenterPage: true,
          viewportFraction: 0.7,
          autoPlay: true,
          autoPlayInterval: Duration(seconds: 3),
        ),
        itemBuilder: (context, index, realIdx) {
          return MobileProjectCard(project: projects[index]);
        },
      ),
    );
  }
}

class MobileProjectCard extends StatefulWidget {
  final Project project;
  
  const MobileProjectCard({Key? key, required this.project}) : super(key: key);

  @override
  State<MobileProjectCard> createState() => _MobileProjectCardState();
}

class _MobileProjectCardState extends State<MobileProjectCard> {
  bool _isTapped = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _isTapped = !_isTapped),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        margin: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: Offset(0, 5),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  widget.project.mainImagePath,
                  fit: BoxFit.cover,
                ),
              ),
              AnimatedOpacity(
                opacity: _isTapped ? 1 : 0,
                duration: Duration(milliseconds: 300),
                child: Container(
                  color: Colors.black.withOpacity(0.7),
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.project.name,
                        style: GoogleFonts.kalam(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      Text(
                        widget.project.description,
                        style: GoogleFonts.kalam(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 15),
                      if (widget.project.link != null)
                        ElevatedButton(
                          onPressed: () => html.window.open(widget.project.link!, '_blank'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                          ),
                          child: Text(
                            "View Project",
                            style: GoogleFonts.kalam(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
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
    );
  }
}

class MobileSvgMarquee extends StatefulWidget {
  /// The list of SVG asset paths to scroll.
  final List<String> svgAssets;

  /// Width & height of each SVG.
  final double size;

  /// How many logical pixels to scroll on each tick.
  final double scrollSpeed;

  /// How often to advance the scroll.
  final Duration scrollInterval;

  const MobileSvgMarquee({
    Key? key,
    required this.svgAssets,
    this.size = 60,
    this.scrollSpeed = 1.0,
    this.scrollInterval = const Duration(milliseconds: 16),
  })  : assert(svgAssets.length > 0),
        super(key: key);

  @override
  _MobileSvgMarqueeState createState() => _MobileSvgMarqueeState();
}

class _MobileSvgMarqueeState extends State<MobileSvgMarquee> {
  late final ScrollController _controller;
  Timer? _timer;
  double _maxScrollExtent = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();

    // Once the ListView is laid out, grab its max scroll extent:
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_controller.hasClients) {
        _maxScrollExtent = _controller.position.maxScrollExtent;
        _startScrolling();
      }
    });
  }

  void _startScrolling() {
    _timer?.cancel();
    _timer = Timer.periodic(widget.scrollInterval, (_) {
      if (!_controller.hasClients || _maxScrollExtent <= 0) return;

      final nextOffset = _controller.offset + widget.scrollSpeed;

      if (nextOffset >= _maxScrollExtent) {
        // Jump back to the very start (seamless loop)
        _controller.jumpTo(0);
      } else {
        _controller.jumpTo(nextOffset);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // We double the list so as we scroll out of the first half,
    // the second half is already queued up seamlessly.
    final items = List<String>.from(widget.svgAssets)
      ..addAll(widget.svgAssets);

    return SizedBox(
      height: widget.size + 20,
      child: ListView.builder(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: SvgPicture.asset(
              items[index],
              width: widget.size,
              height: widget.size,
            ),
          );
        },
      ),
    );
  }
}

class MobileAppBarButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback voidCallback;

  const MobileAppBarButton({
    Key? key,
    required this.text,
    required this.icon,
    required this.voidCallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: voidCallback,
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.black, size: 20),
            SizedBox(width: 8),
            Text(
              text,
              style: GoogleFonts.kalam(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Keep your existing RotatingDashedCircle and _DashedCirclePainter classes