import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vittalo/core/constants/app_constants.dart';
import 'package:vittalo/core/router/app_router.dart';
import 'package:vittalo/core/theme/app_theme.dart';
import 'package:vittalo/features/category_selection/domain/models/category_model.dart';
import 'package:vittalo/features/price_estimator/presentation/screens/input_wizard_screen.dart';

class ImageUploadScreen extends StatefulWidget {
  final CategoryModel category;
  const ImageUploadScreen({super.key, required this.category});

  @override
  State<ImageUploadScreen> createState() => _ImageUploadScreenState();
}

class _ImageUploadScreenState extends State<ImageUploadScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  bool _isLoading = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      setState(() => _isLoading = true);
      final image = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (mounted) setState(() => _selectedImage = image);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not access ${source.name}: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _proceed() {
    context.push(
      AppRoutes.inputWizard,
      extra: InputWizardArgs(
        category: widget.category,
        imagePath: _selectedImage?.path,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(widget.category.title),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.pagePadding),
          child: Column(
            children: [
              _SectionHeader(category: widget.category),
              const SizedBox(height: 28),
              Expanded(
                child: _selectedImage == null
                    ? _UploadPlaceholder(
                        isLoading: _isLoading,
                        onCamera: () => _pickImage(ImageSource.camera),
                        onGallery: () => _pickImage(ImageSource.gallery),
                      )
                    : _ImagePreview(
                        imagePath: _selectedImage!.path,
                        onRetake: () => setState(() => _selectedImage = null),
                      ),
              ),
              const SizedBox(height: 20),
              _BottomActions(
                hasImage: _selectedImage != null,
                onSkip: _proceed,
                onContinue: _proceed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final CategoryModel category;
  const _SectionHeader({required this.category});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add a photo',
          style: Theme.of(context).textTheme.headlineMedium,
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),
        const SizedBox(height: 6),
        Text(
          'A clear photo helps buyers trust your listing. Optional but recommended.',
          style: Theme.of(context).textTheme.bodyMedium,
        ).animate(delay: 100.ms).fadeIn(duration: 400.ms),
      ],
    );
  }
}

// ─── Upload Placeholder ───────────────────────────────────────────────────────

class _UploadPlaceholder extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onCamera;
  final VoidCallback onGallery;

  const _UploadPlaceholder({
    required this.isLoading,
    required this.onCamera,
    required this.onGallery,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: VittaloColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        border: Border.all(
          color: VittaloColors.cardBorder,
          style: BorderStyle.solid,
        ),
      ),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: VittaloColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add_photo_alternate_outlined,
                    color: VittaloColors.primary,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Upload product photo',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Clear, well-lit photo increases estimation accuracy',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _SourceButton(
                      icon: Icons.camera_alt_rounded,
                      label: 'Camera',
                      onTap: onCamera,
                    ),
                    const SizedBox(width: 16),
                    _SourceButton(
                      icon: Icons.photo_library_rounded,
                      label: 'Gallery',
                      onTap: onGallery,
                    ),
                  ],
                ),
              ],
            ),
    ).animate(delay: 150.ms).fadeIn(duration: 400.ms).scale(
          begin: const Offset(0.97, 0.97),
          end: const Offset(1, 1),
          duration: 400.ms,
        );
  }
}

class _SourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SourceButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }
}

// ─── Image Preview ────────────────────────────────────────────────────────────

class _ImagePreview extends StatelessWidget {
  final String imagePath;
  final VoidCallback onRetake;

  const _ImagePreview({required this.imagePath, required this.onRetake});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.cardRadius),
          child: Image.file(File(imagePath), fit: BoxFit.cover),
        ),
        Positioned(
          top: 12,
          right: 12,
          child: GestureDetector(
            onTap: onRetake,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.refresh_rounded, color: Colors.white, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Retake',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: VittaloColors.secondary.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.black, size: 14),
                const SizedBox(width: 6),
                Text(
                  'Photo selected',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 350.ms).scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
          duration: 350.ms,
        );
  }
}

// ─── Bottom Actions ───────────────────────────────────────────────────────────

class _BottomActions extends StatelessWidget {
  final bool hasImage;
  final VoidCallback onSkip;
  final VoidCallback onContinue;

  const _BottomActions({
    required this.hasImage,
    required this.onSkip,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onContinue,
            child: Text(hasImage ? 'Continue with photo' : 'Continue'),
          ),
        ),
        if (!hasImage) ...[
          const SizedBox(height: 12),
          TextButton(
            onPressed: onSkip,
            child: Text(
              'Skip — add details only',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: VittaloColors.textSecondary,
                  ),
            ),
          ),
        ],
      ],
    );
  }
}
