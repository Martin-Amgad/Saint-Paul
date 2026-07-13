class AuthState {}

class AuthInitialState extends AuthState {}

class AuthloadingState extends AuthState {}

class AuthSuccessState extends AuthState {
  String? role;
  String? message;

  AuthSuccessState({this.role, this.message});
}

class AuthChurchLoadedState extends AuthState {
  final Map<String, dynamic>? churches;

  AuthChurchLoadedState({this.churches});
}

class AuthResetPasswordSuccessState extends AuthState {
  final String message;

  AuthResetPasswordSuccessState(this.message);
}

class AuthErrorState extends AuthState {
  final String error;

  AuthErrorState(this.error);
}
