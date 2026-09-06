import '../../../../core/enums/app_enums.dart';

abstract class HomeEvent {}

class ImagePicked extends HomeEvent {
  final String imagePath;
  ImagePicked(this.imagePath);
}

class ImageCleared extends HomeEvent {}

class ProcessTypeSelected extends HomeEvent {
  final ImageProcessType? type;
  ProcessTypeSelected(this.type);
}

class StartProcess extends HomeEvent {}

class ResetProcess extends HomeEvent {}
