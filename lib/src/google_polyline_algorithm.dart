// Copyright (c) 2021, the MarchDev Toolkit project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert' show ascii;
import 'dart:math' as math show pow;

/// Polyline encoding is a lossy compression algorithm that allows you to
/// store a series of coordinates as a single string. Point coordinates
/// are encoded using signed values. If you only have a few static points,
/// you may also wish to use the interactive
/// [polyline encoding utility](https://developers.google.com/maps/documentation/utilities/polylineutility?hl=en).
///
/// The encoding process converts a binary value into a series of character
/// codes for ASCII characters using the familiar base64 encoding scheme:
/// to ensure proper display of these characters, encoded values are summed
/// with 63 (the ASCII character '?') before converting them into ASCII.
/// The algorithm also checks for additional character codes for a given
/// point by checking the least significant bit of each byte group; if this
/// bit is set to 1, the point is not yet fully formed and additional data
/// must follow.
///
/// Additionally, to conserve space, *`points only include the offset from
/// the previous point`* (except of course for the first point). All points
/// are encoded in Base64 as signed integers, as latitudes and longitudes
/// are signed values. The encoding format within a polyline needs to
/// represent two coordinates representing latitude and longitude to a
/// reasonable precision. Given a maximum longitude of +/- 180 degrees to
/// a precision of 5 decimal places (180.00000 to -180.00000), this results
/// in the need for a 32 bit signed binary integer value.
///
/// Note that the backslash is interpreted as an escape character within
/// string literals. Any output of this utility should convert backslash
/// characters to double-backslashes within string literals.
///
/// The steps for encoding such a signed value are specified below.
///
/// 1. Take the initial signed value:
///
///   `-179.9832104`
///
/// 2. Take the decimal value and multiply it by 1e5, rounding the result:
///
///   `-17998321`
///
/// 3. Convert the decimal value to binary. Note that a negative value must
/// be calculated using its two's complement by inverting the binary value
/// and adding one to the result:
///
///   `00000001 00010010 10100001 11110001`
///
///   `11111110 11101101 01011110 00001110`
///
///   `11111110 11101101 01011110 00001111`
///
/// 4. Left-shift the binary value one bit:
///
///   `11111101 11011010 10111100 00011110`
///
/// 5. If the original decimal value is negative, invert this encoding:
///
///   `00000010 00100101 01000011 11100001`
///
/// 6. Break the binary value out into 5-bit chunks (starting from the
/// right hand side):
///
///   `00001 00010 01010 10000 11111 00001`
///
/// 7. Place the 5-bit chunks into reverse order:
///
///   `00001 11111 10000 01010 00010 00001`
///
/// 8. OR each value with 0x20 if another bit chunk follows:
///
///   `100001 111111 110000 101010 100010 000001`
///
/// 9. Convert each value to decimal:
///
///   `33 63 48 42 34 1`
///
/// 10. Add 63 to each value:
///
///   `96 126 111 105 97 64`
///
/// 11. Convert each value to its ASCII equivalent:
///
///   ``` `~oia@ ```
///
/// The table below shows some examples of encoded points, showing the
/// encodings as a series of offsets from previous points.
///
/// ## Example
///
/// Points: (38.5, -120.2), (40.7, -120.95), (43.252, -126.453)
///
/// | Latitude | Longitude | Latitude in E5 | Longitude in E5 | Change In Latitude | Change In Longitude | Encoded Latitude | Encoded Longitude | Encoded Point |
/// | :------: | :-------: | :------------: | :-------------: | :----------------: | :-----------------: | :--------------: | :---------------: | :-----------: |
/// | 38.5     | -120.2    | 3850000        | -12020000       |	+3850000           | -12020000           | _p~iF            |	~ps|U             |	_p~iF~ps|U    |
/// | 40.7	   | -120.95	 | 4070000	      | -12095000	      | +220000            | -75000	             | _ulL             | nnqC	            | _ulLnnqC      |
/// | 43.252   | -126.453  | 4325200	      | -12645300       |	+255200	           | -550300	           | _mqN             |	vxq`@	            | _mqNvxq`@     |
///
/// Encoded polyline: ```_p~iF~ps|U_ulLnnqC_mqNvxq`@```.
///
/// For more info visit [Encoded Polyline Algorithm Format](https://developers.google.com/maps/documentation/utilities/polylinealgorithm?hl=en)
String encodePoint(num current, {num previous = 0, int accuracyExponent = 5}) {
  assert(() {
    if (accuracyExponent < 1) {
      throw ArgumentError.value(accuracyExponent, 'accuracyExponent',
          'Location accuracy exponent cannot be less than 1');
    }

    if (accuracyExponent > 9) {
      throw ArgumentError.value(
          accuracyExponent,
          'accuracyExponent',
          'Location accuracy exponent cannot be greater than 9.\n\n'
              'For more info why (cannot be greater than 9), refer to table of what each digit '
              'in a decimal degree signifies:\n'
              ' * The sign tells us whether we are north or south, east or west on the globe.\n'
              ' * A nonzero hundreds digit tells us we\'re using longitude, not latitude!\n'
              ' * The tens digit gives a position to about 1,000 kilometers. It gives us useful '
              'information about what continent or ocean we are on.\n'
              ' * The units digit (one decimal degree) gives a position up to 111 kilometers (60 '
              'nautical miles, about 69 miles). It can tell us roughly what large state or country '
              'we are in.\n'
              ' * The first decimal place is worth up to 11.1 km: it can distinguish the position '
              'of one large city from a neighboring large city.\n'
              ' * The second decimal place is worth up to 1.1 km: it can separate one village from '
              'the next.\n'
              ' * The third decimal place is worth up to 110 m: it can identify a large agricultural '
              'field or institutional campus.\n'
              ' * The fourth decimal place is worth up to 11 m: it can identify a parcel of land. It '
              'is comparable to the typical accuracy of an uncorrected GPS unit with no interference.\n'
              ' * The fifth decimal place is worth up to 1.1 m: it distinguish trees from each other. '
              'Accuracy to this level with commercial GPS units can only be achieved with differential '
              'correction.\n'
              ' * The sixth decimal place is worth up to 0.11 m: you can use this for laying out '
              'structures in detail, for designing landscapes, building roads. It should be more '
              'than good enough for tracking movements of glaciers and rivers. This can be achieved '
              'by taking painstaking measures with GPS, such as differentially corrected GPS.\n'
              ' * The seventh decimal place is worth up to 11 mm: this is good for much surveying '
              'and is near the limit of what GPS-based techniques can achieve.\n'
              ' * The eighth decimal place is worth up to 1.1 mm: this is good for charting motions '
              'of tectonic plates and movements of volcanoes. Permanent, corrected, constantly-running '
              'GPS base stations might be able to achieve this level of accuracy.\n'
              ' * The ninth decimal place is worth up to 110 microns: we are getting into the range '
              'of microscopy. For almost any conceivable application with earth positions, this is '
              'overkill and will be more precise than the accuracy of any surveying device.\n'
              ' * Ten or more decimal places indicates a computer or calculator was used and that no '
              'attention was paid to the fact that the extra decimals are useless. Be careful, because '
              'unless you are the one reading these numbers off the device, this can indicate low '
              'quality processing!');
    }

    return true;
  }());

  final accuracyMultiplier = math.pow(10, accuracyExponent);

  int curr = (current * accuracyMultiplier + 0.5).floor();
  int prev = (previous * accuracyMultiplier + 0.5).floor();
  int value = curr - prev;

  /// Left-shift the `value` for one bit.
  value <<= 1;
  if (curr - prev < 0) {
    /// Inverting `value` if it is negative.
    value = ~value;
  }

  String point = '';

  /// Iterating while value is grater or equal of `32-bits` size
  while (value >= 0x20) {
    /// `AND` each `value` with `0x1f` to get 5-bit chunks.
    /// Then `OR` each `value` with `0x20` as per algorithm.
    /// Then add `63` to each `value` as per algorithm.
    point += String.fromCharCodes([(0x20 | (value & 0x1f)) + 63]);

    /// Rigth-shift the `value` for 5 bits
    value >>= 5;
  }

  point += ascii.decode([value + 63]);

  return point;
}

