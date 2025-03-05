// lib/screens/chats/chat_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/routes.dart';
import '../../providers/workspace_provider.dart';
import '../../providers/experiment_provider.dart';
import '../../widgets/sidebar_menu.dart';
import '../../models/chat.dart';

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
    final assistant = experimentProvider.assistants.firstWhere(
      (a) => a.id == widget.assistantId,
      orElse: () => experimentProvider.assistants.first,
    );
    
    // 해당 어시스턴트의 채팅 목록 가져오기
    final chats = experimentProvider.getChatsForAssistant(assistant.id);
    
    // 현재 채팅 가져오기
    ChatMessage? lastMessage;
    if (chats.isNotEmpty) {
      final chat = chats.firstWhere(
        (c) => c.name == _selectedChatRoom,
        orElse: () => chats.first,
      );
      
      if (chat.messages.isNotEmpty) {
        lastMessage = chat.messages.last;
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
                                  child: Text(_selectedAssistant),
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
                                    },
                                    child: const Text('Clear Chat'),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                
                                // 채팅방 목록
                                Expanded(
                                  child: ListView(
                                    children: [
                                      _buildChatRoomItem('Chat room 1'),
                                      _buildChatRoomItem('Chat room 2'),
                                      _buildChatRoomItem('Chat room 3'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // 오른쪽 채팅 영역
                          Expanded(
                            child: Column(
                              children: [
                                // 채팅 안내 영역
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // 배포 버튼
                                      Container(
                                        alignment: Alignment.topRight,
                                        child: TextButton.icon(
                                          onPressed: () {
                                            // 배포 액션
                                          },
                                          icon: const Icon(Icons.cloud_upload),
                                          label: const Text('Deploy'),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      
                                      // 안내 메시지 (한국어)
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('○'),
                                          const SizedBox(width: 8),
                                          const Expanded(
                                            child: Text(
                                              '추가로 선택할 개체는 Shift 키를 누른 상태에서 같이 클릭합니다.',
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('○'),
                                          const SizedBox(width: 8),
                                          const Expanded(
                                            child: Text(
                                              '또는, 마우스를 드래그하여 여러 개체를 선택할 수도 있습니다.',
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      
                                      const Text('3. 개체 그룹화:'),
                                      const SizedBox(height: 8),
                                      
                                      Padding(
                                        padding: const EdgeInsets.only(left: 16.0),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('○'),
                                            const SizedBox(width: 8),
                                            RichText(
                                              text: const TextSpan(
                                                style: TextStyle(color: Colors.black),
                                                children: [
                                                  TextSpan(text: '개체가 모두 선택된 상태에서 상단 메뉴의 '),
                                                  TextSpan(
                                                    text: 'Format (서식)',
                                                    style: TextStyle(color: Colors.green),
                                                  ),
                                                  TextSpan(text: ' 메뉴를 클릭합니다.'),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                      // 나머지 안내 텍스트들...
                                      
                                      const SizedBox(height: 24),
                                      const Text(
                                        '여러 개체를 묶는 단계별 요약:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      
                                      // 요약 단계들...
                                    ],
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
                                            _sendMessage(context, experimentProvider, assistant.id);
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        onPressed: () {
                                          _sendMessage(context, experimentProvider, assistant.id);
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
  
  // 채팅방 아이템 위젯
  Widget _buildChatRoomItem(String name) {
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
        onTap: () {
          setState(() {
            _selectedChatRoom = name;
          });
        },
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
    String chatId;
    
    if (chats.isEmpty || !chats.any((c) => c.name == _selectedChatRoom)) {
      // 새 채팅 생성
      experimentProvider.createChat(
        assistantId,
        experimentProvider.selectedExperiment!.id,
        content,
      );
    } else {
      // 메시지 전송
      final chat = chats.firstWhere((c) => c.name == _selectedChatRoom);
      experimentProvider.sendMessage(chat.id, content);
    }
    
    // 채팅방 스크롤을 맨 아래로 이동
    _scrollToBottom();
  }
}