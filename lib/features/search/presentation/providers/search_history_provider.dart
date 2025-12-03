import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Search history notifier that maintains up to 10 most recent searches
class SearchHistoryNotifier extends Notifier<List<String>> {
  static const String _storageKey = 'search_history';
  static const int _maxHistoryItems = 10;

  @override
  List<String> build() {
    // Initialize with empty list, then load from storage
    _loadHistory();
    return [];
  }

  /// Load search history from SharedPreferences
  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList(_storageKey) ?? [];
      state = history;
    } catch (e) {
      // If loading fails, keep empty history
      state = [];
    }
  }

  /// Add a search query to history
  /// If history reaches 10 items, remove the oldest one
  Future<void> addSearch(String query) async {
    if (query.trim().isEmpty) return;

    final trimmedQuery = query.trim().toLowerCase();

    // Remove if already exists (to move it to top)
    final newHistory = state.where((item) => item != trimmedQuery).toList();

    // Add to beginning
    newHistory.insert(0, trimmedQuery);

    // Keep only last 10 items
    if (newHistory.length > _maxHistoryItems) {
      newHistory.removeLast();
    }

    state = newHistory;

    // Save to SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_storageKey, newHistory);
    } catch (e) {
      // Handle save error silently
    }
  }

  /// Clear all search history
  Future<void> clearHistory() async {
    state = [];
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
    } catch (e) {
      // Handle error silently
    }
  }

  /// Remove a specific search from history
  Future<void> removeSearch(String query) async {
    state = state.where((item) => item != query).toList();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_storageKey, state);
    } catch (e) {
      // Handle error silently
    }
  }
}

/// Provider instance
final searchHistoryProvider = NotifierProvider<SearchHistoryNotifier, List<String>>(
  SearchHistoryNotifier.new,
);
