class PuzzleData {
  final String id;
  final List<int> givens;
  final List<int> solution;

  const PuzzleData({
    required this.id,
    required this.givens,
    required this.solution,
  })  : assert(givens.length == 81, 'givens must have exactly 81 elements'),
        assert(solution.length == 81, 'solution must have exactly 81 elements');

  factory PuzzleData.fromJson(Map<String, dynamic> json) {
    final givens = List<int>.from(json['givens'] as List);
    final solution = List<int>.from(json['solution'] as List);
    if (givens.length != 81) {
      throw ArgumentError(
        'givens must have exactly 81 elements, got ${givens.length}',
      );
    }
    if (solution.length != 81) {
      throw ArgumentError(
        'solution must have exactly 81 elements, got ${solution.length}',
      );
    }
    return PuzzleData(
      id: json['id'] as String,
      givens: givens,
      solution: solution,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'givens': givens,
      'solution': solution,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PuzzleData) return false;
    return id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}
