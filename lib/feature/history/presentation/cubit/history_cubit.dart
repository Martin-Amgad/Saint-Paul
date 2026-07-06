import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saint_paul/core/models/tayo_history_model.dart';
import 'package:saint_paul/feature/history/data/repo/history_repo.dart';
import 'package:saint_paul/feature/history/presentation/cubit/history_state.dart';

class HistoryCubit extends Cubit<HistoryState> {
  HistoryCubit() : super(HistoryInitialState());

  Future<void> loadTayoHistory(String studentId) async {
    emit(HistoryLoadingState());
    try {
      var historyList = await HistoryRepo.loadTayoHistory(studentId);

      emit(HistoryLoadedState(historyList: historyList));
    } catch (e) {
      emit(
        HistoryErrorState(
          message: 'حدث خطأ أثناء تحميل سجل التاي. الرجاء المحاولة مرة أخرى.',
        ),
      );
    }
  }

  Future<void> loadPointsHistory(String groupId) async {
    emit(HistoryLoadingState());
    try {
      var historyList = await HistoryRepo.loadPointsHistory(groupId);

      emit(HistoryLoadedState(historyList: historyList));
    } catch (e) {
      emit(
        HistoryErrorState(
          message: 'حدث خطأ أثناء تحميل سجل التاي. الرجاء المحاولة مرة أخرى.',
        ),
      );
    }
  }
}
