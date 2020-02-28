# google_polyline_algorithm

![Build](https://github.com/marchdev-tk/google_polyline_algorithm/workflows/build/badge.svg)
[![codecov](https://codecov.io/gh/marchdev-tk/google_polyline_algorithm/branch/master/graph/badge.svg)](https://codecov.io/gh/marchdev-tk/google_polyline_algorithm)
[![Pub](https://img.shields.io/pub/v/google_polyline_algorithm.svg)](https://pub.dartlang.org/packages/google_polyline_algorithm)
![GitHub](https://img.shields.io/github/license/marchdev-tk/google_polyline_algorithm)
![GitHub stars](https://img.shields.io/github/stars/marchdev-tk/google_polyline_algorithm?style=social)

Dart implementation of Googles Polyline Encoding lossy compression Algorithm.

## Getting Started

This package adds following methods to work with Googles Polyline Encoding Algorithm:

* `encodePoint(num current, {num previous = 0, int accuracyExponent = 5})` encodes a single coordinate

* `encodePolyline(List<List<num>> coordinates, {int accuracyExponent = 5})` encodes a list of coordinates into an encoded polyline stirng

* `decodePolyline(String polyline, {int accuracyExponent = 5})` decodes an encoded polyline string into a list of coordinates

## Examples

```dart
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';

final coord = encodePoint(-179.9832104);
print(coord);
// output is `~oia@'

final coords = encodePolyline([
  [38.5, -120.2],
  [40.7, -120.95],
  [43.252, -126.453],
]);
print(coords);
// output is `_p~iF~ps|U_ulLnnqC_mqNvxq`@'

final polyline = decodePolyline('_p~iF~ps|U_ulLnnqC_mqNvxq`@');
print(polyline);
// output is [[38.5, -120.2],[40.7, -120.95],[43.252, -126.453],]
```
