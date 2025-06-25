import 'package:flutter_bloc/flutter_bloc.dart';
import 'profile_event.dart';
import 'profile_state.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/edit_profile_usecase.dart';
import '../../domain/usecases/search_profile_usecase.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase getProfileUseCase;
  final EditProfileUseCase editProfileUseCase;
  final SearchProfileUseCase searchProfileUseCase;

  ProfileBloc({
    required this.getProfileUseCase,
    required this.editProfileUseCase,
    required this.searchProfileUseCase,
  }) : super(ProfileInitial()) {
    on<GetProfileEvent>((event, emit) async {
      emit(ProfileLoading());
      try {
        final profile = await getProfileUseCase(event.userId);
        emit(ProfileLoaded(profile));
      } catch (e) {
        emit(ProfileError(e.toString()));
      }
    });
    on<EditProfileEvent>((event, emit) async {
      emit(ProfileLoading());
      try {
        final profile = await editProfileUseCase(event.data);
        emit(ProfileLoaded(profile));
      } catch (e) {
        emit(ProfileError(e.toString()));
      }
    });
    on<SearchProfileEvent>((event, emit) async {
      emit(ProfileLoading());
      try {
        final profiles = await searchProfileUseCase(event.query);
        emit(ProfileListLoaded(profiles));
      } catch (e) {
        emit(ProfileError(e.toString()));
      }
    });
  }
}
