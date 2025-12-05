import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../services/upload_service.dart';
import '../models/upload.dart';

class PhotoUploadScreen extends StatefulWidget {
  final String campaignId;
  final String campaignTitle;

  const PhotoUploadScreen({
    super.key,
    required this.campaignId,
    required this.campaignTitle,
  });

  @override
  State<PhotoUploadScreen> createState() => _PhotoUploadScreenState();
}

class _PhotoUploadScreenState extends State<PhotoUploadScreen> {
  final ImagePicker _picker = ImagePicker();
  final UploadService _uploadService = UploadService();
  final List<XFile> _selectedImages = [];
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _error;
  List<Upload>? _completedUploads;

  Future<void> _pickFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImages.add(image);
        });
      }
    } catch (e) {
      _showError('Failed to capture photo: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images);
        });
      }
    } catch (e) {
      _showError('Failed to pick photos: $e');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<Map<String, dynamic>> _getMetadata() async {
    final metadata = <String, dynamic>{};

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }

        if (permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always) {
          final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );

          metadata['latitude'] = position.latitude;
          metadata['longitude'] = position.longitude;
          metadata['accuracy'] = position.accuracy;
        }
      }
    } catch (e) {
      // GPS metadata is optional, continue without it
      debugPrint('Failed to get location: $e');
    }

    metadata['timestamp'] = DateTime.now().toIso8601String();

    return metadata;
  }

  Future<void> _uploadPhotos() async {
    if (_selectedImages.isEmpty) {
      _showError('Please select at least one photo');
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
      _error = null;
      _completedUploads = [];
    });

    try {
      final metadata = await _getMetadata();
      final totalImages = _selectedImages.length;

      for (int i = 0; i < totalImages; i++) {
        final image = _selectedImages[i];

        final upload = await _uploadService.uploadPhoto(
          campaignId: widget.campaignId,
          filePath: image.path,
          metadata: metadata,
          onProgress: (progress) {
            setState(() {
              final baseProgress = i / totalImages;
              final currentProgress = progress / totalImages;
              _uploadProgress = baseProgress + currentProgress;
            });
          },
        );

        _completedUploads!.add(upload);
      }

      // All uploads successful
      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isUploading = false;
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 12),
            Text('Upload Successful!'),
          ],
        ),
        content: Text(
          '${_selectedImages.length} photo(s) uploaded successfully to "${widget.campaignTitle}"',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Return to campaign detail
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Photos'),
      ),
      body: Column(
        children: [
          if (_selectedImages.isEmpty) _buildEmptyState(),
          if (_selectedImages.isNotEmpty) ...[
            Expanded(child: _buildImageGrid()),
            _buildUploadSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library_outlined,
                size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            Text(
              'No photos selected',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _pickFromCamera,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _pickFromGallery,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _selectedImages.length + 1,
      itemBuilder: (context, index) {
        if (index == _selectedImages.length) {
          return _buildAddMoreButton();
        }

        final image = _selectedImages[index];
        return _buildImageCard(image, index);
      },
    );
  }

  Widget _buildAddMoreButton() {
    return Card(
      child: InkWell(
        onTap: _pickFromGallery,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey[600]),
            const SizedBox(height: 8),
            Text('Add More', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCard(XFile image, int index) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(
            File(image.path),
            fit: BoxFit.cover,
          ),
          Positioned(
            top: 4,
            right: 4,
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.black54,
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.close, size: 18, color: Colors.white),
                onPressed: () => _removeImage(index),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            if (_isUploading)
              Column(
                children: [
                  LinearProgressIndicator(value: _uploadProgress),
                  const SizedBox(height: 8),
                  Text(
                    '${(_uploadProgress * 100).toInt()}% uploaded',
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _isUploading ? null : _pickFromCamera,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isUploading ? null : _uploadPhotos,
                    icon: _isUploading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.cloud_upload),
                    label: Text(
                      _isUploading
                          ? 'Uploading...'
                          : 'Upload ${_selectedImages.length} Photo${_selectedImages.length != 1 ? 's' : ''}',
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
