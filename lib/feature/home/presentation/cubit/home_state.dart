class HomeState {}

class Homeinit extends HomeState {}

class HomeLoadingState extends HomeState {}

class HomeTayoLoadSuccessState extends HomeState {
  final Map<String, dynamic> tayo;
  HomeTayoLoadSuccessState({this.tayo = const {}});
}

class HomeSuccessState extends HomeState {
  final String? message;
  HomeSuccessState({this.message});
}

class HomeSuccessStateForTakenAt extends HomeState {
  final String? message;
  HomeSuccessStateForTakenAt({this.message});
}

class StudentYearLoaded extends HomeState {
  final String year;
  StudentYearLoaded({required this.year});
}

class HomeErrorState extends HomeState {
  final String message;
  HomeErrorState({required this.message});
}
