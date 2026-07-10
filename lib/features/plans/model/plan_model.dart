class PlanModel {
  final String id;
  final String name;
  final String description;
  final int cutPrice;
  final int finalPrice;
  final List<String> features;
  final String buttonText;
  final bool isPopular;
  final String color;
  final int order;

  PlanModel({
    required this.id,
    required this.name,
    required this.description,
    required this.cutPrice,
    required this.finalPrice,
    required this.features,
    required this.buttonText,
    required this.isPopular,
    required this.color,
    required this.order,
  });

  factory PlanModel.fromMap(
    String id,
    Map<String, dynamic> data,
  ) {
    return PlanModel(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      cutPrice: (data['cutPrice'] ?? 0) as int,
      finalPrice: (data['finalPrice'] ?? 0) as int,
      features: List<String>.from(data['features'] ?? []),
      buttonText: data['buttonText'] ?? 'Get Started',
      isPopular: data['isPopular'] ?? false,
      color: data['color'] ?? '#4CAF50',
      order: (data['order'] ?? 0) as int,
    );
  }
}