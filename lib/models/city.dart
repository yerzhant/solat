class City {
  final int id;
  final String title;
  final String lat;
  final String lng;

  const City(
    this.id,
    this.title,
    this.lat,
    this.lng,
  )   : assert(id != null),
        assert(title != null),
        assert(lat != null),
        assert(lng != null);

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      (json['id'] as double).toInt(),
      json['title'] as String,
      json['lat'] as String,
      json['lng'] as String,
    );
  }
}
