class City {
  final String title;
  final double lat;
  final double lng;
  final double timeZone;

  const City(
    this.title,
    this.lat,
    this.lng,
    this.timeZone,
  )   : assert(title != null),
        assert(lat != null),
        assert(lng != null),
        assert(timeZone != null);

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      json['title'] as String,
      json['lat'] as double,
      json['lng'] as double,
      json['time_shift'] as double,
    );
  }
}
