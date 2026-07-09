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
  });

  factory PlanModel.fromMap(
    String id,
    Map<String, dynamic> data,
  ) {
    return PlanModel(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      cutPrice: (data['cut_price'] ?? 0) as int,
      finalPrice: (data['final_price'] ?? 0) as int,
      features: List<String>.from(data['features'] ?? []),
      buttonText: data['buttonText'] ?? 'Get Started',
      isPopular: data['isPopular'] ?? false,
      color: data['color'] ?? '#4CAF50',
    );
  }
}