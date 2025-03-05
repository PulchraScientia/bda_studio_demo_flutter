// lib/screens/assistants/assistant_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/routes.dart';
import '../../providers/workspace_provider.dart';
import '../../providers/experiment_provider.dart';
import '../../widgets/sidebar_menu.dart';

class AssistantListScreen extends StatefulWidget {
  final String? workspaceId;
  final String? experimentId;
  
  const AssistantListScreen({
    Key? key, 
    this.workspaceId, 
    this.experimentId,
  }) : super(key: key);

  @override
  State<AssistantListScreen> createState() => _AssistantListScreenState();
}

class _AssistantListScreenState extends State<AssistantListScreen> {
  // 선택된 버전
  String _selectedVersion = 'v1';
  // 상세 정보 표시 여부
  bool _showDetails = false;
  
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
    
    // 해당 실험의 어시스턴트 목록 가져오기
    final assistants = experimentProvider.getAssistantsForExperiment(experiment.id);

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
                    'Assistants',
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
                      padding: const EdgeInsets.all(20),
                      child: assistants.isEmpty
                          ? const Center(
                              child: Text(
                                'No assistants found. Deploy an evaluation as an assistant first.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: assistants.length,
                              itemBuilder: (context, index) {
                                final assistant = assistants[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // 어시스턴트 이름
                                        Text(
                                          index == 0 ? 'Sales Data Assistant' : 'Assistant from Experiment-12',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        
                                        // 버전 정보
                                        Row(
                                          children: [
                                            const Text(
                                              'Version:',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text('${assistant.version}'),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        
                                        // 생성 시간
                                        Row(
                                          children: [
                                            const Text(
                                              'Created:',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              assistant.createdAt.toString().substring(0, 16),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        
                                        // 데이터셋 정보
                                        Row(
                                          children: [
                                            const Text(
                                              'Dataset:',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text('demo-project-sales_data'),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        
                                        // 버전 선택
                                        Row(
                                          children: [
                                            const Text(
                                              'Select version',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            DropdownButton<String>(
                                              value: _selectedVersion,
                                              items: const [
                                                DropdownMenuItem(
                                                  value: 'v1',
                                                  child: Text('v1'),
                                                ),
                                              ],
                                              onChanged: (value) {
                                                if (value != null) {
                                                  setState(() {
                                                    _selectedVersion = value;
                                                  });
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        
                                        // 채팅 시작 버튼
                                        ElevatedButton(
                                          onPressed: () {
                                            _startChat(context, assistant, experiment);
                                          },
                                          child: const Text('Chat with Assistant'),
                                        ),
                                        const SizedBox(height: 16),
                                        
                                        // 상세 정보 토글
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              _showDetails = !_showDetails;
                                            });
                                          },
                                          child: Row(
                                            children: [
                                              Text(
                                                'Show Details',
                                                style: TextStyle(
                                                  color: Colors.blue,
                                                  fontWeight: _showDetails ? FontWeight.bold : FontWeight.normal,
                                                ),
                                              ),
                                              Icon(
                                                _showDetails ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                                color: Colors.blue,
                                              ),
                                            ],
                                          ),
                                        ),
                                        
                                        // 상세 정보
                                        if (_showDetails) ...[
                                          const SizedBox(height: 16),
                                          const Text(
                                            'Description: Assistant for querying sales data with natural language',
                                            style: TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          const Text(
                                            'Material: Sales Data Material',
                                            style: TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          const Text(
                                            'Training examples: 7',
                                            style: TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          
                                          // 데이터셋 정보
                                          const Text(
                                            'Dataset Information',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          
                                          // 데이터셋 항목
                                          _buildDatasetItem('transactions: Daily sales transactions'),
                                          _buildDatasetItem('products: Product catalog'),
                                          _buildDatasetItem('customers: Customer information'),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              },
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
  
  // 데이터셋 항목 위젯
  Widget _buildDatasetItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(
            Icons.circle,
            size: 8,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
  
  // 채팅 시작
  void _startChat(
    BuildContext context,
    dynamic assistant,
    dynamic experiment,
  ) {
    Navigator.pushNamed(
      context, 
      AppRoutes.chatList,
      arguments: {
        'workspaceId': widget.workspaceId,
        'experimentId': experiment.id,
        'assistantId': assistant.id,
      },
    );
  }
}