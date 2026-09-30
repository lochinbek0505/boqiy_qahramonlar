import '../../models/history_model.dart';

class HistoryState {
  final bool isLoading;
  final String? error;
  final List<HistoryModel> histories;
  final List<HistoryModel> authorHistories;
  final List<HistoryModel> mostReadHistories;
  final HistoryModel? selectedHistory;

  HistoryState({
    this.isLoading = false,
    this.error,
    this.histories = const [],
    this.authorHistories = const [],
    this.mostReadHistories = const [],
    this.selectedHistory,
  });

  HistoryState copyWith({
    bool? isLoading,
    String? error,
    List<HistoryModel>? histories,
    List<HistoryModel>? authorHistories,
    List<HistoryModel>? mostReadHistories,
    HistoryModel? selectedHistory,
    bool clearError = false,
  }) {
    return HistoryState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      histories: histories ?? this.histories,
      authorHistories: authorHistories ?? this.authorHistories,
      mostReadHistories: mostReadHistories ?? this.mostReadHistories,
      selectedHistory: selectedHistory ?? this.selectedHistory,
    );
  }
}
