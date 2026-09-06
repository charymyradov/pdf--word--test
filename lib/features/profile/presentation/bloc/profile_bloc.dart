import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/profile_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _repository;
  final String deviceId;

  ProfileBloc({required ProfileRepository repository, required this.deviceId})
      : _repository = repository,
        super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<ToggleDarkMode>(_onToggleDarkMode);
  }

  Future<void> _onLoadProfile(LoadProfile event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      final profile = await _repository.getProfile(deviceId);
      emit(ProfileLoaded(profile: profile));
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  Future<void> _onToggleDarkMode(ToggleDarkMode event, Emitter<ProfileState> emit) async {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    final newDarkMode = !currentState.profile.isDarkMode;
    await _repository.toggleDarkMode(deviceId, newDarkMode);
    emit(ProfileLoaded(profile: currentState.profile.copyWith(isDarkMode: newDarkMode)));
  }
}
