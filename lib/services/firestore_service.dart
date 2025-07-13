import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/diary_model.dart';
import '../models/entry_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // Get user display name by UID
  Future<String> getUserDisplayName(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return data['displayName'] ?? 'Unknown User';
      }
      return 'Unknown User';
    } catch (e) {
      print('Error getting user display name: $e');
      return 'Unknown User';
    }
  }

  // Create a new diary
  Future<String> createDiary({
    required String title,
    required String createdBy,
    String? description,
  }) async {
    try {
      String diaryId = _uuid.v4();

      DiaryModel diary = DiaryModel(
        id: diaryId,
        title: title,
        createdBy: createdBy,
        members: [createdBy], // Creator is automatically a member
        createdAt: DateTime.now(),
        description: description,
      );

      await _firestore.collection('diaries').doc(diaryId).set(diary.toMap());

      return diaryId;
    } catch (e) {
      print('Error creating diary: $e');
      rethrow;
    }
  }

  // Get diaries for a user
  Stream<List<DiaryModel>> getUserDiaries(String userId) {
    return _firestore
        .collection('diaries')
        .where('members', arrayContains: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return DiaryModel.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  // Add member to diary
  Future<void> addMemberToDiary(String diaryId, String userId) async {
    try {
      await _firestore.collection('diaries').doc(diaryId).update({
        'members': FieldValue.arrayUnion([userId]),
      });
    } catch (e) {
      print('Error adding member to diary: $e');
      rethrow;
    }
  }

  // Join diary by ID
  Future<bool> joinDiaryById(String diaryId, String userId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('diaries').doc(diaryId).get();

      if (doc.exists) {
        await addMemberToDiary(diaryId, userId);
        return true;
      }
      return false;
    } catch (e) {
      print('Error joining diary: $e');
      return false;
    }
  }

  // Delete diary and all its entries
  Future<void> deleteDiary(String diaryId) async {
    try {
      final WriteBatch batch = _firestore.batch();

      // Get all entries in the diary
      final entriesSnapshot = await _firestore
          .collection('diaries')
          .doc(diaryId)
          .collection('entries')
          .get();

      // Delete all entries
      for (final doc in entriesSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Delete the diary document
      batch.delete(_firestore.collection('diaries').doc(diaryId));

      // Commit the batch
      await batch.commit();
    } catch (e) {
      print('Error deleting diary: $e');
      rethrow;
    }
  }

  // Create entry
  Future<String> createEntry({
    required String diaryId,
    required String content,
    required String createdBy,
    required String createdByName,
    required List<String> tags,
    String? mood,
    String? voiceTranscript,
  }) async {
    try {
      String entryId = _uuid.v4();

      EntryModel entry = EntryModel(
        id: entryId,
        diaryId: diaryId,
        content: content,
        createdBy: createdBy,
        createdByName: createdByName,
        createdAt: DateTime.now(),
        tags: tags,
        mood: mood,
        voiceTranscript: voiceTranscript,
      );

      await _firestore
          .collection('diaries')
          .doc(diaryId)
          .collection('entries')
          .doc(entryId)
          .set(entry.toMap());

      return entryId;
    } catch (e) {
      print('Error creating entry: $e');
      rethrow;
    }
  }

  // Get entries for a diary
  Stream<List<EntryModel>> getDiaryEntries(String diaryId) {
    return _firestore
        .collection('diaries')
        .doc(diaryId)
        .collection('entries')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return EntryModel.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  // Get entries filtered by tag
  Stream<List<EntryModel>> getDiaryEntriesByTag(String diaryId, String tag) {
    return _firestore
        .collection('diaries')
        .doc(diaryId)
        .collection('entries')
        .where('tags', arrayContains: tag)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return EntryModel.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  // Update entry
  Future<void> updateEntry(
      String diaryId, String entryId, Map<String, dynamic> updates) async {
    try {
      await _firestore
          .collection('diaries')
          .doc(diaryId)
          .collection('entries')
          .doc(entryId)
          .update(updates);
    } catch (e) {
      print('Error updating entry: $e');
      rethrow;
    }
  }

  // Delete entry
  Future<void> deleteEntry(String diaryId, String entryId) async {
    try {
      await _firestore
          .collection('diaries')
          .doc(diaryId)
          .collection('entries')
          .doc(entryId)
          .delete();
    } catch (e) {
      print('Error deleting entry: $e');
      rethrow;
    }
  }
}
