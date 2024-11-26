import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class ResponsesScreen extends StatefulWidget {
  const ResponsesScreen({super.key});

  @override
  State<ResponsesScreen> createState() => _ResponsesScreenState();
}

class _ResponsesScreenState extends State<ResponsesScreen> {
  String selectedFeedbackType = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Responses'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: 600,
              color: Colors.white, // Set the background color to white
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('feedbacks').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    if (!snapshot.hasData || snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }

                    final feedbacks = snapshot.data!.docs;

                    final feedbackCounts = {
                      'All': feedbacks.length.toString(),
                      'Complaints': feedbacks.where((feedbackDoc) => (feedbackDoc.data() as Map<String, dynamic>)['feedback_type'] == 'Complaints').length.toString(),
                      'Suggestions': feedbacks.where((feedbackDoc) => (feedbackDoc.data() as Map<String, dynamic>)['feedback_type'] == 'Suggestions').length.toString(),
                      'Appreciations': feedbacks.where((feedbackDoc) => (feedbackDoc.data() as Map<String, dynamic>)['feedback_type'] == 'Appreciations').length.toString(),
                      'Requests': feedbacks.where((feedbackDoc) => (feedbackDoc.data() as Map<String, dynamic>)['feedback_type'] == 'Requests').length.toString(),
                      'Comments': feedbacks.where((feedbackDoc) => (feedbackDoc.data() as Map<String, dynamic>)['feedback_type'] == 'Comments').length.toString(),
                    };

                    return DropdownButton<String>(
                      dropdownColor: Colors.white,
                      value: selectedFeedbackType,
                      onChanged: (newValue) {
                        setState(() {
                          selectedFeedbackType = newValue!;
                        });
                      },
                      items: feedbackCounts.keys.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text('$value (${feedbackCounts[value]})'),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: FeedbackList(selectedFeedbackType: selectedFeedbackType),
          ),
        ],
      ),
    );
  }
}

class FeedbackList extends StatelessWidget {
  final String selectedFeedbackType;

  const FeedbackList({super.key, required this.selectedFeedbackType});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('feedbacks')
          .orderBy('timestamp', descending: true) // Sort by timestamp in descending order
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        final feedbacks = snapshot.data!.docs;

        final filteredFeedbacks = selectedFeedbackType == 'All'
            ? feedbacks
            : feedbacks.where((feedbackDoc) =>
        (feedbackDoc.data() as Map<String, dynamic>)['feedback_type'] ==
            selectedFeedbackType);

        if (filteredFeedbacks.isEmpty) {
          return const Center(child: Text('No feedbacks available.'));
        }

        return ListView.builder(
          itemCount: filteredFeedbacks.length,
          itemBuilder: (context, index) {
            final feedbackDoc = filteredFeedbacks.elementAt(index);
            final feedbackData = feedbackDoc.data() as Map<String, dynamic>;

            final bool isCompleted = feedbackData['completed'] ?? false;
            final String notes = feedbackData['notes'] ?? '';

            return Card(
              color: isCompleted ? Colors.yellow.shade300 : Colors.white,
              shadowColor: Colors.grey,
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ListTile(
                title: Text(feedbackData['name']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(feedbackData['feedback']),
                    Text(
                      'Feedback Type: ${feedbackData['feedback_type']}',
                      style: const TextStyle(color: CupertinoColors.destructiveRed),
                    ),
                    Text(
                      'Date: ${feedbackData['timestamp'].toDate().toString().substring(0, 16)}',
                      style: const TextStyle(color: CupertinoColors.activeGreen),
                    ),
                    if (notes.isNotEmpty)
                      Text(
                        'Notes: $notes',
                        style: const TextStyle(color: CupertinoColors.activeBlue, fontSize: 14),
                      ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        feedbackDoc.reference.update({'completed': !isCompleted});
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          isCompleted ? Icons.check_circle : Icons.check_circle_outline,
                          color: isCompleted ? Colors.green : Colors.grey,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      color: Colors.red,
                      onPressed: () {
                        feedbackDoc.reference.delete();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.note),
                      color: notes.isEmpty ? Colors.grey : Colors.blue,
                      onPressed: () async {
                        final String? newNotes = await showDialog<String>(
                          context: context,
                          builder: (context) {
                            String enteredNotes = notes;
                            return AlertDialog(
                              title: const Text('Add Notes'),
                              content: TextField(
                                onChanged: (value) {
                                  enteredNotes = value;
                                },
                                decoration: const InputDecoration(hintText: 'Enter notes here'),
                              ),
                              backgroundColor: Colors.white,
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context, enteredNotes);
                                  },
                                  child: const Text('Save'),
                                ),
                              ],
                            );
                          },
                        );

                        if (newNotes != null) {
                          feedbackDoc.reference.update({'notes': newNotes});
                        }
                      },
                    ),
                  ],
                ),
                onTap: () {
                  // Handle feedback item tap, if needed
                },
              ),
            );
          },
        );
      },
    );
  }
}
