import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart' as ip;
import 'package:nepali_festival_wishes/providers/festival_provider.dart';
import 'package:nepali_festival_wishes/services/firebase_service.dart';

class SubmitContentScreen extends ConsumerStatefulWidget {
  final String? initialFestivalId;
  final String? initialFestivalName;

  const SubmitContentScreen({Key? key, this.initialFestivalId, this.initialFestivalName}) : super(key: key);

  @override
  ConsumerState<SubmitContentScreen> createState() => _SubmitContentScreenState();
}

class _SubmitContentScreenState extends ConsumerState<SubmitContentScreen> {
  String? _selectedFestivalId;
  String? _selectedFestivalName;
  String _submissionType = 'wish'; // 'wish' | 'card'
  String _language = 'nepali';
  final TextEditingController _valueController = TextEditingController();
  bool _saving = false;
  Uint8List? _cardBytes;
  String? _cardFileName;

  @override
  void initState() {
    super.initState();
    _selectedFestivalId = widget.initialFestivalId;
    _selectedFestivalName = widget.initialFestivalName;
  }

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  Future<void> _submitContent() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    if (_selectedFestivalId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a festival')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      String valueToSave = _valueController.text.trim();
      if (_submissionType == 'card') {
        // Require either URL or picked image
        if (_cardBytes != null) {
          final path = 'cards/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg';
          final ref = FirebaseStorage.instance.ref(path);
          await ref.putData(_cardBytes!, SettableMetadata(contentType: 'image/jpeg'));
          valueToSave = await ref.getDownloadURL();
        } else if (valueToSave.isEmpty) {
          throw Exception('Please paste image URL or pick an image');
        }
      } else if (_submissionType == 'wish') {
        if (valueToSave.isEmpty) {
          throw Exception('Please enter your wish text');
        }
      }

      await FirebaseService().createSubmission(
        userId: user.uid,
        festivalId: _selectedFestivalId!,
        festivalName: _selectedFestivalName ?? '',
        type: _submissionType,
        language: _submissionType == 'wish' ? _language : null,
        value: valueToSave,
      );
      _valueController.clear();
      _cardBytes = null;
      _cardFileName = null;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Submitted for review')),
        );
        Navigator.of(context).maybePop();
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

  Future<void> _pickCardImage() async {
    try {
      final ip.ImagePicker picker = ip.ImagePicker();
      final ip.XFile? image = await picker.pickImage(source: ip.ImageSource.gallery, maxWidth: 1440);
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _cardBytes = bytes;
          _cardFileName = image.name;
          _valueController.clear();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final festivals = ref.watch(festivalProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Submit Content')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
            if (_submissionType == 'wish')
              TextFormField(
                controller: _valueController,
                decoration: const InputDecoration(
                  labelText: 'Wish text',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              )
            else ...[
              TextFormField(
                controller: _valueController,
                decoration: const InputDecoration(
                  labelText: 'Card image URL (optional if picking from device)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 1,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickCardImage,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Pick from device'),
                  ),
                  const SizedBox(width: 12),
                  if (_cardFileName != null)
                    Expanded(
                      child: Text(
                        _cardFileName!,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
              if (_cardBytes != null) ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    _cardBytes!,
                    height: 160,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
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
          ],
        ),
      ),
    );
  }
}


