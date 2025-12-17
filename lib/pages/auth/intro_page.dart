import 'dart:ui';

import 'package:flutter/material.dart';
import '../../widgets/animated_press_button.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  late PageController _pageController;
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'MediScript-д тавтай морил!',
      'description':
          'Эмийн жор бичих ухаалаг систем. Эмч, эмнэлгийн мэргэжилтнүүдэд зориулав.',
      'image': 'assets/images/intro1.png',
      'icon': Icons.medical_services_outlined,
      'color': const Color(0xFF00B8A9),
    },
    {
      'title': 'Ухаалаг тооцоолол',
      'description':
          'Жин, насанд тулгуурласан, нотолгоонд суурилсан тунг шууд санал болгоно.',
      'image': 'assets/images/intro2.png',
      'icon': Icons.psychology_outlined,
      'color': const Color(0xFF5C6BC0),
    },
    {
      'title': 'Аюулгүй, найдвартай',
      'description':
          'Өвчтөний өгөгдлийг байгууллагын түвшний хамгаалалт, шифрлэлтээр найдвартай хадгална.',
      'image': 'assets/images/intro3.png',
      'icon': Icons.security_outlined,
      'color': const Color(0xFFEF5350),
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutQuint,
      );
    } else {
      _goToLogin();
    }
  }

  void _goToLogin() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return _IntroPageContent(data: _pages[index]);
            },
          ),

          Positioned(
            top: 50,
            right: 20,
            child: AnimatedOpacity(
              opacity: _currentPage == _pages.length - 1 ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: AnimatedPressButton(
                onPressed: _goToLogin,
                child: TextButton(
                  onPressed: _goToLogin,
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(
                      context,
                    ).colorScheme.onBackground.withOpacity(0.6),
                  ),
                  child: const Text(
                    'Алгасах',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? _pages[_currentPage]['color']
                            : Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: AnimatedPressButton(
                    onPressed: _nextPage,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: Theme.of(context).elevatedButtonTheme.style
                          ?.copyWith(
                            backgroundColor: WidgetStateProperty.all(
                              _pages[_currentPage]['color'],
                            ),
                          ),
                      child: Text(
                        _currentPage == _pages.length - 1 ? 'Эхлэх' : 'Дараах',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
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

class _IntroPageContent extends StatelessWidget {
  final Map<String, dynamic> data;

  const _IntroPageContent({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 3,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: (data['color'] as Color).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: Center(
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (data['color'] as Color).withOpacity(0.35),
                          boxShadow: [
                            BoxShadow(
                              color: (data['color'] as Color).withOpacity(0.25),
                              blurRadius: 80,
                              spreadRadius: 40,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: 440,
                  height: 440,
                  child: Image.asset(
                    data['image'],
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(data['icon'], size: 80, color: data['color']);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(32, 40, 32, 0),
            child: Column(
              children: [
                Text(
                  data['title'],
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  data['description'],
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 100),
      ],
    );
  }
}
