import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../models/diary_model.dart';
import '../../providers/diary_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';

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

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String? _selectedMood;
  bool _isPreviewMode = false;

  final List<Map<String, String>> _moodOptions = [
    {
      'emoji': '😊',
      'mood': 'Happy',
      'description': 'Feeling joyful and content'
    },
    {'emoji': '😢', 'mood': 'Sad', 'description': 'Feeling down or melancholy'},
    {
      'emoji': '😠',
      'mood': 'Angry',
      'description': 'Feeling frustrated or upset'
    },
    {
      'emoji': '😴',
      'mood': 'Tired',
      'description': 'Feeling exhausted or sleepy'
    },
    {
      'emoji': '😎',
      'mood': 'Excited',
      'description': 'Feeling energetic and thrilled'
    },
    {
      'emoji': '🤔',
      'mood': 'Thoughtful',
      'description': 'Feeling contemplative'
    },
    {
      'emoji': '😌',
      'mood': 'Peaceful',
      'description': 'Feeling calm and relaxed'
    },
    {
      'emoji': '😰',
      'mood': 'Anxious',
      'description': 'Feeling worried or nervous'
    },
    {
      'emoji': '😍',
      'mood': 'Grateful',
      'description': 'Feeling thankful and blessed'
    },
    {
      'emoji': '🙄',
      'mood': 'Frustrated',
      'description': 'Feeling annoyed or irritated'
    },
  ];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    _scrollController.dispose();
    super.dispose();
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface, // Use theme surface color
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    // Custom Header
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: colorScheme.surface, // Use theme surface color
                        // Removed border for seamless look
                      ),
                      child: Row(
                        children: [
                          // Back button
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF2C2C2E)
                                    : const Color(0xFFF2F2F7),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.arrow_back_ios_new,
                                size: 18,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF1C1C1E),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Title section
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'New Entry',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF1C1C1E),
                                  ),
                                ),
                                Text(
                                  widget.diary.title,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark
                                        ? const Color(0xFF8E8E93)
                                        : const Color(0xFF6D6D70),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Save button
                          Consumer<DiaryProvider>(
                            builder: (context, diaryProvider, child) {
                              return TweenAnimationBuilder<double>(
                                duration: const Duration(milliseconds: 1000),
                                tween: Tween(begin: 0.0, end: 1.0),
                                curve: Curves.elasticOut,
                                builder: (context, animationValue, child) {
                                  return Transform.scale(
                                    scale: 0.8 + (0.2 * animationValue),
                                    child: GestureDetector(
                                      onTap: diaryProvider.isLoading
                                          ? null
                                          : _saveEntry,
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        curve: Curves.easeInOut,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 10),
                                        decoration: BoxDecoration(
                                          gradient: diaryProvider.isLoading
                                              ? null
                                              : LinearGradient(
                                                  colors: [
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .primary
                                                        .withOpacity(0.8),
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                          color: diaryProvider.isLoading
                                              ? (isDark
                                                  ? const Color(0xFF2C2C2E)
                                                  : const Color(0xFFE5E5EA))
                                              : null,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          boxShadow: diaryProvider.isLoading
                                              ? null
                                              : [
                                                  BoxShadow(
                                                    color:
                                                        const Color(0xFF007AFF)
                                                            .withOpacity(0.3),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                        ),
                                        child: diaryProvider.isLoading
                                            ? const SizedBox(
                                                height: 20,
                                                width: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                              Color>(
                                                          Color(0xFF007AFF)),
                                                ),
                                              )
                                            : Text(
                                                'Save',
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                              .brightness ==
                                                          Brightness.dark
                                                      ? const Color(0xFF1C1C1E)
                                                      : Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    // Custom Tab Bar
                    Container(
                      margin: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _isPreviewMode = false),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  gradient: !_isPreviewMode
                                      ? LinearGradient(
                                          colors: [
                                            Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withOpacity(0.8),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : null,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.edit,
                                      size: 18,
                                      color: !_isPreviewMode
                                          ? (Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? const Color(0xFF1C1C1E)
                                              : Colors.white)
                                          : (isDark
                                              ? const Color(0xFF8E8E93)
                                              : const Color(0xFF6D6D70)),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Write',
                                      style: TextStyle(
                                        color: !_isPreviewMode
                                            ? (Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? const Color(0xFF1C1C1E)
                                                : Colors.white)
                                            : (isDark
                                                ? const Color(0xFF8E8E93)
                                                : const Color(0xFF6D6D70)),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _isPreviewMode = true),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  gradient: _isPreviewMode
                                      ? LinearGradient(
                                          colors: [
                                            Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withOpacity(0.8),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : null,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.preview,
                                      size: 18,
                                      color: _isPreviewMode
                                          ? (Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? const Color(0xFF1C1C1E)
                                              : Colors.white)
                                          : (isDark
                                              ? const Color(0xFF8E8E93)
                                              : const Color(0xFF6D6D70)),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Preview',
                                      style: TextStyle(
                                        color: _isPreviewMode
                                            ? (Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? const Color(0xFF1C1C1E)
                                                : Colors.white)
                                            : (isDark
                                                ? const Color(0xFF8E8E93)
                                                : const Color(0xFF6D6D70)),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Content Area
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        switchInCurve: Curves.easeInOut,
                        switchOutCurve: Curves.easeInOut,
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.3, 0),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: _isPreviewMode
                            ? _buildPreviewTab()
                            : _buildWriteTab(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildWriteTab() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Content section header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.edit_note,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF1C1C1E)
                      : Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Your diary entry',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Content field
          TextField(
            controller: _contentController,
            maxLines: 12,
            style: TextStyle(
              height: 1.6,
              fontSize: 16,
              color: isDark ? Colors.white : const Color(0xFF1C1C1E),
            ),
            decoration: InputDecoration(
              hintText: 'Write your diary entry here...',
              hintStyle: TextStyle(
                color:
                    isDark ? const Color(0xFF8E8E93) : const Color(0xFF6D6D70),
                fontSize: 16,
                height: 1.6,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: isDark
                      ? const Color(0xFF38383A)
                      : const Color(0xFFE5E5EA),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: isDark
                      ? const Color(0xFF38383A)
                      : const Color(0xFFE5E5EA),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFF007AFF),
                  width: 2,
                ),
              ),
              fillColor: isDark ? const Color(0xFF2C2C2E) : Colors.white,
              filled: true,
              contentPadding: const EdgeInsets.all(20),
            ),
          ),
          const SizedBox(height: 16),

          // Mood selection header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9500), // Orange color for mood
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.mood,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF1C1C1E)
                      : Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'How are you feeling?',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // All moods as tags
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _moodOptions.asMap().entries.map((entry) {
              final index = entry.key;
              final moodData = entry.value;
              final moodString = '${moodData['emoji']} ${moodData['mood']}';
              final isSelected = _selectedMood == moodString;

              return TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 600 + (index * 100)),
                tween: Tween(begin: 0.0, end: 1.0),
                curve: Curves.easeOutBack,
                builder: (context, animationValue, child) {
                  return Transform.scale(
                    scale: animationValue,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedMood = isSelected ? null : moodString;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.1)
                                : (isDark
                                    ? const Color(0xFF2C2C2E)
                                    : const Color(0xFFF2F2F7)),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : (isDark
                                      ? const Color(0xFF48484A)
                                      : const Color(0xFFD1D1D6)),
                              width: 1, // Keep consistent border width
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                moodData['emoji']!,
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                moodData['mood']!,
                                style: TextStyle(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : (isDark
                                          ? Colors.white
                                          : const Color(0xFF1C1C1E)),
                                  fontWeight: FontWeight
                                      .w500, // Keep consistent font weight
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 32),

          // Tags section header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF20B2AA), // Teal hue of primary blue
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.tag,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF1C1C1E)
                      : Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Tags',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tags field
          TextField(
            controller: _tagsController,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white : const Color(0xFF1C1C1E),
            ),
            decoration: InputDecoration(
              hintText: 'family, vacation, birthday, work...',
              hintStyle: TextStyle(
                color:
                    isDark ? const Color(0xFF8E8E93) : const Color(0xFF6D6D70),
                fontSize: 16,
              ),
              prefixIcon: Icon(
                Icons.tag,
                color:
                    isDark ? const Color(0xFF8E8E93) : const Color(0xFF6D6D70),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: isDark
                      ? const Color(0xFF38383A)
                      : const Color(0xFFE5E5EA),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: isDark
                      ? const Color(0xFF38383A)
                      : const Color(0xFFE5E5EA),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFF007AFF),
                  width: 2,
                ),
              ),
              fillColor: isDark ? const Color(0xFF2C2C2E) : Colors.white,
              filled: true,
              contentPadding: const EdgeInsets.all(20),
            ),
          ),
          const SizedBox(height: 100), // Extra space for FAB
        ],
      ),
    );
  }

  Widget _buildPreviewTab() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Preview card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mock header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF007AFF), Color(0xFF0051D5)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          size: 18,
                          color: Color(0xFF007AFF),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Consumer<AuthProvider>(
                            builder: (context, authProvider, child) {
                              return Text(
                                authProvider.user?.displayName ?? 'You',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF1C1C1E),
                                ),
                              );
                            },
                          ),
                          Text(
                            'Now',
                            style: TextStyle(
                              color: isDark
                                  ? const Color(0xFF8E8E93)
                                  : const Color(0xFF6D6D70),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_selectedMood != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF9500), Color(0xFFFF6B00)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _selectedMood!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Content preview
                _contentController.text.trim().isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1C1C1E)
                              : const Color(0xFFF2F2F7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF38383A)
                                : const Color(0xFFE5E5EA),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'Your diary entry will appear here...',
                          style: TextStyle(
                            color: isDark
                                ? const Color(0xFF8E8E93)
                                : const Color(0xFF6D6D70),
                            fontStyle: FontStyle.italic,
                            fontSize: 16,
                          ),
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1C1C1E)
                              : const Color(0xFFF2F2F7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: MarkdownBody(
                          data: _contentController.text,
                          styleSheet: MarkdownStyleSheet(
                            p: TextStyle(
                              fontSize: 16,
                              height: 1.6,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1C1C1E),
                            ),
                            h1: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1C1C1E),
                            ),
                            h2: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1C1C1E),
                            ),
                            h3: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1C1C1E),
                            ),
                            strong: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1C1C1E),
                            ),
                            em: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1C1C1E),
                            ),
                          ),
                        ),
                      ),

                // Tags preview
                if (_tagsController.text.trim().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _parseTags(_tagsController.text).map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF34C759), Color(0xFF248A3D)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '#$tag',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 100), // Extra space for FAB
        ],
      ),
    );
  }

  Widget _buildQuickMoodButton(Map<String, String> moodData, bool isDark) {
    final moodString = '${moodData['emoji']} ${moodData['mood']}';
    final isSelected = _selectedMood == moodString;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMood = isSelected ? null : moodString;
        });
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : (isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : (isDark ? const Color(0xFF48484A) : const Color(0xFFD1D1D6)),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              moodData['emoji']!,
              style: TextStyle(
                fontSize: isSelected ? 24 : 20,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              moodData['mood']!,
              style: TextStyle(
                color: isSelected
                    ? (Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF1C1C1E)
                        : Colors.white)
                    : (isDark ? Colors.white : const Color(0xFF1C1C1E)),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
