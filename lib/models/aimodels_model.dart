class AiModels {
  final String id;
  final String name;
  final String family;
  final List<String> piplines;

  AiModels(
      {required this.id,
      required this.name,
      required this.family,
      required this.piplines,
      });

  factory AiModels.fromJson(Map<String, dynamic> json) => AiModels(
        id: json['id'],
        name: json['name'],
        family: json['family'],
        piplines: List<String>.from(json['pipelines']),
      );
}
