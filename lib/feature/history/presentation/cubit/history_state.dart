import 'package:saint_paul/core/models/tayo_history_model.dart';

class HistoryState {}

class HistoryInitialState extends HistoryState {}

class HistoryLoadingState extends HistoryState {}

class HistoryLoadedState extends HistoryState {
  final List<TayoHistoryModel>? historyList;

  HistoryLoadedState({this.historyList});
}

class HistoryErrorState extends HistoryState {
  final String? message;

  HistoryErrorState({this.message});
}
