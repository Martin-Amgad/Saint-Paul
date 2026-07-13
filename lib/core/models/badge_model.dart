class BadgeModel {
  final String? bId;
  final String? church;
  final String? family;
  final String? name;
  final String? url;

  BadgeModel({this.bId, this.church, this.family, this.name, this.url});

  /// Model → Firestore
  Map<String, dynamic> toJson() {
    return {'church': church, 'family': family, 'name': name, 'url': url};
  }

  /// Firestore → Model
  factory BadgeModel.fromJson(Map<String, dynamic> json, String id) {
    return BadgeModel(
      bId: id,
      church: json['church'] ?? '',
      family: json['family'] ?? '',
      name: json['name'] ?? '',
      url: json['url'] ?? '',
    );
  }
}
