import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/enums/app_enums.dart';
import '../../../core/services/device_id_service.dart';
import 'bloc/home_bloc.dart';
import 'bloc/home_event.dart';
import 'bloc/home_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: context.read<DeviceIdService>().getDeviceId(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return BlocProvider(
          create: (context) => HomeBloc(
            repository: context.read(),
            deviceId: snapshot.data!,
          ),
          child: const HomeView(),
        );
      },
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildImageUploadArea(context),
                    const SizedBox(height: 20),
                    _buildProcessTypeDropdown(context),
                    const SizedBox(height: 16),
                    _buildStartButton(context),
                    BlocBuilder<HomeBloc, HomeState>(
                      builder: (context, state) {
                        if (state is HomeProcessing) {
                          return _buildProgressIndicator(state.progress);
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    BlocBuilder<HomeBloc, HomeState>(
                      builder: (context, state) {
                        if (state is HomeSuccess) {
                          return _buildSuccessResult(context, state);
                        }
                        if (state is HomeError) {
                          return _buildErrorResult(context, state);
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
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                AppConstants.appName,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryNavy),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryBlue, width: 2),
            ),
            child: const CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.lightBlue,
              child: Icon(Icons.person, color: AppColors.primaryBlue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageUploadArea(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        String? imagePath;
        if (state is HomeIdle) imagePath = state.imagePath;
        if (state is HomeProcessing) imagePath = state.imagePath;
        if (state is HomeSuccess) imagePath = state.imagePath;
        if (state is HomeError) imagePath = state.imagePath;

        final hasImage = imagePath != null && imagePath.isNotEmpty;

        return Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 200),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryBlue.withValues(alpha: 0.1),
                AppColors.turquoise.withValues(alpha: 0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: hasImage ? AppColors.primaryBlue : Colors.grey.shade300,
              width: hasImage ? 2 : 1,
            ),
          ),
          child: hasImage
              ? _buildImagePreview(context, imagePath)
              : _buildEmptyUpload(context),
        );
      },
    );
  }

  Widget _buildEmptyUpload(BuildContext context) {
    return InkWell(
      onTap: () => _showImageSourceDialog(context),
      borderRadius: BorderRadius.circular(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.cloud_upload_outlined, size: 64, color: AppColors.primaryBlue),
          ),
          const SizedBox(height: 16),
          Text(AppConstants.uploadPrompt, style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSourceButton(
                icon: Icons.camera_alt,
                label: AppConstants.cameraButton,
                color: AppColors.primaryBlue,
                onTap: () => _pickImage(context, fromCamera: true),
              ),
              const SizedBox(width: 12),
              _buildSourceButton(
                icon: Icons.photo_library,
                label: AppConstants.galleryButton,
                color: AppColors.purple,
                onTap: () => _pickImage(context, fromCamera: false),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildImagePreview(BuildContext context, String imagePath) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(
            File(imagePath),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: AppColors.lightBlue,
              child: const Center(child: Icon(Icons.broken_image, size: 80, color: AppColors.primaryBlue)),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black.withValues(alpha: 0.3), Colors.transparent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: GestureDetector(
              onTap: () => context.read<HomeBloc>().add(ImageCleared()),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 20),
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: AppColors.success, borderRadius: BorderRadius.circular(20)),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text('Gorsel yuklendi',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            right: 12,
            child: GestureDetector(
              onTap: () => _showImageSourceDialog(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessTypeDropdown(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        ImageProcessType? selectedType;
        if (state is HomeIdle) selectedType = state.selectedProcessType;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<ImageProcessType>(
              value: selectedType,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primaryBlue),
              hint: Row(
                children: [
                  const Text('📋', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                  Text(AppConstants.selectProcessType,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                ],
              ),
              items: ImageProcessType.values.map((type) {
                return DropdownMenuItem<ImageProcessType>(
                  value: type,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(type.icon, style: const TextStyle(fontSize: 20)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(type.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.primaryNavy)),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 32, top: 2),
                        child: Text(type.subtitle,
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (ImageProcessType? value) {
                context.read<HomeBloc>().add(ProcessTypeSelected(value));
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        bool canStart = false;
        bool isLoading = false;
        if (state is HomeIdle) {
          canStart = state.selectedProcessType != null && state.imagePath != null;
        }
        if (state is HomeProcessing) {
          canStart = true;
          isLoading = true;
        }

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: canStart && !isLoading
                ? () => context.read<HomeBloc>().add(StartProcess())
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canStart ? AppColors.primaryNavy : Colors.grey.shade400,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: canStart ? 4 : 0,
            ),
            child: isLoading
                ? const SizedBox(
                    height: 24, width: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  )
                : const Text(AppConstants.startProcess,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        );
      },
    );
  }

  Widget _buildProgressIndicator(double progress) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 24, height: 24,
                child: CircularProgressIndicator(
                  value: progress, strokeWidth: 3, color: AppColors.primaryBlue,
                  backgroundColor: AppColors.lightBlue,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                progress < 0.3
                    ? AppConstants.processingImage
                    : progress < 0.7
                        ? AppConstants.extractingText
                        : progress < 0.9
                            ? AppConstants.generatingQuiz
                            : AppConstants.creatingFile,
                style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primaryNavy),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress, minHeight: 8, backgroundColor: AppColors.lightBlue,
              valueColor: AlwaysStoppedAnimation<Color>(
                  progress < 0.5 ? AppColors.primaryBlue : AppColors.turquoise),
            ),
          ),
          const SizedBox(height: 8),
          Text('${(progress * 100).toInt()}%', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildSuccessResult(BuildContext context, HomeSuccess state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                child: const Icon(Icons.check, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(AppConstants.successMessage,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.success)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (state.processType == ImageProcessType.quizCreate)
            _buildQuizResultContent(state)
          else if (state.processType == ImageProcessType.extractText)
            _buildTextResultContent(context, state)
          else
            _buildExportResultContent(context, state),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => context.read<HomeBloc>().add(ResetProcess()),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: AppColors.success),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Yeni Islem Yap',
                  style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizResultContent(HomeSuccess state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quiz basariyla olusturuldu! ${state.result.quizQuestions.length} soru',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
        const SizedBox(height: 12),
        ...List.generate(
          state.result.quizQuestions.length.clamp(0, 3),
          (index) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text('${index + 1}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(state.result.quizQuestions[index],
                      style: const TextStyle(fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextResultContent(BuildContext context, HomeSuccess state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12)),
          child: SelectableText(state.result.extractedText,
              style: const TextStyle(fontSize: 13, height: 1.5)),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: state.result.extractedText));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Metin kopyalandi!')),
              );
            },
            icon: const Icon(Icons.copy, size: 18),
            label: const Text('Metni Kopyala'),
          ),
        ),
      ],
    );
  }

  Widget _buildExportResultContent(BuildContext context, HomeSuccess state) {
    final isWord = state.processType == ImageProcessType.exportWord;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Icon(isWord ? Icons.description : Icons.table_chart, color: AppColors.primaryBlue, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(state.result.fileName ?? 'output',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text(state.result.fileSize ?? '',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  SharePlus.instance.share(
                    ShareParams(text: state.result.extractedText),
                  );
                },
                icon: const Icon(Icons.share, size: 18),
                label: const Text('Paylas'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: state.result.extractedText));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Metin kopyalandi!')),
                  );
                },
                icon: const Icon(Icons.copy, size: 18),
                label: const Text('Kopyala'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorResult(BuildContext context, HomeError state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
            child: const Icon(Icons.close, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 12),
          const Text('Hata Olustu',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.error)),
          const SizedBox(height: 8),
          Text(state.message,
              textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.read<HomeBloc>().add(ResetProcess()),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              child: const Text('Tekrar Dene'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, {required bool fromCamera}) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (picked != null && context.mounted) {
      context.read<HomeBloc>().add(ImagePicked(picked.path));
    }
  }

  void _showImageSourceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 20),
              const Text('Gorsel Kaynagi',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.camera_alt, color: AppColors.primaryBlue),
                ),
                title: const Text('Kamera'),
                subtitle: const Text('Fotograf cek'),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(context, fromCamera: true);
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.purple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.photo_library, color: AppColors.purple),
                ),
                title: const Text('Galeri'),
                subtitle: const Text('Mevcut bir gorsel sec'),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(context, fromCamera: false);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
