import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/diary_provider.dart';
import '../models/diary_model.dart';
import 'diary/diary_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final diaryProvider = Provider.of<DiaryProvider>(context, listen: false);

      if (authProvider.user != null) {
        diaryProvider.loadUserDiaries(authProvider.user!.uid);
      }
    });
  }

  void _showCreateDiaryDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Diary'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Diary Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          Consumer<DiaryProvider>(
            builder: (context, diaryProvider, child) {
              return ElevatedButton(
                onPressed: diaryProvider.isLoading
                    ? null
                    : () async {
                        if (titleController.text.trim().isNotEmpty) {
                          final authProvider =
                              Provider.of<AuthProvider>(context, listen: false);

                          bool success = await diaryProvider.createDiary(
                            title: titleController.text.trim(),
                            createdBy: authProvider.user!.uid,
                            description:
                                descriptionController.text.trim().isEmpty
                                    ? null
                                    : descriptionController.text.trim(),
                          );

                          if (success && mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Diary created successfully!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else if (!success && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(diaryProvider.error ??
                                    'Failed to create diary'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                child: diaryProvider.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create'),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showJoinDiaryDialog() {
    final diaryIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Join Diary'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: diaryIdController,
              decoration: const InputDecoration(
                labelText: 'Diary ID',
                hintText: 'Enter the diary ID to join',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ask a diary member to share the diary ID with you',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          Consumer<DiaryProvider>(
            builder: (context, diaryProvider, child) {
              return ElevatedButton(
                onPressed: diaryProvider.isLoading
                    ? null
                    : () async {
                        if (diaryIdController.text.trim().isNotEmpty) {
                          final authProvider =
                              Provider.of<AuthProvider>(context, listen: false);

                          bool success = await diaryProvider.joinDiary(
                            diaryIdController.text.trim(),
                            authProvider.user!.uid,
                          );

                          if (success && mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Joined diary successfully!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else if (!success && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(diaryProvider.error ??
                                    'Failed to join diary'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                child: diaryProvider.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Join'),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(DiaryModel diary) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Diary'),
        content: Text(
          'Are you sure you want to delete "${diary.title}"?\n\nThis action cannot be undone and will delete all entries in this diary.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          Consumer<DiaryProvider>(
            builder: (context, diaryProvider, child) {
              return ElevatedButton(
                onPressed: diaryProvider.isLoading
                    ? null
                    : () async {
                        bool success =
                            await diaryProvider.deleteDiary(diary.id);

                        if (mounted) {
                          Navigator.pop(context); // Close dialog

                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Diary deleted successfully!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(diaryProvider.error ??
                                    'Failed to delete diary'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: diaryProvider.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Delete'),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Diaries'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                Provider.of<AuthProvider>(context, listen: false).signOut();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<DiaryProvider>(
        builder: (context, diaryProvider, child) {
          if (diaryProvider.diaries.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.book_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No diaries yet',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your first diary or join an existing one',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: diaryProvider.diaries.length,
            itemBuilder: (context, index) {
              final diary = diaryProvider.diaries[index];
              return _buildDiaryCard(diary);
            },
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'join',
            onPressed: _showJoinDiaryDialog,
            backgroundColor: Colors.orange,
            child: const Icon(Icons.group_add),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'create',
            onPressed: _showCreateDiaryDialog,
            backgroundColor: Colors.deepPurple,
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget _buildDiaryCard(DiaryModel diary) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Colors.deepPurple,
          child: Text(
            diary.title.isNotEmpty ? diary.title[0].toUpperCase() : 'D',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          diary.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (diary.description != null) ...[
              const SizedBox(height: 4),
              Text(
                diary.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 4),
            Text(
              '${diary.members.length} member${diary.members.length == 1 ? '' : 's'}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            // Show "Created by you" indicator
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                if (authProvider.user?.uid == diary.createdBy) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Created by you',
                      style: TextStyle(
                        color: Colors.green[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                // Show diary ID for sharing
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Share Diary'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Share this ID with others to invite them:'),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SelectableText(
                            diary.id,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
            ),
            // Show delete button only for diary creators
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                if (authProvider.user?.uid == diary.createdBy) {
                  return IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _showDeleteConfirmation(diary),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const Icon(Icons.arrow_forward_ios),
          ],
        ),
        onTap: () {
          Provider.of<DiaryProvider>(context, listen: false).selectDiary(diary);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DiaryScreen(diary: diary),
            ),
          );
        },
      ),
    );
  }
}
