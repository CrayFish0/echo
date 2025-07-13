import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../models/diary_model.dart';
import '../../providers/diary_provider.dart';
import '../../providers/auth_provider.dart';

class EntryEditorScreen extends StatefulWidget {
  final DiaryModel diary;

  const EntryEditorScreen({super.key, required this.diary});

  @override
  State<EntryEditorScreen> createState() => _EntryEditorScreenState();
}

class _EntryEditorScreenState extends State<EntryEditorScreen>
    with TickerProviderStateMixin {
  final _contentController = TextEditingController();
  final _tagsController = TextEditingController();
  final _scrollController = ScrollController();

  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _speechEnabled = false;
  String? _voiceTranscript;
  String? _selectedMood;
  bool _isPreviewMode = false;

  late TabController _tabController;

  final List<String> _moodOptions = [
    'Happy',
    'Sad',
    'Excited',
    'Calm',
    'Grateful',
    'Angry',
    'Anxious',
    'Peaceful'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initSpeech();
  }

  @override
  void dispose() {
    _contentController.dispose();
    _tagsController.dispose();
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _initSpeech() async {
    _speech = stt.SpeechToText();
    _speechEnabled = await _speech.initialize();
    setState(() {});
  }

  void _startListening() async {
    if (_speechEnabled) {
      setState(() {
        _isListening = true;
        _voiceTranscript = '';
      });

      await _speech.listen(
        onResult: (result) {
          setState(() {
            _voiceTranscript = result.recognizedWords;
            if (result.finalResult) {
              _isListening = false;
              // Add the recognized text to the content
              final currentText = _contentController.text;
              final newText = currentText.isEmpty
                  ? result.recognizedWords
                  : '$currentText\n\n${result.recognizedWords}';
              _contentController.text = newText;
              _contentController.selection = TextSelection.fromPosition(
                TextPosition(offset: _contentController.text.length),
              );
            }
          });
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
      );
    }
  }

  void _stopListening() async {
    await _speech.stop();
    setState(() {
      _isListening = false;
    });
  }

  List<String> _parseTags(String tagsText) {
    return tagsText
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
  }

  Future<void> _saveEntry() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write something in your entry'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final diaryProvider = Provider.of<DiaryProvider>(context, listen: false);

    final tags = _parseTags(_tagsController.text);

    bool success = await diaryProvider.createEntry(
      content: _contentController.text.trim(),
      createdBy: authProvider.user!.uid,
      createdByName: authProvider.user!.displayName,
      tags: tags,
      mood: _selectedMood,
      voiceTranscript: _voiceTranscript,
    );

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Entry saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(diaryProvider.error ?? 'Failed to save entry'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Entry - ${widget.diary.title}'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Write', icon: Icon(Icons.edit)),
            Tab(text: 'Preview', icon: Icon(Icons.preview)),
          ],
        ),
        actions: [
          Consumer<DiaryProvider>(
            builder: (context, diaryProvider, child) {
              return TextButton(
                onPressed: diaryProvider.isLoading ? null : _saveEntry,
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
                    : const Text(
                        'Save',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              );
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildWriteTab(),
          _buildPreviewTab(),
        ],
      ),
      floatingActionButton: _speechEnabled
          ? FloatingActionButton(
              onPressed: _isListening ? _stopListening : _startListening,
              backgroundColor: _isListening ? Colors.red : Colors.deepPurple,
              child: Icon(_isListening ? Icons.mic : Icons.mic_none),
            )
          : null,
    );
  }

  Widget _buildWriteTab() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Voice status indicator
          if (_isListening || _voiceTranscript != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isListening ? Colors.red[50] : Colors.blue[50],
                border: Border.all(
                  color: _isListening ? Colors.red[200]! : Colors.blue[200]!,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    color: _isListening ? Colors.red[700] : Colors.blue[700],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _isListening
                          ? 'Listening... ${_voiceTranscript ?? ""}'
                          : 'Voice transcript ready to insert',
                      style: TextStyle(
                        color:
                            _isListening ? Colors.red[700] : Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Content field
          const Text(
            'Your diary entry:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _contentController,
            maxLines: 15,
            decoration: InputDecoration(
              hintText:
                  'Write your diary entry here...\n\nYou can use Markdown formatting:\n'
                  '**bold text**\n*italic text*\n# Heading\n- List item\n\n'
                  'Use the microphone button to add voice input!',
              border: const OutlineInputBorder(),
              alignLabelWithHint: true,
              contentPadding: const EdgeInsets.all(16),
            ),
            style: const TextStyle(height: 1.5),
          ),
          const SizedBox(height: 24),

          // Mood selection
          const Text(
            'How are you feeling?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _moodOptions.map((mood) {
              final isSelected = _selectedMood == mood;
              return FilterChip(
                label: Text(mood),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedMood = selected ? mood : null;
                  });
                },
                selectedColor: Colors.deepPurple[100],
                checkmarkColor: Colors.deepPurple,
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Tags field
          const Text(
            'Tags (separate with commas):',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _tagsController,
            decoration: const InputDecoration(
              hintText: 'family, vacation, birthday, work...',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.tag),
            ),
          ),
          const SizedBox(height: 100), // Extra space for FAB
        ],
      ),
    );
  }

  Widget _buildPreviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Preview header
          Row(
            children: [
              const Icon(Icons.preview, color: Colors.deepPurple),
              const SizedBox(width: 8),
              Text(
                'Entry Preview',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Preview card
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mock header
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.deepPurple,
                        child: Icon(
                          Icons.person,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Consumer<AuthProvider>(
                            builder: (context, authProvider, child) {
                              return Text(
                                authProvider.user?.displayName ?? 'You',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              );
                            },
                          ),
                          Text(
                            'Now',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      if (_selectedMood != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _selectedMood!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Content preview
                  _contentController.text.trim().isEmpty
                      ? Text(
                          'Your diary entry will appear here...',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontStyle: FontStyle.italic,
                          ),
                        )
                      : MarkdownBody(
                          data: _contentController.text,
                          styleSheet: MarkdownStyleSheet(
                            p: const TextStyle(fontSize: 14, height: 1.5),
                            h1: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                            h2: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                            h3: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),

                  // Voice transcript indicator
                  if (_voiceTranscript != null &&
                      _voiceTranscript!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        border: Border.all(color: Colors.blue[200]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.mic, size: 16, color: Colors.blue[700]),
                          const SizedBox(width: 8),
                          Text(
                            'Voice transcription available',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Tags preview
                  if (_tagsController.text.trim().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _parseTags(_tagsController.text).map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple[50],
                            border: Border.all(color: Colors.deepPurple[200]!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '#$tag',
                            style: TextStyle(
                              color: Colors.deepPurple[700],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
