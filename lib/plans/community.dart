import 'package:flutter/material.dart';
import 'package:hortimize/climate/climate.dart';
import 'package:hortimize/hero_page/hero_page.dart';
import 'package:hortimize/market_demand/market_demand.dart';
import 'package:hortimize/plans/plans.dart';
import 'package:hortimize/services/community_service.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class Community extends StatefulWidget {
  const Community({super.key});

  @override
  State<Community> createState() => _CommunityState();
}

class _CommunityState extends State<Community> {
  final CommunityService _communityService = CommunityService();
  bool _isLoading = false;

  // Helper function to format date
  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // Helper function to truncate text for summary
  String _truncateText(String text, int maxWords) {
    final words = text.split(' ');
    if (words.length <= maxWords) return text;
    return '${words.take(maxWords).join(' ')}...';
  }

  void _showNewDiscussionDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Discussion'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter a title for your discussion',
                ),
                maxLength: 100,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  hintText: 'What would you like to discuss?',
                ),
                maxLines: 5,
                maxLength: 2000,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = titleController.text.trim();
              final content = contentController.text.trim();

              if (title.isEmpty || content.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Please enter both title and content')),
                );
                return;
              }

              Navigator.pop(context);

              setState(() {
                _isLoading = true;
              });

              try {
                await _communityService.createDiscussion(title, content);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Discussion created successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error creating discussion: $e')),
                  );
                }
              } finally {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                  });
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showDiscussionDetails(Discussion discussion) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DiscussionDetailPage(discussion: discussion),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Community Forum",
          style: TextStyle(fontFamily: "Poppins", fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: CircleAvatar(
              radius: 18,
              backgroundImage: const AssetImage("asset/images/profile.png"),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("asset/images/homescreen.jpeg"),
            fit: BoxFit.cover,
            opacity: 0.7,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
          child: Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color(0xffd8d8d8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.only(top: 10, bottom: 20),
                  child: Text(
                      "Community Discussions",
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                ),
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : StreamBuilder<List<Discussion>>(
                          stream: _communityService.getDiscussions(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            if (snapshot.hasError) {
                              // Handle index creation errors
                              final errorMsg = snapshot.error.toString();
                              if (errorMsg.contains('FAILED_PRECONDITION') ||
                                  errorMsg.contains('requires an index')) {
                                return const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                                      CircularProgressIndicator(),
                                      SizedBox(height: 20),
                            Text(
                                        'Setting up database indexes...',
                              style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 30),
                                        child: Text(
                                          'This happens only once. Please wait a moment or try again later.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Colors.grey),
                                        ),
                            ),
                          ],
                        ),
                                );
                              }

                              // For other errors
                              return Center(
                                child: Text(
                                  'Error loading discussions: ${snapshot.error}',
                                  style: const TextStyle(color: Colors.red),
                                ),
                              );
                            }

                            final discussions = snapshot.data ?? [];

                            if (discussions.isEmpty) {
                              return const Center(
                                child: Text(
                                  'No discussions yet. Be the first to create one!',
                                  style: TextStyle(fontSize: 16),
                                ),
                              );
                            }

                            return ListView.builder(
                              itemCount: discussions.length,
                              itemBuilder: (context, index) {
                                final discussion = discussions[index];
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Author info row
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 16,
                                          backgroundImage: discussion
                                                  .authorImageUrl
                                                  .startsWith('asset/')
                                              ? AssetImage(
                                                  discussion.authorImageUrl)
                                              : NetworkImage(
                                                      discussion.authorImageUrl)
                                                  as ImageProvider,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                          children: [
                                              Text(
                                                discussion.authorName,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                            ),
                            Text(
                                                _formatDate(
                                                    discussion.createdAt),
                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[700],
                                                ),
                            ),
                          ],
                        ),
                      ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),

                                    // Discussion content
                                    GestureDetector(
                                      onTap: () =>
                                          _showDiscussionDetails(discussion),
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        width: double.infinity,
                                        height:
                                            160, // Fixed height for all discussion containers
                      decoration: BoxDecoration(
                                          color: const Color(0xffb6c5c1),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                          children: [
                            Text(
                                              discussion.title,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                fontFamily: "Poppins",
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Expanded(
                                              child: Text(
                                                _truncateText(
                                                    discussion.content, 25),
                                                maxLines: 4,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontFamily: "Poppins",
                        ),
                      ),
                    ),
                  ],
                ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    // Action buttons
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                  children: [
                                        GestureDetector(
                                          onTap: () => _showDiscussionDetails(
                                              discussion),
                                          child: Container(
                                            height: 24,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8),
                      decoration: BoxDecoration(
                                              color: const Color(0xffb6c5c1),
                                              borderRadius:
                                                  BorderRadius.circular(3),
                      ),
                                            child: const Padding(
                                              padding: EdgeInsets.all(2.0),
                        child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                          children: [
                            Icon(
                              Icons.remove_red_eye,
                              size: 15,
                            ),
                                                  SizedBox(width: 4),
                            Text(
                              "Read more",
                              style: TextStyle(
                                                        fontSize: 12,
                                                        fontFamily: "Poppins"),
                            ),
                          ],
                        ),
                      ),
                    ),
                                        ),
                                        SizedBox(width: 10),
                                        GestureDetector(
                                          onTap: () => _showDiscussionDetails(
                                              discussion),
                                          child: Container(
                                            height: 24,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8),
                      decoration: BoxDecoration(
                                              color: const Color(0xffb6c5c1),
                                              borderRadius:
                                                  BorderRadius.circular(3),
                      ),
                      child: Padding(
                                              padding:
                                                  const EdgeInsets.all(2.0),
                        child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                          children: [
                                                  const Icon(
                              Icons.comment_bank,
                              size: 15,
                            ),
                                                  const SizedBox(width: 4),
                            Text(
                                                    "${discussion.commentCount} comments",
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        fontFamily: "Poppins"),
                            ),
                          ],
                        ),
                      ),
                    ),
                                        ),
                                        
                                      ],
                                    ),
                                    // Add divider between discussions
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      child: Divider(
                                        color: Colors.grey[400],
                                        thickness: 1,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                      ),
                    ),
                  ],
                ),
          ),
        ),
      ),
      // Add floating action button for creating new discussions
      floatingActionButton: FloatingActionButton(
        onPressed: _showNewDiscussionDialog,
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart), label: "Market"),
            BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart), label: "Plans"),
            BottomNavigationBarItem(icon: Icon(Icons.cloud), label: "Climate"),
          ],
          currentIndex: 2,
          onTap: (index) {
            if (index == 0) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HeroPage()),
                (route) =>
                    false, // This removes all previous routes from the stack
              );
            } else if (index == 1) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MarketDemandPage()));
            } else if (index == 2) {
              Navigator.pop(context);
            } else if (index == 3) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Climate()));
            }
          }),
    );
  }
}

