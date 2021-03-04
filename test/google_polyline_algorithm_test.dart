// Copyright (c) 2021, the MarchDev Toolkit project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test/test.dart';
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';

void main() {
  group('Google Polyline Algorithm Tests', () {
    test('encodePoint test', () {
      final actual = encodePoint(-179.9832104);
      expect(actual, '`~oia@');
    });

    const rawCoords = [
      [38.5, -120.2],
      [40.7, -120.95],
      [43.252, -126.453],
    ];
    const encodedCoords = '_p~iF~ps|U_ulLnnqC_mqNvxq`@';

    test('encodePolyline test', () {
      final actual = encodePolyline(rawCoords);
      expect(actual, encodedCoords);
    });

    test('decodePolyline test', () {
      final actual = decodePolyline(encodedCoords);
      expect(actual, rawCoords);
    });
  });
}
