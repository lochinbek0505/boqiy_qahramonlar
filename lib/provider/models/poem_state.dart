import '../../models/poems_model.dart';

class PoemsState {
  final bool isLoading;
  final String? error;
  final List<PoemsModel> poems;
  final PoemsModel? selectedPoem; // Bitta she'rni saqlash uchun

  PoemsState({
    this.isLoading = false,
    this.error,
    this.poems = const [],
    this.selectedPoem,
  });

  PoemsState copyWith({
    bool? isLoading,
    String? error,
    List<PoemsModel>? poems,
    PoemsModel? selectedPoem,
    bool clearError = false, // Xatolikni null qilish uchun maxsus belgi
  }) {
    return PoemsState(
      isLoading: isLoading ?? this.isLoading,
      // Agar clearError true bo'lsa, xatolikni null qilamiz, yo'qsa eskisini saqlaymiz yoki yangisini yozamiz
      error: clearError ? null : (error ?? this.error),
      poems: poems ?? this.poems,
      selectedPoem: selectedPoem ?? this.selectedPoem,
    );
  }
}