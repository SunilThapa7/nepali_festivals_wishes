import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart' as ip;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nepali_festival_wishes/providers/auth_provider.dart';
import 'package:nepali_festival_wishes/services/firebase_service.dart';
// import removed

class ProfileScreen extends ConsumerStatefulWidget {
  final String? initialFestivalId;
  final String? initialFestivalName;
  final bool showSubmissionsInitially;

  const ProfileScreen({Key? key, this.initialFestivalId, this.initialFestivalName, this.showSubmissionsInitially = false}) : super(key: key);
  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameController = TextEditingController();
  // submission-related state removed
  final _valueController = TextEditingController();
  bool _saving = false;
  bool _showSubmissions = false;
  String? _pickedImagePath; // for URL selection
  Uint8List? _pickedBytes; // for device selection

  @override
  void dispose() {
    _nameController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _showSubmissions = widget.showSubmissionsInitially;
  }

  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    if (_nameController.text.trim().isEmpty) return;
    setState(() => _saving = true);
    try {
      String? avatarUrlToSave;
      if (_pickedBytes != null) {
        final storage = FirebaseStorage.instance;
        final refPath = storage.ref().child('avatars/${user.uid}.jpg');
        await refPath.putData(_pickedBytes!, SettableMetadata(contentType: 'image/jpeg'));
        avatarUrlToSave = await refPath.getDownloadURL();
      } else {
        avatarUrlToSave = _pickedImagePath;
      }

      await ref.read(authServiceProvider).updateUserProfile(
            userId: user.uid,
            name: _nameController.text.trim(),
            avatarUrl: avatarUrlToSave,
          );
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Profile updated')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickAvatar() async {
    // Let user choose: URL or pick from device
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Use image URL'),
              onTap: () => Navigator.pop(context, 'url'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pick from device'),
              onTap: () => Navigator.pop(context, 'device'),
            ),
          ],
        ),
      ),
    );
    if (choice == 'url') {
      final controller = TextEditingController(text: _pickedImagePath ?? '');
      final result = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Image URL'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Paste image URL',
              hintText: 'https://.../avatar.png',
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Use')),
          ],
        ),
      );
      if (result != null && result.isNotEmpty) {
        setState(() {
          _pickedImagePath = result;
          _pickedBytes = null;
        });
      }
    } else if (choice == 'device') {
      // Device picker (works on mobile; on web falls back to file picker)
      try {
        // Import deferred to avoid unused warnings if not used
        // ignore: avoid_dynamic_calls
        final bytes = await _pickImageFromDevice();
        if (bytes != null) {
          setState(() {
            _pickedBytes = bytes;
            _pickedImagePath = null;
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to pick image: $e')),
          );
        }
      }
    }
  }

  Future<Uint8List?> _pickImageFromDevice() async {
    final ip.ImagePicker picker = ip.ImagePicker();
    final ip.XFile? image = await picker.pickImage(source: ip.ImageSource.gallery, maxWidth: 512);
    return image != null ? await image.readAsBytes() : null;
  }

  // Submission moved to dedicated screen

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    // festivals provider no longer needed here

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            currentUser.when(
              data: (user) {
                _nameController.text = user?.name ?? '';
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 32,
                              backgroundImage: _pickedBytes != null
                                  ? MemoryImage(_pickedBytes!)
                                  : (_pickedImagePath != null && _pickedImagePath!.isNotEmpty)
                                      ? NetworkImage(_pickedImagePath!)
                                      : (user?.avatarUrl != null && (user!.avatarUrl!.isNotEmpty))
                                          ? NetworkImage(user.avatarUrl!)
                                          : const AssetImage('assets/images/logo.png') as ImageProvider,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: InkWell(
                                onTap: _pickAvatar,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(6),
                                  child: const Icon(Icons.edit, size: 14, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Display Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _saveProfile,
                        child: _saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Save Profile'),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
            ),
            // Submission UI moved to dedicated screen
            const SizedBox(height: 24),
            if (_showSubmissions) ...[
              const Text(
                'My Submissions',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _UserSubmissionsList(),
            ],
          ],
        ),
      ),
    );
  }
}

class _UserSubmissionsList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();
    return StreamBuilder(
      stream: FirebaseService().getUserSubmissions(user.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const SizedBox.shrink();
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data!;
        if (docs.isEmpty) {
          return const Text('No submissions yet');
        }
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final d = docs[index].data();
            return ListTile(
              title: Text('${d['festivalName']} • ${d['type']}'),
              subtitle: Text(d['type'] == 'wish' ? (d['value'] ?? '') : (d['value'] ?? '')),
              trailing: Text(
                (d['status'] ?? 'pending').toString(),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            );
          },
        );
      },
    );
  }
} 