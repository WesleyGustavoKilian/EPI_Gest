class RelatedData {
  final String id;
  final String name;

  RelatedData({required this.id, required this.name});

  factory RelatedData.fromJson(Map<String, dynamic> json) {
    return RelatedData(
      id: json['\$id'],
      name: json['name'],
    );
  }
}
