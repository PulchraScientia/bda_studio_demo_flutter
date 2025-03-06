// lib/screens/assistants/assistant_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/routes.dart';
import '../../providers/workspace_provider.dart';
import '../../providers/experiment_provider.dart';
import '../../widgets/sidebar_menu.dart';
import '../../models/assistant.dart';
import '../../models/evaluation.dart';

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

    // 평가 정보 가져오기 함수
    Evaluation? getEvaluationForAssistant(Assistant assistant) {
      try {
        return experimentProvider.evaluations.firstWhere(
          (eval) => eval.id == assistant.evaluationId,
        );
      } catch (e) {
        return null; // 이제 메소드 반환 타입을 Evaluation?로 변경했으므로 null 반환 가능
      }
    }
    
    // 평가 정보 생성 시간 기반 날짜 문자열
    String getFormattedDate(DateTime date) {
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
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
                                final evaluation = getEvaluationForAssistant(assistant);
                                
                                // 테스트 세트 및 훈련 세트 이름 생성
                                final createdDate = assistant.createdAt;
                                final testSetName = evaluation != null 
                                    ? 'TestSet-${getFormattedDate(evaluation.createdAt)}-v${(evaluation.id.hashCode % 3) + 1}'
                                    : 'TestSet-${getFormattedDate(createdDate)}-v1';
                                final trainSetName = evaluation != null
                                    ? 'TrainSet-${getFormattedDate(evaluation.createdAt)}-v${(evaluation.id.hashCode % 2) + 1}'
                                    : 'TrainSet-${getFormattedDate(createdDate)}-v1';
                                    
                                // 지식 데이터 정보
                                final knowledgeInfo = evaluation != null && evaluation.id.contains('eval1')
                                    ? '15 schema items, 10 examples'
                                    : '20 schema items, 12 examples';
                                    
                                // 정확도 정보
                                final accuracy = evaluation?.accuracy ?? 85.0;
                                
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // 어시스턴트 이름 및 배지
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              assistant.name,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.green.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(color: Colors.green.shade300),
                                              ),
                                              child: Text(
                                                'Accuracy: ${accuracy.toStringAsFixed(1)}%',
                                                style: const TextStyle(
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
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
                                            Text('v${assistant.version}'),
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
                                            Text(experiment.dataset.name),
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
                                          // 기본 정보 섹션
                                          Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade50,
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: Colors.grey.shade200),
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'Evaluation Details',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 12),
                                                
                                                // 메타데이터 표시
                                                Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    // 데이터셋
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          const Text(
                                                            'Dataset:',
                                                            style: TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                          Text(experiment.dataset.name),
                                                        ],
                                                      ),
                                                    ),
                                                    // 지식 데이터
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          const Text(
                                                            'Knowledge Data:',
                                                            style: TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                          Text(knowledgeInfo),
                                                        ],
                                                      ),
                                                    ),
                                                    // 상태
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: const [
                                                          Text(
                                                            'Status:',
                                                            style: TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                          Text('completed'),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 12),
                                                
                                                Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    // 훈련 세트
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          const Text(
                                                            'Train Set:',
                                                            style: TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                          Text(trainSetName),
                                                        ],
                                                      ),
                                                    ),
                                                    // 테스트 세트
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          const Text(
                                                            'Test Set:',
                                                            style: TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                          Text(testSetName),
                                                        ],
                                                      ),
                                                    ),
                                                    // 생성 시간
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          const Text(
                                                            'Created:',
                                                            style: TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                          Text(
                                                            evaluation?.createdAt.toString().substring(0, 16) ?? 
                                                            getFormattedDate(assistant.createdAt),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 16),
                                                
                                                // 결과 요약
                                                const Text(
                                                  'Results Summary',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 12),
                                                
                                                // 결과 통계
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          const Text(
                                                            'Accuracy',
                                                            style: TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                          Text('${accuracy.toStringAsFixed(1)}%'),
                                                        ],
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          const Text(
                                                            'Correct Queries',
                                                            style: TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                          Text(accuracy >= 85 ? '1/1' : '0/1'),
                                                        ],
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          const Text(
                                                            'Error Rate',
                                                            style: TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                          Text('${(100 - accuracy).toStringAsFixed(1)}%'),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          
                                          const SizedBox(height: 16),
                                          
                                          // 학습 데이터 정보
                                          const Text(
                                            'Training Information',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          
                                          // 데이터셋 항목
                                          _buildDatasetItem('Training examples: 7 natural language to SQL pairs'),
                                          _buildDatasetItem('Test examples: 3 natural language to SQL pairs'),
                                          _buildDatasetItem(knowledgeInfo),
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