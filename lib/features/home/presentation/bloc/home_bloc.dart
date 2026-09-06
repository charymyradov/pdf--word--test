import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/process_repository.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final ProcessRepository _repository;
  final String deviceId;

  HomeBloc({required this._repository, required this.deviceId})
      : super(HomeInitial()) {
    on<ImagePicked>(_onImagePicked);
    on<ImageCleared>(_onImageCleared);
    on<ProcessTypeSelected>(_onProcessTypeSelected);
    on<StartProcess>(_onStartProcess);
    on<ResetProcess>(_onResetProcess);
  }

  void _onImagePicked(ImagePicked event, Emitter<HomeState> emit) {
    final currentState = state;
    if (currentState is HomeIdle) {
      emit(HomeIdle(
        selectedProcessType: currentState.selectedProcessType,
        imagePath: event.imagePath,
      ));
    } else {
      emit(HomeIdle(imagePath: event.imagePath));
    }
  }

  void _onImageCleared(ImageCleared event, Emitter<HomeState> emit) {
    emit(HomeIdle());
  }

  void _onProcessTypeSelected(ProcessTypeSelected event, Emitter<HomeState> emit) {
    final currentState = state;
    final imagePath = currentState is HomeIdle ? currentState.imagePath : null;
    emit(HomeIdle(selectedProcessType: event.type, imagePath: imagePath));
  }

  Future<void> _onStartProcess(StartProcess event, Emitter<HomeState> emit) async {
    final currentState = state;
    if (currentState is! HomeIdle || currentState.selectedProcessType == null) return;
    if (currentState.imagePath == null || currentState.imagePath!.isEmpty) return;

    final processType = currentState.selectedProcessType!;
    final imagePath = currentState.imagePath!;

    for (int i = 0; i <= 100; i += 5) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (emit.isDone) return;
      emit(HomeProcessing(progress: i / 100, processType: processType, imagePath: imagePath));
    }

    try {
      final result = await _repository.processImage(
        imagePath: imagePath,
        processType: processType,
      );

      await _repository.saveExtraction(
        deviceId: deviceId,
        extractedText: result.extractedText,
        resultType: result.resultType.name,
      );

      emit(HomeSuccess(result: result, processType: processType, imagePath: imagePath));
    } catch (e) {
      emit(HomeError(message: 'Bir hata olustu: ${e.toString()}', imagePath: imagePath));
    }
  }

  void _onResetProcess(ResetProcess event, Emitter<HomeState> emit) {
    emit(HomeIdle());
  }
}
