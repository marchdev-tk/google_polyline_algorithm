// Copyright (c) 2021, the MarchDev Toolkit project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';

void main() {
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
}
