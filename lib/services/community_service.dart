import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class Discussion {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final String authorName;
  final String authorImageUrl;
  final DateTime createdAt;
  final int commentCount;

  Discussion({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.authorImageUrl,
    required this.createdAt,
    required this.commentCount,
  });

  // Factory constructor to create a Discussion from a Firestore document
  factory Discussion.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Discussion(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? 'Unknown',
      authorImageUrl: data['authorImageUrl'] ?? 'asset/images/profile.png',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      commentCount: data['commentCount'] ?? 0,
    );
  }

  // Convert Discussion to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'authorImageUrl': authorImageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'commentCount': commentCount,
    };
  }
}

class Comment {
  final String id;
  final String discussionId;
  final String content;
  final String authorId;
  final String authorName;
  final String authorImageUrl;
  final DateTime createdAt;
  final String? parentCommentId; // null if it's a top-level comment

  Comment({
    required this.id,
    required this.discussionId,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.authorImageUrl,
    required this.createdAt,
    this.parentCommentId,
  });

  // Factory constructor to create a Comment from a Firestore document
  factory Comment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Comment(
      id: doc.id,
      discussionId: data['discussionId'] ?? '',
      content: data['content'] ?? '',
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? 'Unknown',
      authorImageUrl: data['authorImageUrl'] ?? 'asset/images/profile.png',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      parentCommentId: data['parentCommentId'],
    );
  }

  // Convert Comment to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'discussionId': discussionId,
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'authorImageUrl': authorImageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'parentCommentId': parentCommentId,
    };
  }
}

class CommunityService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Reference to collections
  CollectionReference get discussionsRef => _db.collection('discussions');
  CollectionReference get commentsRef => _db.collection('comments');

  // Get all discussions ordered by creation date
  Stream<List<Discussion>> getDiscussions() {
    return discussionsRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Discussion.fromFirestore(doc))
          .toList();
    });
  }

  // Get a single discussion by ID
  Future<Discussion?> getDiscussion(String discussionId) async {
    try {
      final doc = await discussionsRef.doc(discussionId).get();
      if (doc.exists) {
        return Discussion.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting discussion: $e');
      return null;
    }
  }

  // Create a new discussion
  Future<String?> createDiscussion(String title, String content) async {
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      // Get user profile info
      final userDoc = await _db.collection('users').doc(user.uid).get();
      final userData = userDoc.data() as Map<String, dynamic>?;
      
      final discussion = Discussion(
        id: '', // Will be set by Firestore
        title: title,
        content: content,
        authorId: user.uid,
        authorName: userData?['name'] ?? user.displayName ?? 'Anonymous',
        authorImageUrl: userData?['photoURL'] ?? user.photoURL ?? 'asset/images/profile.png',
        createdAt: DateTime.now(),
        commentCount: 0,
      );

      final docRef = await discussionsRef.add(discussion.toFirestore());
      return docRef.id;
    } catch (e) {
      debugPrint('Error creating discussion: $e');
      return null;
    }
  }

  // Get comments for a discussion with pagination
  Stream<List<Comment>> getCommentsWithLimit(String discussionId, {int limit = 20}) {
    return commentsRef
        .where('discussionId', isEqualTo: discussionId)
        .where('parentCommentId', isNull: true) // Only fetch top-level comments
        .orderBy('createdAt', descending: false)
        .limit(limit) // Limit the number of comments fetched
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Comment.fromFirestore(doc))
          .toList();
    });
  }
  
  // Get comments for a discussion (original method for backward compatibility)
  Stream<List<Comment>> getComments(String discussionId) {
    return commentsRef
        .where('discussionId', isEqualTo: discussionId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Comment.fromFirestore(doc))
          .toList();
    });
  }

  // Get replies to a specific comment with limit
  Stream<List<Comment>> getRepliesWithLimit(String commentId, {int limit = 5}) {
    return commentsRef
        .where('parentCommentId', isEqualTo: commentId)
        .orderBy('createdAt', descending: false)
        .limit(limit) // Limit the number of replies fetched
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Comment.fromFirestore(doc))
          .toList();
    });
  }
  
  // Get replies to a specific comment (original method for backward compatibility)
  Stream<List<Comment>> getReplies(String commentId) {
    return commentsRef
        .where('parentCommentId', isEqualTo: commentId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Comment.fromFirestore(doc))
          .toList();
    });
  }

  // Add a comment to a discussion
  Future<String?> addComment(String discussionId, String content, {String? parentCommentId}) async {
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      // Get user profile info
      final userDoc = await _db.collection('users').doc(user.uid).get();
      final userData = userDoc.data() as Map<String, dynamic>?;
      
      final comment = Comment(
        id: '', // Will be set by Firestore
        discussionId: discussionId,
        content: content,
        authorId: user.uid,
        authorName: userData?['name'] ?? user.displayName ?? 'Anonymous',
        authorImageUrl: userData?['photoURL'] ?? user.photoURL ?? 'asset/images/profile.png',
        createdAt: DateTime.now(),
        parentCommentId: parentCommentId,
      );

      // Add the comment
      final docRef = await commentsRef.add(comment.toFirestore());
      
      // Update comment count in the discussion
      await discussionsRef.doc(discussionId).update({
        'commentCount': FieldValue.increment(1),
      });
      
      return docRef.id;
    } catch (e) {
      debugPrint('Error adding comment: $e');
      return null;
    }
  }

  // Delete a discussion (only by the author)
  Future<bool> deleteDiscussion(String discussionId) async {
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      // Check if user is the author
      final discussionDoc = await discussionsRef.doc(discussionId).get();
      final discussionData = discussionDoc.data() as Map<String, dynamic>?;
      
      if (discussionData?['authorId'] != user.uid) {
        throw Exception('Only the author can delete this discussion');
      }

      // Delete all comments in this discussion
      final commentsQuery = await commentsRef.where('discussionId', isEqualTo: discussionId).get();
      final batch = _db.batch();
      
      for (var doc in commentsQuery.docs) {
        batch.delete(doc.reference);
      }
      
      // Delete the discussion
      batch.delete(discussionsRef.doc(discussionId));
      
      await batch.commit();
      return true;
    } catch (e) {
      debugPrint('Error deleting discussion: $e');
      return false;
    }
  }

  // Delete a comment (only by the author)
  Future<bool> deleteComment(String commentId) async {
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      // Check if user is the author
      final commentDoc = await commentsRef.doc(commentId).get();
      final commentData = commentDoc.data() as Map<String, dynamic>?;
      
      if (commentData?['authorId'] != user.uid) {
        throw Exception('Only the author can delete this comment');
      }

      final discussionId = commentData?['discussionId'];
      
      // Delete the comment
      await commentsRef.doc(commentId).delete();
      
      // Update comment count in the discussion
      if (discussionId != null) {
        await discussionsRef.doc(discussionId).update({
          'commentCount': FieldValue.increment(-1),
        });
      }
      
      return true;
    } catch (e) {
      debugPrint('Error deleting comment: $e');
      return false;
    }
  }
} 