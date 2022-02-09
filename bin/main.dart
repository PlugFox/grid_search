/* 
 * The Grid Search
 * https://www.hackerrank.com/challenges/the-grid-search/problem
 * https://gist.github.com/PlugFox/ac541a35262c3a7ace7f6a611780aefe
 * https://dartpad.dev/ac541a35262c3a7ace7f6a611780aefe
 */

import 'dart:collection';

import 'package:meta/meta.dart';

void main(List<String> arguments) {
  final offset = measure(() => table.matrix.search(pattern.matrix));
  print(offset == null ? 'Entry not found' : 'Entry found: $offset');
}

T measure<T extends Object?>(T Function() fn) {
  final stopwatch = Stopwatch()..start();
  try {
    return fn();
  } finally {
    print('Elapsed: ${(stopwatch..stop()).elapsedMilliseconds} ms');
  }
}

extension on String {
  Matrix get matrix => Matrix.fromString(this);
}

const String table = '''
400453592126560
474386082879648
522356951189169
887137475874964
252814174887822
502787160667486
075975207693780
511799789562806
404007454272504
549043809916080
962410809534811
445893523737475
768705303214174
650629270887160
''';

const String pattern = '''
37475
14174
87160
''';

/// Двумерный массив целых чисел
/// 0 1 2 3 4
/// 1
/// 2
/// 3
/// 4
@immutable
class Matrix extends ListBase<List<int>> {
  Matrix.from2DArray(List<List<int>> matrix)
      : _innerData = matrix,
        width = matrix[0].length,
        height = matrix.length;

  factory Matrix.fromString(String matrix) => Matrix.from2DArray(
        matrix
            .split('\n')
            .map<List<int>>(
              (row) => row.codeUnits
                  .where((code) => code > 47 && code < 58)
                  .map<int>((code) => code - 48)
                  .toList(growable: false),
            )
            .where((row) => row.isNotEmpty)
            .toList(growable: false),
      );

  final List<List<int>> _innerData;

  /// Поиск вхождения [pattern] в [table]
  Offset? search(Matrix pattern) {
    final table = this;
    if (table.isEmpty || pattern.isEmpty) return null;
    if (table.width < pattern.width) return null;
    if (table.height < pattern.height) return null;

    final constraint = Offset(
      dx: table.width - pattern.width,
      dy: table.height - pattern.height,
    );

    for (var col = 0; col <= constraint.dy; col++) {
      for (var row = 0; row <= constraint.dx; row++) {
        if (table.compare(row, col, pattern)) {
          return Offset(dx: row, dy: col);
        }
      }
    }

    return null;
  }

  /// Содержит ли другую матрицу по указанному отступу
  bool compare(int dx, int dy, Matrix other) {
    try {
      final width = other.width;
      final height = other.height;
      for (var i = 0; i < height; i++) {
        for (var j = 0; j < width; j++) {
          if (_innerData[dy + i][dx + j] != other[i][j]) {
            return false;
          }
        }
      }
      // ignore: avoid_catching_errors
    } on RangeError catch (error, stackTrace) {
      Error.throwWithStackTrace(
        RangeError(
          'При сравнении двух матриц произошел выход за пределы исходной матрицы'
          '${error.message}',
        ),
        stackTrace,
      );
    }

    return true;
  }

  /// Ширина матрицы
  final int width;

  /// Высота матрицы
  final int height;

  @override
  int get length => _innerData.length;

  @override
  set length(int value) => throw UnsupportedError('Immutable!');

  @override
  List<int> operator [](int index) => _innerData[index];

  @override
  void operator []=(int index, List<int> value) =>
      throw UnsupportedError('Immutable!');

  @override
  String toString() => '$width x $height';
}

@immutable
class Offset {
  const Offset({
    required final this.dx,
    required final this.dy,
  });

  final int dx;
  final int dy;

  @override
  String toString() => '$dx, $dy';

  @override
  int get hashCode => dx ^ dy;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Offset && other.dx == dx && other.dy == dy);
}