/// Encodes `List<List<num>>` of [coordinates] into a `String` via
/// [Encoded Polyline Algorithm Format](https://developers.google.com/maps/documentation/utilities/polylinealgorithm?hl=en)
///
/// For mode detailed info about encoding refer to [encodePoint].
String encodePolyline(List<List<num>> coordinates, {int accuracyExponent = 5}) {
  assert(() {
    if (accuracyExponent < 1) {
      throw ArgumentError.value(accuracyExponent, 'accuracyExponent',
          'Location accuracy exponent cannot be less than 1');
    }

    if (accuracyExponent > 9) {
      throw ArgumentError.value(
          accuracyExponent,
          'accuracyExponent',
          'Location accuracy exponent cannot be greater than 9.\n\n'
              'For more info why (cannot be greater than 9), refer to table of what each digit '
              'in a decimal degree signifies:\n'
              ' * The sign tells us whether we are north or south, east or west on the globe.\n'
              ' * A nonzero hundreds digit tells us we\'re using longitude, not latitude!\n'
              ' * The tens digit gives a position to about 1,000 kilometers. It gives us useful '
              'information about what continent or ocean we are on.\n'
              ' * The units digit (one decimal degree) gives a position up to 111 kilometers (60 '
              'nautical miles, about 69 miles). It can tell us roughly what large state or country '
              'we are in.\n'
              ' * The first decimal place is worth up to 11.1 km: it can distinguish the position '
              'of one large city from a neighboring large city.\n'
              ' * The second decimal place is worth up to 1.1 km: it can separate one village from '
              'the next.\n'
              ' * The third decimal place is worth up to 110 m: it can identify a large agricultural '
              'field or institutional campus.\n'
              ' * The fourth decimal place is worth up to 11 m: it can identify a parcel of land. It '
              'is comparable to the typical accuracy of an uncorrected GPS unit with no interference.\n'
              ' * The fifth decimal place is worth up to 1.1 m: it distinguish trees from each other. '
              'Accuracy to this level with commercial GPS units can only be achieved with differential '
              'correction.\n'
              ' * The sixth decimal place is worth up to 0.11 m: you can use this for laying out '
              'structures in detail, for designing landscapes, building roads. It should be more '
              'than good enough for tracking movements of glaciers and rivers. This can be achieved '
              'by taking painstaking measures with GPS, such as differentially corrected GPS.\n'
              ' * The seventh decimal place is worth up to 11 mm: this is good for much surveying '
              'and is near the limit of what GPS-based techniques can achieve.\n'
              ' * The eighth decimal place is worth up to 1.1 mm: this is good for charting motions '
              'of tectonic plates and movements of volcanoes. Permanent, corrected, constantly-running '
              'GPS base stations might be able to achieve this level of accuracy.\n'
              ' * The ninth decimal place is worth up to 110 microns: we are getting into the range '
              'of microscopy. For almost any conceivable application with earth positions, this is '
              'overkill and will be more precise than the accuracy of any surveying device.\n'
              ' * Ten or more decimal places indicates a computer or calculator was used and that no '
              'attention was paid to the fact that the extra decimals are useless. Be careful, because '
              'unless you are the one reading these numbers off the device, this can indicate low '
              'quality processing!');
    }

    return true;
  }());

  if (coordinates.isEmpty) return '';

  String polyline =
      encodePoint(coordinates[0][0], accuracyExponent: accuracyExponent) +
          encodePoint(coordinates[0][1], accuracyExponent: accuracyExponent);

  for (var i = 1; i < coordinates.length; i++) {
    polyline += encodePoint(coordinates[i][0],
        previous: coordinates[i - 1][0], accuracyExponent: accuracyExponent);
    polyline += encodePoint(coordinates[i][1],
        previous: coordinates[i - 1][1], accuracyExponent: accuracyExponent);
  }

  return polyline;
}