// Page to display full discussion details and comments
class DiscussionDetailPage extends StatefulWidget {
  final Discussion discussion;

  const DiscussionDetailPage({super.key, required this.discussion});

  @override
  State<DiscussionDetailPage> createState() => _DiscussionDetailPageState();
}

class _DiscussionDetailPageState extends State<DiscussionDetailPage> {
  final CommunityService _communityService = CommunityService();
  final TextEditingController _commentController = TextEditingController();
  String? _replyingToCommentId;
  String _replyingToUsername = '';
  bool _isSubmitting = false;
  List<Comment> _localComments = [];
  Map<String, List<Comment>> _localReplies = {}; // To store replies locally
  bool _forceRefresh = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // Shimmer loading effect for comments
  Widget _buildCommentShimmer() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
                        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
            // Avatar
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Author name
                  Container(
                    width: 120,
                    height: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  // Comment content
                  Container(
                    width: double.infinity,
                    height: 60,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 4),
                  // Reply button
                    Container(
                    width: 60,
                      height: 20,
                    color: Colors.white,
                  ),
                ],
              ),
                            ),
                          ],
                        ),
                      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  void _setReplyingTo(Comment comment) {
    setState(() {
      _replyingToCommentId = comment.id;
      _replyingToUsername = comment.authorName;
    });

    // Focus the text field and set hint text
    FocusScope.of(context).requestFocus(FocusNode());
    _commentController.text = '@${comment.authorName} ';
  }

  void _cancelReply() {
    setState(() {
      _replyingToCommentId = null;
      _replyingToUsername = '';
      _commentController.clear();
    });
  }

  Future<void> _submitComment() async {
    final content = _commentController.text.trim();

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a comment')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final commentId = await _communityService.addComment(
        widget.discussion.id,
        content,
        parentCommentId: _replyingToCommentId,
      );

      // Clear input field and reset replying state
      _commentController.clear();

      // Create a local copy of the comment to display immediately
      if (commentId != null && mounted) {
        final user = _communityService.currentUser;
        if (user != null) {
          // Add a temporary local comment
          final newComment = Comment(
            id: commentId,
            discussionId: widget.discussion.id,
            content: content,
            authorId: user.uid,
            authorName: user.displayName ?? 'You',
            authorImageUrl: user.photoURL ?? 'asset/images/profile.png',
            createdAt: DateTime.now(),
            parentCommentId: _replyingToCommentId,
          );

          // Add comment to the proper local collection
          setState(() {
            if (_replyingToCommentId == null) {
              // It's a top-level comment
              _localComments.add(newComment);
            } else {
              // It's a reply
              _localReplies[_replyingToCommentId!] ??= [];
              _localReplies[_replyingToCommentId!]!.add(newComment);

              // Clear reply state after adding
              _cancelReply();
            }
            _forceRefresh = !_forceRefresh;
          });

          // Show a success message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Comment posted successfully')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error posting comment: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Widget _buildCommentItem(Comment comment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: comment.authorImageUrl.startsWith('asset/')
                  ? AssetImage(comment.authorImageUrl)
                  : NetworkImage(comment.authorImageUrl) as ImageProvider,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                  Row(
                    children: [
                      Text(
                        comment.authorName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                            Text(
                        _formatDate(comment.createdAt),
                              style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                  const SizedBox(height: 4),
                Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
                    child: Text(
                      comment.content,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                  children: [
                      TextButton.icon(
                        onPressed: () => _setReplyingTo(comment),
                        icon: const Icon(Icons.reply, size: 14),
                        label:
                            const Text('Reply', style: TextStyle(fontSize: 12)),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 0),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                            ),
                          ],
                        ),
                      ),
          ],
        ),
        // Display replies for this comment
        StreamBuilder<List<Comment>>(
          key: ValueKey(
              '${comment.id}_$_forceRefresh'), // Add key to force rebuild
          stream: _communityService.getRepliesWithLimit(comment.id, limit: 5),
          builder: (context, snapshot) {
            // Get replies from stream or local cache
            List<Comment> replies = [];
            if (snapshot.hasData) {
              replies = snapshot.data!;
              // Update local cache
              _localReplies[comment.id] = replies;
            } else if (_localReplies.containsKey(comment.id) &&
                _localReplies[comment.id]!.isNotEmpty) {
              // Use cached replies if stream has error or is loading
              replies = _localReplies[comment.id]!;
            }

            if (snapshot.connectionState == ConnectionState.waiting &&
                replies.isEmpty) {
              // Show shimmer loading effect when loading and no cached data
              return Padding(
                padding: const EdgeInsets.only(left: 40, top: 8),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 40,
                    color: Colors.white,
                  ),
                ),
              );
            }

            if (snapshot.hasError && replies.isEmpty) {
              // Show subtle 'indexing' message for FAILED_PRECONDITION errors
              if (snapshot.error.toString().contains('FAILED_PRECONDITION') ||
                  snapshot.error.toString().contains('requires an index')) {
                return const Padding(
                  padding: EdgeInsets.only(left: 40, top: 4),
                  child: Text(
                    'Replies will appear here soon.',
                              style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }

            if (replies.isEmpty) {
              return const SizedBox.shrink();
            }

            // Display the replies
            return Padding(
              padding: const EdgeInsets.only(left: 40, top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: replies.map((reply) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundImage:
                                reply.authorImageUrl.startsWith('asset/')
                                    ? AssetImage(reply.authorImageUrl)
                                    : NetworkImage(reply.authorImageUrl)
                                        as ImageProvider,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                                Row(
                                  children: [
                                    Text(
                                      reply.authorName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                            Text(
                                      _formatDate(reply.createdAt),
                              style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey[600],
                                      ),
                            ),
                          ],
                        ),
                                const SizedBox(height: 2),
                                Text(
                                  reply.content,
                                  style: const TextStyle(fontSize: 13),
                                ),
                                const SizedBox(height: 2),
                                TextButton.icon(
                                  onPressed: () => _setReplyingTo(
                                      comment), // Reply to the parent comment
                                  icon: const Icon(Icons.reply, size: 12),
                                  label: const Text('Reply',
                                      style: TextStyle(fontSize: 10)),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 0),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
                          ),
                        ],
                      ),
                      if (replies.last != reply)
                        const Divider(height: 16, thickness: 0.5),
                    ],
                  );
                }).toList(),
              ),
            );
          },
        ),
        const Divider(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discussion'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          // Discussion details
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Author info
                    Row(
                  children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: widget.discussion.authorImageUrl
                                  .startsWith('asset/')
                              ? AssetImage(widget.discussion.authorImageUrl)
                              : NetworkImage(widget.discussion.authorImageUrl)
                                  as ImageProvider,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.discussion.authorName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              _formatDate(widget.discussion.createdAt),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Discussion title
                    Text(
                      widget.discussion.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Poppins",
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Discussion content
                    Text(
                      widget.discussion.content,
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: "Poppins",
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Divider(thickness: 1),

                    // Comments section
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Text(
                            "Comments",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Poppins",
                            ),
                          ),
                          const SizedBox(width: 8),
                    Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "(${widget.discussion.commentCount})",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                      ),
                    ),
                  ],
                ),
                    ),

                    // List of comments
                    StreamBuilder<List<Comment>>(
                      key:
                          ValueKey(_forceRefresh), // Add a key to force rebuild
                      stream: _communityService.getCommentsWithLimit(
                          widget.discussion.id,
                          limit: 20),
                      builder: (context, snapshot) {
                        // Get comments either from snapshot or from our local state
                        List<Comment> comments = [];

                        if (snapshot.hasData) {
                          comments = snapshot.data!;
                          // Update our local state
                          _localComments = comments;
                        } else if (_localComments.isNotEmpty) {
                          // Use local comments if stream has an error but we have local data
                          comments = _localComments;
                        }

                        if (snapshot.connectionState ==
                                ConnectionState.waiting &&
                            comments.isEmpty) {
                          // Show shimmer loading effect
                          return Column(
                            children: List.generate(
                              3, // Show 3 shimmer placeholders
                              (index) => _buildCommentShimmer(),
                            ),
                          );
                        }

                        if (snapshot.hasError && comments.isEmpty) {
                          // Check if the error is about missing index
                          final errorMsg = snapshot.error.toString();
                          if (errorMsg.contains('FAILED_PRECONDITION') ||
                              errorMsg.contains('requires an index')) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16.0),
                              child: Column(
                  children: [
                                  Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Setting up database indexes...',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const Text(
                                    'This happens only once. Please wait a moment or try again later.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                            Text(
                                    'Your comment has been saved and will appear soon.',
                                    textAlign: TextAlign.center,
                              style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[700],
                                    ),
                            ),
                          ],
                        ),
                            );
                          }

                          // For other errors
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: Text(
                              'Error loading comments: ${snapshot.error}',
                              style: const TextStyle(color: Colors.red),
                            ),
                          );
                        }

                        if (comments.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Text(
                              'No comments yet. Be the first to comment!',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        }

                        // Filter to only show top-level comments
                        final topLevelComments = comments
                            .where((c) => c.parentCommentId == null)
                            .toList();

                        return Column(
                          children: topLevelComments
                              .map((comment) => _buildCommentItem(comment))
                              .toList(),
                        );
                      },
                            ),
                          ],
                        ),
                      ),
                    ),
                ),

          // Comment input field
                Container(
                  decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 1,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
                  children: [
                if (_replyingToCommentId != null)
                    Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                      ),
                        child: Row(
                      mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                          'Replying to $_replyingToUsername',
                          style: const TextStyle(fontSize: 12),
                        ),
                        IconButton(
                          onPressed: _cancelReply,
                          icon: const Icon(Icons.close, size: 14),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                Row(
                          children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          hintText: _replyingToCommentId != null
                              ? 'Write a reply...'
                              : 'Write a comment...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        maxLines: 3,
                        minLines: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _isSubmitting ? null : _submitComment,
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                      height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send),
                      color: Colors.green,
                    ),
                  ],
                    ),
                  ],
                ),
          ),
        ],
      ),
    );
  }
}
