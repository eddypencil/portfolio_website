class Project {
  final String name;
  final String description;
  final String mainImagePath;
  final List<String> images;
  final String? link;
  final String details;

  Project({
    required this.images,
    required this.details,
    required this.name,
    required this.description,
    required this.mainImagePath,
    this.link,
  });
}