/// Decodes [polyline] `String` via inverted
/// [Encoded Polyline Algorithm](https://developers.google.com/maps/documentation/utilities/polylinealgorithm?hl=en)
List<List<num>> decodePolyline(String polyline, {int accuracyExponent = 5}) {
  final accuracyMultiplier = math.pow(10, accuracyExponent);
  final List<List<num>> coordinates = [];

  int index = 0;
  int lat = 0;
  int lng = 0;

  while (index < polyline.length) {
    int char;
    int shift = 0;
    int result = 0;

    /// Method for getting **only** `1` coorditane `latitude` or `longitude` at a time
    int getCoordinate() {
      /// Iterating while value is grater or equal of `32-bits` size
      do {
        /// Substract `63` from `codeUnit`.
        char = polyline.codeUnitAt(index++) - 63;

        /// `AND` each `char` with `0x1f` to get 5-bit chunks.
        /// Then `OR` each `char` with `result`.
        /// Then left-shift for `shift` bits
        result |= (char & 0x1f) << shift;
        shift += 5;
      } while (char >= 0x20);

      /// Inversion of both:
      ///
      ///  * Left-shift the `value` for one bit
      ///  * Inversion `value` if it is negative
      final coordinateChange =
          (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      /// It is needed to clear `shift` and `result` for next coordinate.
      shift = result = 0;

      return coordinateChange;
    }

    lat += getCoordinate();
    lng += getCoordinate();

    coordinates.add([lat / accuracyMultiplier, lng / accuracyMultiplier]);
  }

  return coordinates;
}
