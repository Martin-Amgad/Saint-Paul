class AuthState {}

class AuthInitialState extends AuthState {}

class AuthloadingState extends AuthState {}

class AuthSuccessState extends AuthState {
  String? role;
  AuthSuccessState({this.role});
}

class AuthErrorState extends AuthState {
  final String error;

  AuthErrorState(this.error);
}
