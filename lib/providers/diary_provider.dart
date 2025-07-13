import 'package:flutter/material.dart';
import '../models/diary_model.dart';
import '../models/entry_model.dart';
import '../services/firestore_service.dart';

class DiaryProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<DiaryModel> _diaries = [];
  List<EntryModel> _entries = [];
  DiaryModel? _selectedDiary;
  bool _isLoading = false;
  String? _error;
  String? _selectedTag;

  List<DiaryModel> get diaries => _diaries;
  List<EntryModel> get entries => _entries;
  DiaryModel? get selectedDiary => _selectedDiary;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedTag => _selectedTag;

  // Get filtered entries based on selected tag
  List<EntryModel> get filteredEntries {
    if (_selectedTag == null || _selectedTag!.isEmpty) {
      return _entries;
    }
    return _entries
        .where((entry) => entry.tags.contains(_selectedTag))
        .toList();
  }

  // Get all unique tags from entries
  List<String> get allTags {
    Set<String> tags = {};
    for (var entry in _entries) {
      tags.addAll(entry.tags);
    }
    return tags.toList()..sort();
  }

  void setSelectedTag(String? tag) {
    _selectedTag = tag;
    notifyListeners();
  }

  void clearSelectedTag() {
    _selectedTag = null;
    notifyListeners();
  }

  Future<void> loadUserDiaries(String userId) async {
    _firestoreService.getUserDiaries(userId).listen((diaries) {
      _diaries = diaries;
      notifyListeners();
    });
  }

  Future<bool> createDiary({
    required String title,
    required String createdBy,
    String? description,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _firestoreService.createDiary(
        title: title,
        createdBy: createdBy,
        description: description,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> joinDiary(String diaryId, String userId) async {
    _setLoading(true);
    _clearError();

    try {
      bool success = await _firestoreService.joinDiaryById(diaryId, userId);
      _setLoading(false);
      if (!success) {
        _setError('Diary not found or you don\'t have permission to join');
      }
      return success;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteDiary(String diaryId) async {
    _setLoading(true);
    _clearError();

    try {
      await _firestoreService.deleteDiary(diaryId);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  void selectDiary(DiaryModel diary) {
    _selectedDiary = diary;
    _loadDiaryEntries(diary.id);
    notifyListeners();
  }

  void _loadDiaryEntries(String diaryId) {
    _firestoreService.getDiaryEntries(diaryId).listen((entries) {
      _entries = entries;
      notifyListeners();
    });
  }

  Future<bool> createEntry({
    required String content,
    required String createdBy,
    required String createdByName,
    required List<String> tags,
    String? mood,
    String? voiceTranscript,
  }) async {
    if (_selectedDiary == null) return false;

    _setLoading(true);
    _clearError();

    try {
      await _firestoreService.createEntry(
        diaryId: _selectedDiary!.id,
        content: content,
        createdBy: createdBy,
        createdByName: createdByName,
        tags: tags,
        mood: mood,
        voiceTranscript: voiceTranscript,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<void> deleteEntry(String entryId) async {
    if (_selectedDiary == null) return;

    try {
      await _firestoreService.deleteEntry(_selectedDiary!.id, entryId);
    } catch (e) {
      _setError(e.toString());
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}
