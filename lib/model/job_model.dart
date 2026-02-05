class JobModel {
  final String id;
  final String title;
  final String description;
  final String? image;
  final String companyName;
  final String? companyLogo;

  JobModel({
    required this.id,
    required this.title,
    required this.description,
    this.image,
    required this.companyName,
    this.companyLogo,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      image: json['image'],
      companyName: json['userauth']['name'],
      companyLogo: json['userauth']['company_logo_url'],
    );
  }
}
