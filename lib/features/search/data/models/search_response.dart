import 'artisan_search_model.dart';

class SearchArtisansResponse {
  final List<ArtisanSearchModel> artisans;
  final int totalCount;

  const SearchArtisansResponse({
    required this.artisans,
    required this.totalCount,
  });

  factory SearchArtisansResponse.fromJson(Map<String, dynamic> json) {
    return SearchArtisansResponse(
      artisans: (json['artisans'] as List)
          .map((a) => ArtisanSearchModel.fromJson(a as Map<String, dynamic>))
          .toList(),
      totalCount: json['total_count'] as int? ?? 0,
    );
  }
}
