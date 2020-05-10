class City {
  final String title;
  final double lat;
  final double lng;

  const City(
    this.title,
    this.lat,
    this.lng,
  )   : assert(title != null),
        assert(lat != null),
        assert(lng != null);

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      json['title'] as String,
      json['lat'] as double,
      json['lng'] as double,
    );
  }
}
