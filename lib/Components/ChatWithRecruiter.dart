import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  final String jobId;
  final String applicationId;

  const ChatPage({super.key, required this.jobId, required this.applicationId});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController messageController = TextEditingController();
  late CollectionReference messagesCollection;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    messagesCollection = FirebaseFirestore.instance
        .collection('jobsposted')
        .doc(widget.jobId)
        .collection('applications')
        .doc(widget.applicationId)
        .collection('messages');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'Chat Page',
          style: TextStyle(color: Colors.white),
        ),
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: messagesCollection.orderBy('timestamp').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                List<QueryDocumentSnapshot> messages = snapshot.data!.docs;

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  scrollController
                      .jumpTo(scrollController.position.maxScrollExtent);
                });

                return ListView.builder(
                  controller: scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> messageData =
                        messages[index].data() as Map<String, dynamic>;
                    String messageText = messageData['message'];
                    String sender = messageData['sender'];
                    Timestamp? timestamp = messageData['timestamp'];

                    String formattedTime = 'Timestamp not available';

                    if (timestamp != null) {
                      DateTime dateTime = timestamp.toDate();
                      formattedTime =
                          DateFormat('HH:mm:ss dd-MM-yy').format(dateTime);
                    }

                    bool isUserSender = sender == 'Applicant';
                    if (isUserSender) {
                      sender = 'you ';
                    }
                    return ListTile(
                      title: Row(
                        mainAxisAlignment: isUserSender
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          Text(
                            messageText,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isUserSender
                                  ? const Color.fromARGB(255, 49, 134, 203)
                                  : const Color.fromARGB(255, 199, 210, 40),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Row(
                        mainAxisAlignment: isUserSender
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          if (!isUserSender) const SizedBox(width: 8),
                          Text(
                            sender,
                            style: const TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (!isUserSender) const SizedBox(width: 8),
                          Text(
                            formattedTime,
                            style: const TextStyle(
                              fontSize: 8,
                              color: Color.fromARGB(255, 4, 146, 51),
                            ),
                          ),
                        ],
                      ),
                      contentPadding: isUserSender
                          ? const EdgeInsets.only(left: 80.0, right: 8.0)
                          : const EdgeInsets.only(left: 8.0, right: 80.0),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                    child: TextField(
                  controller: messageController,
                  decoration: const InputDecoration(
                    labelText: 'Message',
                    hintText: 'Type your message here',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    filled: true,
                    fillColor: Color.fromARGB(255, 177, 217, 225),
                  ),
                )),
                IconButton(
                  icon: const Icon(
                    Icons.send,
                    color: Colors.blue,
                  ),
                  onPressed: () {
                    sendMessage(messageController.text);
                    messageController.clear();
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void sendMessage(String messageText) {
    messagesCollection.add({
      'message': messageText,
      'sender': 'Applicant',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
