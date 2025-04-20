import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Create or update a document
  Future<void> setDocument({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _db.collection(collection).doc(documentId).set(data, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error setting document: $e');
      rethrow;
    }
  }

  // Get a document
  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument({
    required String collection,
    required String documentId,
  }) async {
    try {
      return await _db.collection(collection).doc(documentId).get();
    } catch (e) {
      debugPrint('Error getting document: $e');
      rethrow;
    }
  }

  // Delete a document
  Future<void> deleteDocument({
    required String collection,
    required String documentId,
  }) async {
    try {
      await _db.collection(collection).doc(documentId).delete();
    } catch (e) {
      debugPrint('Error deleting document: $e');
      rethrow;
    }
  }

  // Get collection
  Stream<QuerySnapshot<Map<String, dynamic>>> streamCollection({
    required String collection,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) {
    try {
      var ref = _db.collection(collection);
      Query<Map<String, dynamic>> query = ref;
      
      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }
      
      if (limit != null) {
        query = query.limit(limit);
      }
      
      return query.snapshots();
    } catch (e) {
      debugPrint('Error streaming collection: $e');
      rethrow;
    }
  }

  // Query documents
  Future<QuerySnapshot<Map<String, dynamic>>> queryDocuments({
    required String collection,
    required List<QueryFilter> filters,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) async {
    try {
      var ref = _db.collection(collection);
      Query<Map<String, dynamic>> query = ref;
      
      for (var filter in filters) {
        query = query.where(
          filter.field, 
          isEqualTo: filter.isEqualTo,
          isNotEqualTo: filter.isNotEqualTo,
          isGreaterThan: filter.isGreaterThan,
          isGreaterThanOrEqualTo: filter.isGreaterThanOrEqualTo,
          isLessThan: filter.isLessThan,
          isLessThanOrEqualTo: filter.isLessThanOrEqualTo,
          arrayContains: filter.arrayContains,
          arrayContainsAny: filter.arrayContainsAny,
          whereIn: filter.whereIn,
          whereNotIn: filter.whereNotIn,
        );
      }
      
      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }
      
      if (limit != null) {
        query = query.limit(limit);
      }
      
      return await query.get();
    } catch (e) {
      debugPrint('Error querying documents: $e');
      rethrow;
    }
  }

  // Add user profile
  Future<void> createUserProfile({
    required String userId,
    required String name,
    required String email,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final userData = {
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        ...?additionalData,
      };
      
      await _db.collection('users').doc(userId).set(userData);
    } catch (e) {
      debugPrint('Error creating user profile: $e');
      rethrow;
    }
  }
}

class QueryFilter {
  final String field;
  final dynamic isEqualTo;
  final dynamic isNotEqualTo;
  final dynamic isGreaterThan;
  final dynamic isGreaterThanOrEqualTo;
  final dynamic isLessThan;
  final dynamic isLessThanOrEqualTo;
  final dynamic arrayContains;
  final List<dynamic>? arrayContainsAny;
  final List<dynamic>? whereIn;
  final List<dynamic>? whereNotIn;

  QueryFilter({
    required this.field,
    this.isEqualTo,
    this.isNotEqualTo,
    this.isGreaterThan,
    this.isGreaterThanOrEqualTo,
    this.isLessThan,
    this.isLessThanOrEqualTo,
    this.arrayContains,
    this.arrayContainsAny,
    this.whereIn,
    this.whereNotIn,
  });
} 