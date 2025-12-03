/// Mock search suggestions data
class SearchSuggestions {
  /// Get search suggestions based on query
  static List<String> getSuggestions(String query) {
    if (query.trim().isEmpty) return [];

    final lowerQuery = query.toLowerCase().trim();

    // Filter suggestions that contain the query
    return _allSuggestions
        .where((suggestion) => suggestion.toLowerCase().contains(lowerQuery))
        .take(8)
        .toList();
  }

  /// All available search suggestions
  static const List<String> _allSuggestions = [
    'carpenter',
    'finish carpentry',
    'journeyman carpenter',
    'custom furniture carpentry',
    'staircase work/carpentry',
    'door and window work/carpentry',
    'built-in furniture carpentry',
    'cabinet installation/carpentry',
    'plumber',
    'plumbing repair',
    'pipe installation',
    'drain cleaning',
    'water heater repair',
    'electrician',
    'electrical wiring',
    'light fixture installation',
    'circuit breaker repair',
    'electrical panel upgrade',
    'ac repair',
    'air conditioning installation',
    'ac maintenance',
    'hvac repair',
    'painter',
    'interior painting',
    'exterior painting',
    'wall painting',
    'ceiling painting',
  ];
}
