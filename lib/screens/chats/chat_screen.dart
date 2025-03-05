// lib/screens/chats/chat_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/routes.dart';
import '../../providers/workspace_provider.dart';
import '../../providers/experiment_provider.dart';
import '../../widgets/sidebar_menu.dart';
import '../../models/chat.dart';
import '../../models/assistant.dart';  // Assistant 클래스 import 추가

class ChatScreen extends StatefulWidget {
  final String? workspaceId;
  final String? experimentId;
  final String? assistantId;
  
  const ChatScreen({
    Key? key, 
    this.workspaceId, 
    this.experimentId,
    this.assistantId,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _selectedAssistant = "Assistant name _v?";
  String _selectedChatRoom = "Chat room 1";
  
  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  // 채팅방 스크롤을 맨 아래로 이동
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final workspaceProvider = Provider.of<WorkspaceProvider>(context);
    final experimentProvider = Provider.of<ExperimentProvider>(context);
    
    // 현재 워크스페이스 정보 가져오기
    final workspace = workspaceProvider.selectedWorkspace ?? 
        workspaceProvider.workspaces.firstWhere((ws) => ws.id == widget.workspaceId);
    
    // 현재 실험 정보 가져오기
    final experiment = experimentProvider.selectedExperiment ?? 
        experimentProvider.experiments.firstWhere((exp) => exp.id == widget.experimentId);
    
    // 현재 어시스턴트 정보 가져오기
    final assistant = widget.assistantId != null
        ? experimentProvider.assistants.firstWhere(
            (a) => a.id == widget.assistantId,
            orElse: () => experimentProvider.assistants.isNotEmpty
                ? experimentProvider.assistants.first
                : Assistant(
                    id: 'default',
                    name: 'Default Assistant',
                    experimentId: experiment.id,
                    evaluationId: '',
                    version: 1,
                    createdAt: DateTime.now(),
                  ),
          )
        : experimentProvider.assistants.first;
    
    // 해당 어시스턴트의 채팅 목록 가져오기
    final chats = experimentProvider.getChatsForAssistant(assistant.id);
    
    // 현재 채팅 가져오기
    late Chat currentChat;
    List<ChatMessage> currentMessages = [];
    
    if (chats.isNotEmpty) {
      currentChat = chats.firstWhere(
        (c) => c.name == _selectedChatRoom,
        orElse: () => chats.first,
      );
      
      currentMessages = currentChat.messages;
      
      // 선택된 채팅방 이름 업데이트
      if (_selectedChatRoom != currentChat.name) {
        _selectedChatRoom = currentChat.name;
      }
    }

    return Scaffold(
      body: Row(
        children: [
          // 사이드바 메뉴
          const SidebarMenu(),
          
          // 메인 콘텐츠
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 헤더
                  const Text(
                    'Chats',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // 메인 컨텐츠
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          // 왼쪽 사이드 패널 (어시스턴트 선택 및 채팅방 목록)
                          Container(
                            width: 300,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              border: Border(
                                right: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 어시스턴트 선택
                                const Text(
                                  'Select OpenAI model',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade400),
                                    borderRadius: BorderRadius.circular(4),
                                    color: Colors.white,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  child: Text(assistant.name),
                                ),
                                const SizedBox(height: 16),
                                
                                // 채팅 초기화 버튼
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: Colors.grey.shade400),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: TextButton(
                                    onPressed: () {
                                      // 채팅 초기화 액션
                                      _showNewChatDialog(context, assistant.id, experiment.id);
                                    },
                                    child: const Text('New Chat'),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                
                                // 채팅방 목록
                                Expanded(
                                  child: chats.isEmpty
                                      ? const Center(
                                          child: Text(
                                            'No chats found. Start a new conversation.',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                        )
                                      : ListView.builder(
                                          itemCount: chats.length,
                                          itemBuilder: (context, index) {
                                            final chat = chats[index];
                                            return _buildChatRoomItem(
                                              chat.name,
                                              onTap: () {
                                                setState(() {
                                                  _selectedChatRoom = chat.name;
                                                });
                                                // 채팅 내용이 변경되면 스크롤을 아래로 이동
                                                _scrollToBottom();
                                              }
                                            );
                                          },
                                        ),
                                ),
                              ],
                            ),
                          ),
                          
                          // 오른쪽 채팅 영역
                          Expanded(
                            child: Column(
                              children: [
                                // 채팅 메시지 영역
                                Expanded(
                                  child: currentMessages.isEmpty
                                      ? const Center(
                                          child: Text(
                                            'No messages yet. Start a conversation!',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 16,
                                            ),
                                          ),
                                        )
                                      : Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: ListView.builder(
                                            controller: _scrollController,
                                            itemCount: currentMessages.length,
                                            itemBuilder: (context, index) {
                                              final message = currentMessages[index];
                                              return _buildMessageItem(message);
                                            },
                                          ),
                                        ),
                                ),
                                
                                // 메시지 입력 영역
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      top: BorderSide(color: Colors.grey.shade300),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _messageController,
                                          decoration: InputDecoration(
                                            hintText: 'What is up?',
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(24),
                                            ),
                                            contentPadding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 12,
                                            ),
                                          ),
                                          onSubmitted: (value) {
                                            if (chats.isNotEmpty) {
                                              _sendMessage(context, experimentProvider, assistant.id);
                                            } else {
                                              _showNewChatDialog(context, assistant.id, experiment.id);
                                            }
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        onPressed: () {
                                          if (chats.isNotEmpty) {
                                            _sendMessage(context, experimentProvider, assistant.id);
                                          } else {
                                            _showNewChatDialog(context, assistant.id, experiment.id);
                                          }
                                        },
                                        icon: const Icon(Icons.send),
                                        color: Colors.blue,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // 새 채팅방 생성 다이얼로그
  void _showNewChatDialog(BuildContext context, String assistantId, String experimentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Chat'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Enter your first message',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_messageController.text.trim().isNotEmpty) {
                final experimentProvider = Provider.of<ExperimentProvider>(context, listen: false);
                experimentProvider.createChat(
                  assistantId,
                  experimentId,
                  _messageController.text.trim(),
                );
                Navigator.pop(context);
                setState(() {
                  _selectedChatRoom = "Chat ${experimentProvider.chats.length}";
                });
                _messageController.clear();
                _scrollToBottom();
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
  
  // 채팅방 아이템 위젯
  Widget _buildChatRoomItem(String name, {required VoidCallback onTap}) {
    final isSelected = name == _selectedChatRoom;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? Colors.blue : Colors.grey.shade400,
        ),
        borderRadius: BorderRadius.circular(4),
        color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.white,
      ),
      child: ListTile(
        title: Text(
          name,
          style: TextStyle(
            color: isSelected ? Colors.blue : Colors.black,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
  
  // 메시지 아이템 위젯
  Widget _buildMessageItem(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              backgroundColor: Colors.blue.shade200,
              child: const Icon(Icons.smart_toy, color: Colors.white),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isUser ? Colors.blue.shade100 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.isUser ? 'You' : 'Assistant',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(message.content),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.blue.shade500,
              child: const Icon(Icons.person, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }
  
  // 메시지 전송
  void _sendMessage(
    BuildContext context,
    ExperimentProvider experimentProvider,
    String assistantId,
  ) {
    if (_messageController.text.trim().isEmpty) return;
    
    final content = _messageController.text.trim();
    _messageController.clear();
    
    // 채팅 존재 여부 확인
    final chats = experimentProvider.getChatsForAssistant(assistantId);
    
    if (chats.isEmpty || !chats.any((c) => c.name == _selectedChatRoom)) {
      // 새 채팅 생성
      experimentProvider.createChat(
        assistantId,
        experimentProvider.selectedExperiment!.id,
        content,
      );
      setState(() {
        _selectedChatRoom = "Chat ${experimentProvider.chats.length}";
      });
    } else {
      // 메시지 전송
      final chat = chats.firstWhere((c) => c.name == _selectedChatRoom);
      experimentProvider.sendMessage(chat.id, content);
    }
    
    // 채팅방 스크롤을 맨 아래로 이동
    _scrollToBottom();
  }
}