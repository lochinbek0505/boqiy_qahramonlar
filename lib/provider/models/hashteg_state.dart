import '../../models/hashteg_model.dart';

class HashtegState {
  final bool isLoading;
  final String? error;
  final List<HashtegModel> hashtegs;

  HashtegState({this.isLoading = false, this.error, this.hashtegs = const []});

  HashtegState copyWith({bool? isLoading, String? error, List<HashtegModel>? hashtegs}) {
    return HashtegState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hashtegs: hashtegs ?? this.hashtegs,
    );
  }
}
