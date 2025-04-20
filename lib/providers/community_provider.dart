import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hortimize/services/community_service.dart';

class CommunityProvider with ChangeNotifier {
  final CommunityService _communityService = CommunityService();
  
  // State variables
  List<Discussion> _discussions = [];
  bool _isLoading = false;
  String _errorMessage = '';
  
  // Maps to cache comments for each discussion
  Map<String, List<Comment>> _commentsCache = {};
  Map<String, List<Comment>> _repliesCache = {};
  
  // Getters
  List<Discussion> get discussions => _discussions;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  
  // Stream subscriptions
  StreamSubscription<List<Discussion>>? _discussionsSubscription;
  Map<String, StreamSubscription<List<Comment>>> _commentsSubscriptions = {};
  
  // Initialize the provider
  CommunityProvider() {
    _initDiscussionsStream();
  }
  
  // Setup the discussions stream
  void _initDiscussionsStream() {
    _isLoading = true;
    notifyListeners();
    
    _discussionsSubscription = _communityService.getDiscussions().listen(
      (discussions) {
        _discussions = discussions;
        _isLoading = false;
        notifyListeners();
        
        // Initialize comments for new discussions
        for (var discussion in discussions) {
          if (!_commentsCache.containsKey(discussion.id)) {
            _loadCommentsForDiscussion(discussion.id);
          }
        }
      },
      onError: (error) {
        _errorMessage = 'Error loading discussions: $error';
        _isLoading = false;
        notifyListeners();
      }
    );
  }
  
  // Load comments for a specific discussion
  void _loadCommentsForDiscussion(String discussionId) {
    _commentsSubscriptions[discussionId]?.cancel();
    
    _commentsSubscriptions[discussionId] = _communityService.getComments(discussionId).listen(
      (comments) {
        _commentsCache[discussionId] = comments;
        
        // Load replies for comments
        for (var comment in comments) {
          if (comment.parentCommentId == null) { // Only for top-level comments
            _loadRepliesForComment(comment.id);
          }
        }
        
        notifyListeners();
      },
      onError: (error) {
        debugPrint('Error loading comments for discussion $discussionId: $error');
      }
    );
  }
  
  // Load replies for a specific comment
  void _loadRepliesForComment(String commentId) {
    _communityService.getReplies(commentId).listen(
      (replies) {
        _repliesCache[commentId] = replies;
        notifyListeners();
      },
      onError: (error) {
        debugPrint('Error loading replies for comment $commentId: $error');
      }
    );
  }
  
  // Get comments for a specific discussion
  List<Comment> getCommentsForDiscussion(String discussionId) {
    return _commentsCache[discussionId] ?? [];
  }
  
  // Get top-level comments for a specific discussion
  List<Comment> getTopLevelCommentsForDiscussion(String discussionId) {
    final comments = _commentsCache[discussionId] ?? [];
    return comments.where((comment) => comment.parentCommentId == null).toList();
  }
  
  // Get replies for a specific comment
  List<Comment> getRepliesForComment(String commentId) {
    return _repliesCache[commentId] ?? [];
  }
  
  // Create a new discussion
  Future<bool> createDiscussion(String title, String content) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _communityService.createDiscussion(title, content);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error creating discussion: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Add a comment to a discussion
  Future<bool> addComment(String discussionId, String content, {String? parentCommentId}) async {
    try {
      await _communityService.addComment(discussionId, content, parentCommentId: parentCommentId);
      return true;
    } catch (e) {
      debugPrint('Error adding comment: $e');
      return false;
    }
  }
  
  @override
  void dispose() {
    // Cancel all subscriptions to avoid memory leaks
    _discussionsSubscription?.cancel();
    for (var subscription in _commentsSubscriptions.values) {
      subscription.cancel();
    }
    super.dispose();
  }
} 