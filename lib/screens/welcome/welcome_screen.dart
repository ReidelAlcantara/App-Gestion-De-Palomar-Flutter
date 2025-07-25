import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../mi_palomar/mi_palomar_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;
  
  final List<WelcomePage> _pages = [
    WelcomePage(
      icon: Icons.home,
      title: 'Bienvenido a tu Palomar Digital',
      description: 'Gestiona todas tus palomas de forma moderna y eficiente. '
          'Registra, organiza y mantén un control completo de tu palomar.',
      color: AppColors.primary,
    ),
    WelcomePage(
      icon: Icons.favorite,
      title: 'Reproducción Inteligente',
      description: 'Controla el proceso de reproducción, registra parejas, '
          'huevos y pichones. Mantén un árbol genealógico completo.',
      color: AppColors.primaryLight,
    ),
    WelcomePage(
      icon: Icons.medical_services,
      title: 'Tratamientos Médicos',
      description: 'Programa y registra tratamientos médicos, vacunas y '
          'medicamentos. Mantén la salud de tu palomar bajo control.',
      color: AppColors.success,
    ),
    WelcomePage(
      icon: Icons.analytics,
      title: 'Estadísticas Detalladas',
      description: 'Analiza el rendimiento de tu palomar con gráficos '
          'y reportes detallados. Toma decisiones informadas.',
      color: AppColors.warning,
    ),
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

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishWelcome();
    }
  }

  void _finishWelcome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MiPalomarScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: _finishWelcome,
                  child: Text(
                    'Omitir',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            
            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return _WelcomePageView(page: page);
                },
              ),
            ),
            
            // Bottom section
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == index
                              ? _pages[index].color
                              : AppColors.textTertiary,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Next/Finish button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      child: Text(
                        _currentPage == _pages.length - 1 ? '¡Empezar!' : 'Siguiente',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomePageView extends StatelessWidget {
  final WelcomePage page;
  
  const _WelcomePageView({required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: page.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              page.icon,
              size: 60,
              color: page.color,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Title
          Text(
            page.title,
            style: AppTextStyles.h2.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          // Description
          Text(
            page.description,
            style: AppTextStyles.bodyLarge.copyWith(
              color: Colors.grey,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class WelcomePage {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  
  WelcomePage({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
} 