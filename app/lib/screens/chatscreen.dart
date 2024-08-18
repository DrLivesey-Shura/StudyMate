import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:test/models/message.dart';
import 'package:test/models/user.dart';
import 'package:test/providers/user_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:test/utils/constants.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<User> users = [];
  User? selectedUser;
  List<Message> messages = [];
  late IO.Socket socket;
  final ScrollController _scrollController = ScrollController();
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeSocket();
    _loadUsers();
  }

  void _initializeSocket() {
    final currentUser = Provider.of<UserProvider>(context, listen: false).user;

    socket = IO.io('${Constants.uri}', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();
    socket.on('connect', (_) {
      print('Connected to WebSocket');
      socket.emit('joinRoom', currentUser.id);
    });

    socket.on('receiveMessage', (data) {
      print('Message received: $data');

      final newMessage = Message.fromMap(data);

      if (newMessage.senderId == selectedUser?.id ||
          newMessage.receiverId == selectedUser?.id) {
        setState(() {
          messages.add(newMessage);
        });
        _scrollToBottom();
      }
    });

    socket.on('connect_error', (error) {
      print('Connection Error: $error');
    });
  }

  Future<void> _loadUsers() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final response = await http.get(
      Uri.parse('${Constants.uri}/api/users'),
      headers: {
        'Authorization': 'Bearer ${userProvider.user.token}',
      },
    );

    if (response.statusCode == 200) {
      List usersJson = json.decode(response.body)['users'];
      setState(() {
        users = usersJson.map((user) => User.fromMap(user)).toList();
      });
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<void> _loadMessages(User user) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      final response = await http.get(
        Uri.parse(
            '${Constants.uri}/api/messages/${userProvider.user.id}/${user.id}'),
        headers: {
          'Authorization': 'Bearer ${userProvider.user.token}',
        },
      );

      if (response.statusCode == 200) {
        List messagesJson = json.decode(response.body);
        setState(() {
          messages =
              messagesJson.map((message) => Message.fromMap(message)).toList();
        });
        _scrollToBottom();
      } else {
        throw Exception('Failed to load messages');
      }
    } catch (e) {
      print(e);
    }
  }

  void _sendMessage(String content) {
    final currentUser = Provider.of<UserProvider>(context, listen: false).user;
    if (selectedUser != null && content.trim().isNotEmpty) {
      final newMessage = Message(
        senderId: currentUser.id,
        receiverId: selectedUser!.id,
        content: content,
        timestamp: DateTime.now(),
      );

      socket.emit('sendMessage', newMessage.toMap());
      setState(() {
        messages.add(newMessage);
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(selectedUser == null
            ? 'Select a User'
            : 'Chat with ${selectedUser!.name}'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child:
                selectedUser == null ? _buildUserList() : _buildMessageList(),
          ),
          if (selectedUser != null) _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildUserList() {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: ListTile(
            leading: users[index].avatar.url.endsWith('.svg')
                ? SvgPicture.network(users[index].avatar.url,
                    width: 40, height: 40)
                : CircleAvatar(
                    backgroundImage: NetworkImage(users[index].avatar.url),
                  ),
            title: Text(users[index].name),
            onTap: () {
              setState(() {
                selectedUser = users[index];
              });
              _loadMessages(users[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildMessageList() {
    final currentUser = Provider.of<UserProvider>(context, listen: false);

    return ListView.builder(
      controller: _scrollController,
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isSentByMe = message.senderId == currentUser.user.id;
        final user = isSentByMe ? currentUser.user : selectedUser;

        return Align(
          alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (!isSentByMe)
                  user!.avatar.url.endsWith('.svg')
                      ? SvgPicture.network(user.avatar.url,
                          width: 40, height: 40)
                      : CircleAvatar(
                          backgroundImage: NetworkImage(user.avatar.url),
                        ),
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSentByMe ? Colors.blue : Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    message.content,
                    style: TextStyle(
                      color: isSentByMe ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                if (isSentByMe) SizedBox(width: 8),
                if (isSentByMe)
                  user!.avatar.url.endsWith('.svg')
                      ? SvgPicture.network(user.avatar.url,
                          width: 40, height: 40)
                      : CircleAvatar(
                          backgroundImage: NetworkImage(user.avatar.url),
                        ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(hintText: 'Enter message...'),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              _sendMessage(_controller.text);
              _controller.clear();
            },
          ),
        ],
      ),
    );
  }
}
