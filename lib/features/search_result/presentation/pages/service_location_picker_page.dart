import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/text/text_widgets.dart';

class ServiceLocationSelection {
  final double latitude;
  final double longitude;
  final String address;

  const ServiceLocationSelection({
    required this.latitude,
    required this.longitude,
    required this.address,
  });
}

class ServiceLocationPickerPage extends StatefulWidget {
  final double initialLatitude;
  final double initialLongitude;
  final String? initialAddress;

  const ServiceLocationPickerPage({
    super.key,
    required this.initialLatitude,
    required this.initialLongitude,
    this.initialAddress,
  });

  @override
  State<ServiceLocationPickerPage> createState() =>
      _ServiceLocationPickerPageState();
}

class _ServiceLocationPickerPageState extends State<ServiceLocationPickerPage> {
  final Dio _dio = Dio(
    BaseOptions(
      headers: {'User-Agent': 'workchop-app/1.0'},
      receiveTimeout: const Duration(seconds: 15),
      connectTimeout: const Duration(seconds: 15),
    ),
  );
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  late LatLng _selectedPoint;
  String? _selectedAddress;
  bool _isResolving = false;
  bool _isSearching = false;
  List<_AddressSuggestion> _suggestions = const [];

  @override
  void initState() {
    super.initState();
    _selectedPoint = LatLng(widget.initialLatitude, widget.initialLongitude);
    _selectedAddress = widget.initialAddress;
    _searchController.text = widget.initialAddress ?? '';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _reverseGeocode(double lat, double lon) async {
    setState(() => _isResolving = true);
    try {
      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {'format': 'jsonv2', 'lat': lat, 'lon': lon},
      );
      final data = response.data as Map<String, dynamic>;
      final displayName = (data['display_name'] ?? '').toString().trim();

      if (!mounted) return;
      setState(() {
        _selectedAddress = displayName.isEmpty ? '$lat, $lon' : displayName;
        _searchController.text = _selectedAddress!;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _selectedAddress =
            '${lat.toStringAsFixed(5)}, ${lon.toStringAsFixed(5)}';
      });
    } finally {
      if (mounted) setState(() => _isResolving = false);
    }
  }

  Future<void> _searchAddress(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      setState(() => _suggestions = const []);
      return;
    }

    setState(() => _isSearching = true);
    try {
      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'q': '$q, Nigeria',
          'format': 'jsonv2',
          'limit': 8,
          'addressdetails': 1,
          'countrycodes': 'ng',
        },
      );
      final list = (response.data as List)
          .whereType<Map<String, dynamic>>()
          .map(_AddressSuggestion.fromJson)
          .toList();
      if (!mounted) return;
      setState(() => _suggestions = list);
    } catch (_) {
      if (!mounted) return;
      setState(() => _suggestions = const []);
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _pickSuggestion(_AddressSuggestion suggestion) {
    final point = LatLng(suggestion.latitude, suggestion.longitude);
    _mapController.move(point, 15.5);
    setState(() {
      _selectedPoint = point;
      _selectedAddress = suggestion.displayName;
      _searchController.text = suggestion.displayName;
      _suggestions = const [];
    });
  }

  void _onMapTap(LatLng point) {
    setState(() {
      _selectedPoint = point;
      _suggestions = const [];
    });
    _reverseGeocode(point.latitude, point.longitude);
  }

  void _submit() {
    Navigator.of(context).pop(
      ServiceLocationSelection(
        latitude: _selectedPoint.latitude,
        longitude: _selectedPoint.longitude,
        address:
            _selectedAddress ??
            '${_selectedPoint.latitude.toStringAsFixed(5)}, ${_selectedPoint.longitude.toStringAsFixed(5)}',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit Service Location'),
        actions: [
          TextButton(onPressed: _submit, child: const Text('Use this')),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 8.h),
            child: TextField(
              controller: _searchController,
              onChanged: _searchAddress,
              decoration: InputDecoration(
                hintText: 'Search address',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _isSearching
                    ? Padding(
                        padding: EdgeInsets.all(12.r),
                        child: SizedBox(
                          width: 16.r,
                          height: 16.r,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF7F9FC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          if (_suggestions.isNotEmpty)
            Flexible(
              fit: FlexFit.loose,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 170.h),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  itemCount: _suggestions.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final s = _suggestions[index];
                    return ListTile(
                      dense: true,
                      title: BodyText(
                        s.displayName,
                        size: BodySize.small,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => _pickSuggestion(s),
                    );
                  },
                ),
              ),
            ),
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _selectedPoint,
                initialZoom: 14,
                onTap: (tapPosition, point) => _onMapTap(point),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.workchop',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedPoint,
                      width: 40.r,
                      height: 40.r,
                      child: Icon(
                        Icons.location_pin,
                        color: AppColors.primary,
                        size: 34.r,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 10.h),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.place_outlined,
                        size: 16.r,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 6.w),
                      BodyText(
                        _isResolving
                            ? 'Resolving address...'
                            : 'Selected address',
                        size: BodySize.small,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  BodyText(
                    _selectedAddress ??
                        '${_selectedPoint.latitude.toStringAsFixed(5)}, ${_selectedPoint.longitude.toStringAsFixed(5)}',
                    size: BodySize.small,
                  ),
                  SizedBox(height: 8.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: const Text('Use this location'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressSuggestion {
  final String displayName;
  final double latitude;
  final double longitude;

  const _AddressSuggestion({
    required this.displayName,
    required this.latitude,
    required this.longitude,
  });

  factory _AddressSuggestion.fromJson(Map<String, dynamic> json) {
    return _AddressSuggestion(
      displayName: (json['display_name'] ?? '').toString(),
      latitude: double.tryParse((json['lat'] ?? '').toString()) ?? 0.0,
      longitude: double.tryParse((json['lon'] ?? '').toString()) ?? 0.0,
    );
  }
}
