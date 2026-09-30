import '../../models/poems_model.dart';

class PoemsState {
  final bool isLoading;
  final String? error;
  final List<PoemsModel> poems;
  final List<PoemsModel> authorPoems;
  final List<PoemsModel> mostReadPoems;
  final PoemsModel? selectedPoem;

  PoemsState({
    this.isLoading = false,
    this.error,
    this.poems = const [],
    this.authorPoems = const [],
    this.mostReadPoems = const [],
    this.selectedPoem,
  });

  PoemsState copyWith({
    bool? isLoading,
    String? error,
    List<PoemsModel>? poems,
    List<PoemsModel>? authorPoems,
    List<PoemsModel>? mostReadPoems,
    PoemsModel? selectedPoem,
    bool clearError = false,
  }) {
    return PoemsState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      poems: poems ?? this.poems,
      authorPoems: authorPoems ?? this.authorPoems,
      mostReadPoems: mostReadPoems ?? this.mostReadPoems,
      selectedPoem: selectedPoem ?? this.selectedPoem,
    );
  }
}
