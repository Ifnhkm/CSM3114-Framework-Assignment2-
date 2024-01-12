class Project {
  final String id;
  final String name;
  final String description;
  final List<String> activities;
  final DateTime deadline;
  final String status;

  Project({
    required this.id,
    required this.name,
    required this.description,
    required this.activities,
    required this.deadline,
    required this.status,
  });

  get statusId => '1';
}
