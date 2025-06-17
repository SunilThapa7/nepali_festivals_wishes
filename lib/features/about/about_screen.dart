import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nepali_festival_wishes/core/utils/app_colors.dart';
import 'package:nepali_festival_wishes/main.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About App'),
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // App logo and name section
            Container(
              padding: const EdgeInsets.symmetric(vertical: 32),
              color: AppColors.primary.withOpacity(0.1),
              width: double.infinity,
              child: Column(
                children: [
                  // App logo
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                          Icons.celebration,
                          size: 64,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // App name
                  const Text(
                    'Nepali Festival Wishes',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // App version
                  const Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            // App description
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Nepali Festival Wishes is a comprehensive app designed to help you celebrate Nepali festivals with beautiful wishes and greetings. Share traditional wishes in both Nepali and English with your loved ones.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const Divider(),

            // Features section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Features',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureItem(
                    Icons.celebration,
                    'Festival Information',
                    'Learn about upcoming and past Nepali festivals',
                  ),
                  _buildFeatureItem(
                    Icons.message,
                    'Festival Wishes',
                    'Collection of beautiful wishes in Nepali and English',
                  ),
                  _buildFeatureItem(
                    Icons.image,
                    'Greeting Cards',
                    'Share festival greeting cards with loved ones',
                  ),
                  _buildFeatureItem(
                    Icons.favorite,
                    'Favorites',
                    'Save your favorite wishes for quick access',
                  ),
                  _buildFeatureItem(
                    Icons.calendar_today,
                    'Festival Dates',
                    'Keep track of upcoming festival dates',
                  ),
                ],
              ),
            ),

            const Divider(),

            // Contact and share section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Contact & Share',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Share this app
                  ListTile(
                    leading: const Icon(Icons.share, color: AppColors.primary),
                    title: const Text('Share this app'),
                    subtitle: const Text('Tell your friends about this app'),
                    onTap: () {
                      Share.share(
                        'Check out this amazing Nepali Festival Wishes app! Download now: [App Store Link]',
                      );
                    },
                  ),
                  // Rate this app
                  ListTile(
                    leading: const Icon(Icons.star, color: AppColors.primary),
                    title: const Text('Rate this app'),
                    subtitle: const Text('Support us with a positive rating'),
                    onTap: () {
                      _launchUrl('https://play.google.com/store/apps');
                    },
                  ),
                  // Send feedback
                  ListTile(
                    leading:
                        const Icon(Icons.feedback, color: AppColors.primary),
                    title: const Text('Send feedback'),
                    subtitle: const Text('Help us improve the app'),
                    onTap: () {
                      _launchUrl('mailto:support@example.com');
                    },
                  ),
                ],
              ),
            ),

            const Divider(),

            // Credits section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Credits',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '• Images and illustrations provided by various artists\n'
                    '• Festival information sourced from cultural resources\n'
                    '• Traditional wishes composed with help from native speakers',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            // Copyright footer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              color: Colors.grey[200],
              child: const Text(
                '© 2023 Nepali Festival Wishes. All rights reserved.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    try {
      await launchUrl(Uri.parse(url));
    } catch (e) {
      debugPrint('Could not launch $url: $e');
    }
  }
}
