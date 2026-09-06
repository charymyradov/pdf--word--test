import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/enums/app_enums.dart';
import '../../../core/services/device_id_service.dart';
import 'bloc/library_bloc.dart';
import 'bloc/library_event.dart';
import 'bloc/library_state.dart';
import '../domain/entities/subject.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: context.read<DeviceIdService>().getDeviceId(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return BlocProvider(
          create: (context) => LibraryBloc(
            repository: context.read(),
            deviceId: snapshot.data!,
          )..add(LoadSubjects()),
          child: const LibraryView(),
        );
      },
    );
  }
}

class LibraryView extends StatelessWidget {
  const LibraryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildSearchBar(context),
                    const SizedBox(height: 16),
                    _buildCategoryPills(context),
                    const SizedBox(height: 20),
                    BlocBuilder<LibraryBloc, LibraryState>(
                      builder: (context, state) {
                        if (state is LibraryLoaded) {
                          return _buildHeroBanner(state);
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    const SizedBox(height: 20),
                    BlocBuilder<LibraryBloc, LibraryState>(
                      builder: (context, state) {
                        if (state is LibraryLoaded) {
                          return _buildSubjectGrid(state);
                        }
                        if (state is LibraryLoading) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.lightBlue, AppColors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Kütüphane',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.tune, color: AppColors.primaryBlue),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: TextField(
        onChanged: (value) => context.read<LibraryBloc>().add(SearchQueryChanged(value)),
        decoration: InputDecoration(
          hintText: 'Quiz veya konu ara...',
          prefixIcon: const Icon(Icons.search, color: AppColors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: AppColors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildCategoryPills(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: SubjectCategory.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = SubjectCategory.values[index];
          return BlocBuilder<LibraryBloc, LibraryState>(
            builder: (context, state) {
              final isSelected = state is LibraryLoaded && state.selectedCategory == category.label;
              return GestureDetector(
                onTap: () => context.read<LibraryBloc>().add(CategoryChanged(category.label)),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryBlue : AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppColors.primaryBlue : Colors.grey.shade200,
                    ),
                  ),
                  child: Text(
                    category.label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHeroBanner(LibraryLoaded state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Toplam Flashcard', style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 4),
                Text(
                  '${state.totalFlashcards}',
                  style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Mastery: %${(state.masteryLevel * 100).toInt()}',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: state.masteryLevel,
                  strokeWidth: 10,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                Center(
                  child: Text(
                    '${(state.masteryLevel * 100).toInt()}%',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectGrid(LibraryLoaded state) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.0,
      ),
      itemCount: state.filteredSubjects.length,
      itemBuilder: (context, index) {
        return _buildSubjectCard(context, state.filteredSubjects[index], index);
      },
    );
  }

  Widget _buildSubjectCard(BuildContext context, Subject subject, int index) {
    final color = _hexToColor(subject.hexColor);
    final icon = _iconDataFromKey(subject.iconKey);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.1),
            color.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              GestureDetector(
                onTap: () => context.read<LibraryBloc>().add(ToggleFavorite(index)),
                child: Icon(
                  subject.isFavorite ? Icons.star : Icons.star_border,
                  color: subject.isFavorite ? AppColors.orange : Colors.grey.shade400,
                  size: 22,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(subject.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primaryNavy)),
              const SizedBox(height: 4),
              Text('${subject.questionCount} soru',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
            ],
          ),
        ],
      ),
    );
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  IconData _iconDataFromKey(String key) {
    final iconMap = <String, IconData>{
      'calculate': Icons.calculate,
      'science': Icons.science,
      'menu_book': Icons.menu_book,
      'history_edu': Icons.history_edu,
      'computer': Icons.computer,
      'biotech': Icons.biotech,
      'functions': Icons.functions,
      'psychology': Icons.psychology,
      'translate': Icons.translate,
      'brush': Icons.brush,
      'music_note': Icons.music_note,
      'earth': Icons.language,
    };
    return iconMap[key] ?? Icons.help_outline;
  }

  Widget _buildFAB() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: Colors.transparent,
        elevation: 0,
        icon: const Icon(Icons.auto_awesome, color: Colors.white),
        label: const Text('AI ile Kart Oluştur',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
