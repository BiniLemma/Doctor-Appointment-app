import 'package:charge_station_finder/domain/auth/models/signInFormForm.dart';
import 'package:charge_station_finder/utils/either.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/auth/models/noReturn.dart';
import '../../domain/auth/models/signUpForm.dart';
import '../../domain/contracts/IAuthRepository.dart';
import '../../infrastructure/dto/userAuthCredential.dart';
import '../core/failure.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final IAuthenticationRepository authRepository;

  AuthenticationBloc({required this.authRepository})
      : super(AuthenticationStateInitial()) {
    on<SignUpEvent>(_onSignUp);
    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_onLogout);
    on<DeleteAccountEvent>(_onDeleteAccount);
    on<GetUserAuthCredentialEvent>(_onGetUser);
  }

  AuthenticationState get initialState => AuthenticationStateInitial();

  void _onLogin(LoginEvent event, Emitter<AuthenticationState> emit) async {
    emit(AuthenticationLoading());
    final failureOrAuthCredential = await authRepository.login(
      signInForm: event.signInForm,
    );
    debugPrint(failureOrAuthCredential.toString());
    emit(_eitherLoginOrError(failureOrAuthCredential));
    // emit(Authenticated());
  }

  void _onDeleteAccount(
      DeleteAccountEvent event, Emitter<AuthenticationState> emit) async {
    emit(DeletingAccount());
    final failureOrNoReturns = await authRepository.deleteAccount();
    failureOrNoReturns.fold((l) => emit(DeleteAccountFailed()), (r) {
      emit(DeleteAccountSucceed());
      emit(AuthenticationStateUnauthenticated());
    });
  }

  void _onSignUp(SignUpEvent event, Emitter<AuthenticationState> emit) async {
    emit(AuthenticationLoading());
    final failureOrNoReturns = await authRepository.signUp(
      signUpForm: event.signUpForm,
    );
    emit(_eitherNoReturnsOrError(failureOrNoReturns));
  }

  void _onLogout(LogoutEvent event, Emitter<AuthenticationState> emit) async {
    emit(AuthenticationLoading());
    final failureOrNoReturns = await authRepository.logout();
    failureOrNoReturns.fold((l) => emit(LogoutFailed()), (r) {
      emit(LogoutSucceed());
      emit(AuthenticationStateUnauthenticated());
    });
  }

  void _onGetUser(GetUserAuthCredentialEvent event,
      Emitter<AuthenticationState> emit) async {
    final failureOrAuthCredential =
        await authRepository.getUserAuthCredential();
    emit(_eitherAuthenticatedOrUnAuthenticated(failureOrAuthCredential));
  }

  AuthenticationState _eitherAuthenticatedOrUnAuthenticated(
      Either<Failure, UserData> failureOrAuthCredential) {
    return failureOrAuthCredential.fold(
        (failure) => AuthenticationStateUnauthenticated(),
        (authCredential) => authCredential.user.role == 'admin'
            ? AuthenticationStateAdminAuthenticated(userData: authCredential)
            : authCredential.user.role == 'user'
                ? AuthenticationStateUserAuthenticated(userData: authCredential)
                : AuthenticationStateProviderAuthenticated(
                    userData: authCredential));
  }

  AuthenticationState _eitherLoginOrError(
      Either<Failure, UserData> failureOrAuthCredential) {
    return failureOrAuthCredential.fold(
        (failure) =>
            AuthenticationStateError(message: _mapFailureToMessage(failure)),
        (authCredential) => authCredential.user.role == 'admin'
            ? AuthenticationStateAdminAuthenticated(userData: authCredential)
            : authCredential.user.role == 'user'
                ? AuthenticationStateUserAuthenticated(userData: authCredential)
                : AuthenticationStateProviderAuthenticated(
                    userData: authCredential));
  }

  AuthenticationState _eitherLogoutOrError(
      Either<Failure, NoReturns> failureOrNoReturn) {
    return failureOrNoReturn.fold(
      (failure) =>
          AuthenticationStateError(message: _mapFailureToMessage(failure)),
      (_) => AuthenticationStateUnauthenticated(),
    );
  }

  AuthenticationState _eitherNoReturnsOrError(
      Either<Failure, NoReturns> failureOrNoReturns) {
    return failureOrNoReturns.fold(
      (failure) =>
          AuthenticationStateError(message: _mapFailureToMessage(failure)),
      (noReturns) => AuthenticationStateLoadedNoReturns(noReturns: noReturns),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    return failure.toString();
  }
}
