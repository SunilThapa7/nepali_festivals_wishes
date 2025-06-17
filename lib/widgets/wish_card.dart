import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:glassmorphism/glassmorphism.dart';

class WishCard extends StatelessWidget {
  final String imageUrl;
  final String festivalName;

  const WishCard({
    super.key,
    required this.imageUrl,
    required this.festivalName,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showCardOptions(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Card Image
            Positioned.fill(
              child: Image.asset(
                imageUrl,
                fit: BoxFit.cover,
              ),
            ),

            // Bottom Gradient & Actions
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: GlassmorphicContainer(
                width: double.infinity,
                height: 60,
                borderRadius: 0,
                blur: 5,
                alignment: Alignment.bottomCenter,
                border: 0,
                linearGradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.3),
                  ],
                ),
                borderGradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.3),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.white),
                      onPressed: () => _shareCard(context),
                      tooltip: 'Share',
                    ),
                    IconButton(
                      icon: const Icon(Icons.download, color: Colors.white),
                      onPressed: () => _saveImage(context),
                      tooltip: 'Save',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCardOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Card Preview
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 20),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  context,
                  Icons.share,
                  'Share',
                  _shareCard,
                ),
                _buildActionButton(
                  context,
                  Icons.download,
                  'Save',
                  _saveImage,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String label,
    Function(BuildContext) onTap,
  ) {
    return InkWell(
      onTap: () => onTap(context),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32),
            const SizedBox(height: 8),
            Text(label),
          ],
        ),
      ),
    );
  }

  void _shareCard(BuildContext context) {
    Share.shareFiles(
      [imageUrl],
      text: 'Happy $festivalName!',
      subject: '$festivalName Greeting Card',
    );
  }

  Future<void> _saveImage(BuildContext context) async {
    try {
      // Request storage permission
      final status = await Permission.storage.request();

      if (status.isGranted) {
        // Get the image bytes
        final ByteData? data = await rootBundle.load(imageUrl);

        if (data != null) {
          final Uint8List bytes = data.buffer.asUint8List();

          // Save to gallery
          await ImageGallerySaver.saveImage(
            bytes,
            quality: 100,
            name:
                '${festivalName}_greeting_${DateTime.now().millisecondsSinceEpoch}',
          );

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image saved to gallery'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permission denied to save image'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving image: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
