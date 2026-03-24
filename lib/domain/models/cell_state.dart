class CellState {
  final int value;
  final bool isGiven;
  final bool isError;

  const CellState({
    required this.value,
    required this.isGiven,
    required this.isError,
  });

  CellState copyWith({int? value, bool? isError}) {
    return CellState(
      value: value ?? this.value,
      isGiven: isGiven,
      isError: isError ?? this.isError,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'isGiven': isGiven,
      'isError': isError,
    };
  }

  factory CellState.fromJson(Map<String, dynamic> json) {
    return CellState(
      value: json['value'] as int,
      isGiven: json['isGiven'] as bool,
      isError: json['isError'] as bool,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CellState) return false;
    return value == other.value &&
        isGiven == other.isGiven &&
        isError == other.isError;
  }

  @override
  int get hashCode => Object.hash(value, isGiven, isError);
}
