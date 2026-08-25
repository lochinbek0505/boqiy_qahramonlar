import '../../models/history_model.dart';

class HistoryState {
  final bool isLoading;
  final String? error;
  final List<HistoryModel> histories;
  final HistoryModel? selectedHistory;

  HistoryState({
    this.isLoading = false,
    this.error,
    this.histories = const [],
    this.selectedHistory,
  });

  HistoryState copyWith({
    bool? isLoading,
    String? error,
    List<HistoryModel>? histories,
    HistoryModel? selectedHistory,
    bool clearError = false,
  }) {
    return HistoryState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      histories: histories ?? this.histories,
      selectedHistory: selectedHistory ?? this.selectedHistory,
    );
  }
}