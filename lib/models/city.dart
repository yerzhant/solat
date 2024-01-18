class City {
  final int id;
  final String title;
  final String lat;
  final String lng;
  final int timeZone;

  const City(
    this.id,
    this.title,
    this.lat,
    this.lng,
    this.timeZone,
  );

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      (json['id'] as double).toInt(),
      json['title'] as String,
      json['lat'] as String,
      json['lng'] as String,
      (json['time_shift'] as double).toInt(),
    );
  }
}
