import 'package:flutter/material.dart';
import 'package:nepali_festival_wishes/models/festival_model.dart';
import 'package:nepali_festival_wishes/services/firebase_service.dart';

class FestivalFormScreen extends StatefulWidget {
  final Festival? festival;

  const FestivalFormScreen({Key? key, this.festival}) : super(key: key);

  @override
  State<FestivalFormScreen> createState() => _FestivalFormScreenState();
}

class _FestivalFormScreenState extends State<FestivalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  String _selectedCategory = 'Religious';
  final _dateController = TextEditingController();
  final List<TextEditingController> _nepaliWishesControllers = [];
  final List<TextEditingController> _englishWishesControllers = [];
  final List<TextEditingController> _cardImageUrlsControllers = [];

  @override
  void initState() {
    super.initState();
    if (widget.festival != null) {
      _nameController.text = widget.festival!.name;
      _descriptionController.text = widget.festival!.description;
      _imageUrlController.text = widget.festival!.imageUrl;
      _selectedCategory = widget.festival!.category;
      _dateController.text = widget.festival!.date.toString().split(' ')[0];

      // Initialize wishes controllers
      for (var wish in widget.festival!.nepaliWishes) {
        _nepaliWishesControllers.add(TextEditingController(text: wish));
      }
      for (var wish in widget.festival!.englishWishes) {
        _englishWishesControllers.add(TextEditingController(text: wish));
      }
      for (var url in widget.festival!.cardImageUrls) {
        _cardImageUrlsControllers.add(TextEditingController(text: url));
      }
    }

    // Add empty controllers if none exist
    if (_nepaliWishesControllers.isEmpty) {
      _nepaliWishesControllers.add(TextEditingController());
    }
    if (_englishWishesControllers.isEmpty) {
      _englishWishesControllers.add(TextEditingController());
    }
    if (_cardImageUrlsControllers.isEmpty) {
      _cardImageUrlsControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _dateController.dispose();
    for (var controller in _nepaliWishesControllers) {
      controller.dispose();
    }
    for (var controller in _englishWishesControllers) {
      controller.dispose();
    }
    for (var controller in _cardImageUrlsControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final festival = Festival(
        id: widget.festival?.id ?? '',
        name: _nameController.text,
        description: _descriptionController.text,
        imageUrl: _imageUrlController.text,
        category: _selectedCategory,
        date: DateTime.parse(_dateController.text),
        nepaliWishes: _nepaliWishesControllers
            .map((c) => c.text)
            .where((text) => text.isNotEmpty)
            .toList(),
        englishWishes: _englishWishesControllers
            .map((c) => c.text)
            .where((text) => text.isNotEmpty)
            .toList(),
        cardImageUrls: _cardImageUrlsControllers
            .map((c) => c.text)
            .where((text) => text.isNotEmpty)
            .toList(),
      );

      if (widget.festival == null) {
        await FirebaseService().addFestival(festival);
      } else {
        await FirebaseService().updateFestival(festival.id, festival);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.festival == null
                  ? 'Festival added successfully'
                  : 'Festival updated successfully',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Widget _buildWishesSection(
      String title, List<TextEditingController> controllers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...controllers.map((controller) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: 'Enter $title',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () {
                      if (controllers.length > 1) {
                        setState(() {
                          controllers.remove(controller);
                          controller.dispose();
                        });
                      }
                    },
                  ),
                ],
              ),
            )),
        TextButton.icon(
          onPressed: () {
            setState(() {
              controllers.add(TextEditingController());
            });
          },
          icon: const Icon(Icons.add),
          label: Text('Add more $title'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.festival == null ? 'Add Festival' : 'Edit Festival'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Festival Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter festival name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: ['Religious', 'Cultural', 'Seasonal']
                    .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'Date (YYYY-MM-DD)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter date';
                  }
                  try {
                    DateTime.parse(value);
                    return null;
                  } catch (_) {
                    return 'Please enter valid date (YYYY-MM-DD)';
                  }
                },
              ),
              const SizedBox(height: 24),
              _buildWishesSection('Nepali Wishes', _nepaliWishesControllers),
              const SizedBox(height: 24),
              _buildWishesSection('English Wishes', _englishWishesControllers),
              const SizedBox(height: 24),
              _buildWishesSection('Card Image URLs', _cardImageUrlsControllers),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                child: Text(
                  widget.festival == null ? 'Add Festival' : 'Update Festival',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
