import 'artisan_search_model.dart';

class SearchArtisansResponse {
  final List<ArtisanSearchModel> artisans;
  final int totalCount;

  const SearchArtisansResponse({
    required this.artisans,
    required this.totalCount,
  });

  factory SearchArtisansResponse.fromJson(Map<String, dynamic> json) {
    final rawArtisans =
        (json['artisans'] ?? json['results']) as List? ?? const [];
    final total =
        (json['total_count'] ?? json['total']) as int? ?? rawArtisans.length;

    return SearchArtisansResponse(
      artisans: rawArtisans
          .map((a) => ArtisanSearchModel.fromJson(a as Map<String, dynamic>))
          .toList(),
      totalCount: total,
    );
  }
}
