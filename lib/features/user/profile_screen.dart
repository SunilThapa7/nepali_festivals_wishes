import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart' as ip;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nepali_festival_wishes/providers/auth_provider.dart';
import 'package:nepali_festival_wishes/services/firebase_service.dart';
import 'package:nepali_festival_wishes/providers/festival_provider.dart';
import 'package:file_picker/file_picker.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameController = TextEditingController();
  String? _selectedFestivalId;
  String? _selectedFestivalName;
  String _submissionType = 'wish'; // 'wish' | 'card'
  String _language = 'nepali';
  final _valueController = TextEditingController();
  bool _saving = false;
  String? _pickedImagePath; // for URL selection
  Uint8List? _pickedBytes; // for device selection

  @override
  void dispose() {
    _nameController.dispose();
    _valueController.dispose();
    super.dispose();
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
        await refPath.putData(_pickedBytes!);
        avatarUrlToSave = await refPath.getDownloadURL();
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
              hintText: 'Enter image URL',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('OK'),
            ),
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

  Future<void> _pickAndUploadAvatar() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null || result.files.single.bytes == null) return;
    setState(() => _saving = true);
    try {
      final storageRef = FirebaseStorage.instance
          .ref('avatars/${user.uid}_${DateTime.now().millisecondsSinceEpoch}.png');
      await storageRef.putData(result.files.single.bytes!, SettableMetadata(contentType: 'image/png'));
      final url = await storageRef.getDownloadURL();
      await ref.read(authServiceProvider)
          .updateUserProfile(userId: user.uid, avatarUrl: url);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Avatar updated')));
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

  Future<void> _pickAndUploadCardImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null || result.files.single.bytes == null) return;
    setState(() => _saving = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      final ref = FirebaseStorage.instance.ref(
          'cards/${user?.uid ?? 'anon'}_${DateTime.now().millisecondsSinceEpoch}.png');
      await ref.putData(result.files.single.bytes!, SettableMetadata(contentType: 'image/png'));
      final url = await ref.getDownloadURL();
      setState(() {
        _submissionType = 'card';
        _valueController.text = url;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Card image uploaded. URL filled.')),
        );
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

  Future<void> _submitContent() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    if (_selectedFestivalId == null || _valueController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select festival and enter content')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await FirebaseService().createSubmission(
        userId: user.uid,
        festivalId: _selectedFestivalId!,
        festivalName: _selectedFestivalName ?? '',
        type: _submissionType,
        language: _submissionType == 'wish' ? _language : null,
        value: _valueController.text.trim(),
      );
      _valueController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Submitted for review')));
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

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final festivals = ref.watch(festivalProvider);

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
                        CircleAvatar(
                          radius: 32,
                          backgroundImage: (user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty)
                              ? NetworkImage(user.avatarUrl!)
                              : null,
                          child: (user?.avatarUrl == null || (user!.avatarUrl ?? '').isEmpty)
                              ? const Icon(Icons.person, size: 32)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: _saving ? null : _pickAndUploadAvatar,
                          icon: const Icon(Icons.upload),
                          label: const Text('Upload Avatar'),
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
            const SizedBox(height: 24),
            const Text(
              'Submit Content',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            festivals.when(
              data: (list) {
                return DropdownButtonFormField<String>(
                  value: _selectedFestivalId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Select Festival',
                    border: OutlineInputBorder(),
                  ),
                  items: list
                      .map((f) => DropdownMenuItem(
                            value: f.id,
                            child: Text(f.name),
                            onTap: () {
                              _selectedFestivalName = f.name;
                            },
                          ))
                      .toList(),
                  onChanged: (v) {
                    setState(() => _selectedFestivalId = v);
                  },
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _submissionType,
                    decoration: const InputDecoration(
                      labelText: 'Type',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'wish', child: Text('Wish')),
                      DropdownMenuItem(value: 'card', child: Text('Card URL')),
                    ],
                    onChanged: (v) {
                      setState(() => _submissionType = v ?? 'wish');
                    },
                  ),
                ),
                const SizedBox(width: 12),
                if (_submissionType == 'wish')
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _language,
                      decoration: const InputDecoration(
                        labelText: 'Language',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'nepali', child: Text('Nepali')),
                        DropdownMenuItem(value: 'english', child: Text('English')),
                      ],
                      onChanged: (v) {
                        setState(() => _language = v ?? 'nepali');
                      },
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _valueController,
              decoration: InputDecoration(
                labelText: _submissionType == 'wish' ? 'Wish text' : 'Card image URL',
                border: const OutlineInputBorder(),
              ),
              maxLines: _submissionType == 'wish' ? 3 : 1,
            ),
            if (_submissionType == 'card') ...[
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _saving ? null : _pickAndUploadCardImage,
                icon: const Icon(Icons.cloud_upload),
                label: const Text('Upload card image'),
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _saving ? null : _submitContent,
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Submit'),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'My Submissions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _UserSubmissionsList(),
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
          return Center(child: Text('Error: ${snapshot.error}'));
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