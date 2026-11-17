import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/text/text_widgets.dart';
import '../../../artisan_profile/domain/models/portfolio_item.dart';
import '../providers/profile_actions_provider.dart';
import '../../../../core/network/dio_error_mapper.dart';

class ArtisanPortfolioManagementPage extends ConsumerStatefulWidget {
  const ArtisanPortfolioManagementPage({super.key});

  @override
  ConsumerState<ArtisanPortfolioManagementPage> createState() =>
      _ArtisanPortfolioManagementPageState();
}

class _ArtisanPortfolioManagementPageState
    extends ConsumerState<ArtisanPortfolioManagementPage> {
  final ImagePicker _picker = ImagePicker();
  bool _loading = true;
  bool _busy = false;
  List<PortfolioItem> _items = const [];

  @override
  void initState() {
    super.initState();
    _loadPortfolio();
  }

  Future<void> _loadPortfolio() async {
    setState(() => _loading = true);
    try {
      final items = await ref
          .read(profileRemoteDataSourceProvider)
          .fetchMyPortfolio();
      if (mounted) setState(() => _items = items);
    } catch (e) {
      _showMessage(userMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _addPortfolioItem() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    if (!mounted) return;

    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final orderController = TextEditingController(text: '0');
    final fileName = image.name;

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (_) {
        final width = MediaQuery.sizeOf(context).width;
        final maxHeight = MediaQuery.sizeOf(context).height * 0.82;

        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: 320.w,
              maxWidth: width > 700 ? 560.w : width * 0.95,
              maxHeight: maxHeight,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(20.r),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const BodyText(
                      'Add Portfolio Item',
                      size: BodySize.large,
                      fontWeight: FontWeight.w700,
                    ),
                    SizedBox(height: 4.h),
                    const BodyText(
                      'Showcase a completed job for clients to see.',
                      size: BodySize.small,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(height: 12.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4FAFA),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.image_outlined,
                            size: 16.r,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: BodyText(
                              fileName,
                              size: BodySize.small,
                              color: AppColors.textSecondary,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12.h),
                    _dialogField('Title', titleController),
                    SizedBox(height: 10.h),
                    _dialogField(
                      'Description',
                      descriptionController,
                      maxLines: 3,
                    ),
                    SizedBox(height: 10.h),
                    _dialogField(
                      'Display order',
                      orderController,
                      keyboard: TextInputType.number,
                    ),
                    SizedBox(height: 14.h),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: FilledButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Save'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    if (shouldSave != true) return;

    final order = int.tryParse(orderController.text.trim()) ?? 0;

    setState(() => _busy = true);
    try {
      await ref
          .read(profileRemoteDataSourceProvider)
          .addPortfolioItem(
            imageFile: File(image.path),
            title: titleController.text.trim().isEmpty
                ? null
                : titleController.text.trim(),
            description: descriptionController.text.trim().isEmpty
                ? null
                : descriptionController.text.trim(),
            displayOrder: order,
          );
      await _loadPortfolio();
      _showMessage('Portfolio item added');
    } catch (e) {
      _showMessage(userMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _editPortfolioItem(PortfolioItem item) async {
    final titleController = TextEditingController(text: item.title);
    final descriptionController = TextEditingController(
      text: item.description ?? '',
    );
    final orderController = TextEditingController(
      text: (item.displayOrder ?? 0).toString(),
    );

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (_) {
        final width = MediaQuery.sizeOf(context).width;
        final maxHeight = MediaQuery.sizeOf(context).height * 0.82;

        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: 320.w,
              maxWidth: width > 700 ? 560.w : width * 0.95,
              maxHeight: maxHeight,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(20.r),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const BodyText(
                      'Edit Portfolio Item',
                      size: BodySize.large,
                      fontWeight: FontWeight.w700,
                    ),
                    SizedBox(height: 4.h),
                    const BodyText(
                      'Update the information for this portfolio entry.',
                      size: BodySize.small,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(height: 12.h),
                    _dialogField('Title', titleController),
                    SizedBox(height: 10.h),
                    _dialogField(
                      'Description',
                      descriptionController,
                      maxLines: 3,
                    ),
                    SizedBox(height: 10.h),
                    _dialogField(
                      'Display order',
                      orderController,
                      keyboard: TextInputType.number,
                    ),
                    SizedBox(height: 14.h),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: FilledButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Update'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    if (shouldSave != true) return;

    final id = int.tryParse(item.id);
    if (id == null) {
      _showMessage('Invalid portfolio item id');
      return;
    }

    setState(() => _busy = true);
    try {
      await ref
          .read(profileRemoteDataSourceProvider)
          .updatePortfolioItem(
            itemId: id,
            title: titleController.text.trim(),
            description: descriptionController.text.trim(),
            displayOrder: int.tryParse(orderController.text.trim()) ?? 0,
          );
      await _loadPortfolio();
      _showMessage('Portfolio item updated');
    } catch (e) {
      _showMessage(userMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _deletePortfolioItem(PortfolioItem item) async {
    final id = int.tryParse(item.id);
    if (id == null) {
      _showMessage('Invalid portfolio item id');
      return;
    }

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete item?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    setState(() => _busy = true);
    try {
      await ref.read(profileRemoteDataSourceProvider).deletePortfolioItem(id);
      await _loadPortfolio();
      _showMessage('Portfolio item deleted');
    } catch (e) {
      _showMessage(userMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Manage Portfolio'),
        actions: [
          IconButton(
            onPressed: _busy ? null : _addPortfolioItem,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadPortfolio,
        child: _loading
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 260),
                  Center(child: CircularProgressIndicator()),
                ],
              )
            : _items.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: 220.h),
                  const Center(
                    child: BodyText(
                      'No portfolio item yet.\nTap + to add your first work.',
                      textAlign: TextAlign.center,
                      size: BodySize.medium,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              )
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(14.r),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 12.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(12.r),
                          ),
                          child: _portfolioImage(item.imageUrl),
                        ),
                        Padding(
                          padding: EdgeInsets.all(10.r),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              BodyText(
                                item.title,
                                size: BodySize.medium,
                                fontWeight: FontWeight.w600,
                              ),
                              if ((item.description ?? '').isNotEmpty) ...[
                                SizedBox(height: 4.h),
                                BodyText(
                                  item.description!,
                                  size: BodySize.small,
                                  color: AppColors.textSecondary,
                                ),
                              ],
                              SizedBox(height: 8.h),
                              Row(
                                children: [
                                  TextButton.icon(
                                    onPressed: _busy
                                        ? null
                                        : () => _editPortfolioItem(item),
                                    icon: const Icon(Icons.edit, size: 16),
                                    label: const Text('Edit'),
                                  ),
                                  const Spacer(),
                                  TextButton.icon(
                                    onPressed: _busy
                                        ? null
                                        : () => _deletePortfolioItem(item),
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      size: 16,
                                    ),
                                    label: const Text('Delete'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _portfolioImage(String imageUrl) {
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return Image.network(
        imageUrl,
        height: 180.h,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _imageFallback(),
      );
    }

    return Image.asset(
      imageUrl,
      height: 180.h,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _imageFallback(),
    );
  }

  Widget _imageFallback() {
    return Container(
      height: 180.h,
      width: double.infinity,
      color: const Color(0xFFF1F5F9),
      child: Icon(
        Icons.image_not_supported_outlined,
        color: AppColors.textSecondary,
        size: 26.r,
      ),
    );
  }

  Widget _dialogField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
    );
  }
}
