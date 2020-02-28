# google_polyline_algorithm_example

Demonstrates how to use the google_polyline_algorithm package.

## Usage

```dart
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
```


## Getting Started

For help getting started with Dart, view 
[online documentation](https://dart.dev/docs), which offers tutorials, 
samples, guidance, and a full API reference.
