import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepali_festival_wishes/models/festival_model.dart';
import 'package:nepali_festival_wishes/providers/auth_provider.dart';
import 'package:nepali_festival_wishes/services/firebase_service.dart';
import 'festival_form_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class _AdminTabs extends StatefulWidget {
  final List<Festival> festivals;
  const _AdminTabs({required this.festivals});
  @override
  State<_AdminTabs> createState() => _AdminTabsState();
}

class _AdminTabsState extends State<_AdminTabs> with TickerProviderStateMixin {
  late TabController _controller;
  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 2, vsync: this);
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _controller,
          tabs: const [
            Tab(text: 'Festivals'),
            Tab(text: 'Submissions'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _controller,
            children: [
              _FestivalsList(festivals: widget.festivals),
              const _SubmissionsList(),
            ],
          ),
        ),
      ],
    );
  }
}

class _FestivalsList extends StatelessWidget {
  final List<Festival> festivals;
  const _FestivalsList({required this.festivals});
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: festivals.length,
      itemBuilder: (context, index) {
        final festival = festivals[index];
        return ListTile(
          title: Text(festival.name),
          subtitle: Text(festival.category),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _editFestival(context, festival),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _deleteFestival(context, festival.id),
              ),
            ],
          ),
        );
      },
    );
  }

  void _editFestival(BuildContext context, Festival festival) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FestivalFormScreen(festival: festival),
      ),
    );
  }

  Future<void> _deleteFestival(BuildContext context, String festivalId) async {
    final confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Festival'),
        content: const Text('Are you sure you want to delete this festival?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseService().deleteFestival(festivalId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Festival deleted successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting festival: $e')),
        );
      }
    }
  }
}

class _SubmissionsList extends StatelessWidget {
  const _SubmissionsList();
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseService().getAllSubmissions(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(child: Text('No submissions'));
        }
        return ListView.separated(
          itemCount: docs.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final d = docs[index].data();
            final id = docs[index].id;
            return ListTile(
              title: Text('${d['festivalName']} • ${d['type']}'),
              subtitle: Text(d['type'] == 'wish' ? (d['value'] ?? '') : (d['value'] ?? '')),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () async {
                      // Approve: merge submission into festival
                      await _approveSubmission(context, id, d);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () async {
                      await FirebaseService()
                          .firestore
                          .collection('submissions')
                          .doc(id)
                          .update({'status': 'rejected'});
                    },
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _approveSubmission(
      BuildContext context, String id, Map<String, dynamic> d) async {
    final firestore = FirebaseService().firestore;
    final festivalRef = firestore.collection('festivals').doc(d['festivalId']);
    final snap = await festivalRef.get();
    if (!snap.exists) return;
    final data = snap.data() as Map<String, dynamic>;
    if (d['type'] == 'wish') {
      final field = d['language'] == 'nepali' ? 'nepaliWishes' : 'englishWishes';
      final List<dynamic> arr = List.from(data[field] ?? []);
      arr.add(d['value']);
      await festivalRef.update({field: arr});
    } else if (d['type'] == 'card') {
      final List<dynamic> arr = List.from(data['cardImageUrls'] ?? []);
      arr.add(d['value']);
      await festivalRef.update({'cardImageUrls': arr});
    }
    await firestore.collection('submissions').doc(id).update({'status': 'approved'});
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Submission approved')));
  }
}

class AdminScreen extends ConsumerWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(isAdminProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
      ),
      body: isAdmin.when(
        data: (isAdmin) {
          if (!isAdmin) {
            return const Center(
              child: Text('You do not have admin access.'),
            );
          }

          return StreamBuilder<List<Festival>>(
            stream: FirebaseService().getFestivals(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final festivals = snapshot.data!;
              return _AdminTabs(festivals: festivals);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) =>
            const Center(child: Text('Error checking admin status')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addNewFestival(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _addNewFestival(BuildContext context) {
    // Navigate to add festival form
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FestivalFormScreen(),
      ),
    );
  }
}
