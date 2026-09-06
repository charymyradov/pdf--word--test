import '../../../../core/enums/app_enums.dart';
import '../../domain/entities/process_result.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeIdle extends HomeState {
  final ImageProcessType? selectedProcessType;
  final String? imagePath;

  HomeIdle({this.selectedProcessType, this.imagePath});
}

class HomeProcessing extends HomeState {
  final double progress;
  final ImageProcessType processType;
  final String? imagePath;

  HomeProcessing({required this.progress, required this.processType, this.imagePath});
}

class HomeSuccess extends HomeState {
  final ProcessResult result;
  final ImageProcessType processType;
  final String? imagePath;

  HomeSuccess({required this.result, required this.processType, this.imagePath});
}

class HomeError extends HomeState {
  final String message;
  final String? imagePath;

  HomeError({required this.message, this.imagePath});
}
