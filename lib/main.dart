import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_colors.dart';
import 'core/services/device_id_service.dart';
import 'core/services/gemini_service.dart';
import 'core/services/image_cache_service.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/home/domain/repositories/process_repository.dart';
import 'features/home/data/repositories/process_repository_impl.dart';
import 'features/library/presentation/library_screen.dart';
import 'features/library/domain/repositories/library_repository.dart';
import 'features/library/data/repositories/library_repository_impl.dart';
import 'features/quiz/presentation/quiz_screen.dart';
import 'features/quiz/domain/repositories/quiz_repository.dart';
import 'features/quiz/data/repositories/quiz_repository_impl.dart';
import 'features/profile/presentation/profile_screen.dart';
import 'features/profile/domain/repositories/profile_repository.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Firebase.initializeApp();
  runApp(const QuizAIApp());
}

class QuizAIApp extends StatelessWidget {
  const QuizAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;
    final deviceIdService = DeviceIdService();
    final imageCacheService = ImageCacheService();
    final geminiService = GeminiService();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<DeviceIdService>.value(value: deviceIdService),
        RepositoryProvider<ImageCacheService>.value(value: imageCacheService),
        RepositoryProvider<GeminiService>.value(value: geminiService),
        RepositoryProvider<ProcessRepository>(
          create: (_) => ProcessRepositoryImpl(
            firestore: firestore,
            geminiService: geminiService,
            imageCacheService: imageCacheService,
          ),
        ),
        RepositoryProvider<LibraryRepository>(
          create: (_) => LibraryRepositoryImpl(firestore: firestore),
        ),
        RepositoryProvider<QuizRepository>(
          create: (_) => QuizRepositoryImpl(firestore: firestore),
        ),
        RepositoryProvider<ProfileRepository>(
          create: (_) => ProfileRepositoryImpl(firestore: firestore),
        ),
      ],
      child: MaterialApp(
        title: 'QuizAI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const MainNavigation(),
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    LibraryScreen(),
    QuizScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryNavy.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.white,
          indicatorColor: AppColors.primaryBlue.withValues(alpha: 0.1),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: AppColors.grey),
              selectedIcon: Icon(Icons.home, color: AppColors.primaryNavy),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.library_books_outlined, color: AppColors.grey),
              selectedIcon: Icon(Icons.library_books, color: AppColors.primaryNavy),
              label: 'Library',
            ),
            NavigationDestination(
              icon: Icon(Icons.quiz_outlined, color: AppColors.grey),
              selectedIcon: Icon(Icons.quiz, color: AppColors.primaryNavy),
              label: 'Quiz',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline, color: AppColors.grey),
              selectedIcon: Icon(Icons.person, color: AppColors.primaryNavy),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
