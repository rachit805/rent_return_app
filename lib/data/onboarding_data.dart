class OnboardingModel {
  final String description;
  final String image;

  OnboardingModel({
    required this.description,
    required this.image,
  });
}

final List<OnboardingModel> onboardingData = [
  OnboardingModel(
    description:
        "Welcome to Store Inventory - Easily manage and track all your store items with real-time updates.",
    image: "assets/images/onb1.png",
  ),
  OnboardingModel(
    description:
        "Add new products, update existing stock, and keep your store inventory organized in just a few clicks.",
    image: "assets/images/onb2.png",
  ),
  OnboardingModel(
    description:
        "Generate detailed reports and get insights to improve your inventory management and reduce wastage.",
    image: "assets/images/onb3.png",
  ),
];
