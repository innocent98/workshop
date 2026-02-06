/// Domain model for rating distribution
class RatingDistribution {
  final int oneStar;
  final int twoStar;
  final int threeStar;
  final int fourStar;
  final int fiveStar;

  const RatingDistribution({
    required this.oneStar,
    required this.twoStar,
    required this.threeStar,
    required this.fourStar,
    required this.fiveStar,
  });

  int get total => oneStar + twoStar + threeStar + fourStar + fiveStar;

  double percentageFor(int stars) {
    if (total == 0) return 0.0;
    final count = _countFor(stars);
    return (count / total) * 100;
  }

  int _countFor(int stars) {
    switch (stars) {
      case 1:
        return oneStar;
      case 2:
        return twoStar;
      case 3:
        return threeStar;
      case 4:
        return fourStar;
      case 5:
        return fiveStar;
      default:
        return 0;
    }
  }

  factory RatingDistribution.empty() {
    return const RatingDistribution(
      oneStar: 0,
      twoStar: 0,
      threeStar: 0,
      fourStar: 0,
      fiveStar: 0,
    );
  }
}
