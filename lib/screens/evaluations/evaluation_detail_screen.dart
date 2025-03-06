// lib/screens/evaluations/evaluation_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/routes.dart';
import '../../providers/workspace_provider.dart';
import '../../providers/experiment_provider.dart';
import '../../widgets/sidebar_menu.dart';
import '../../models/evaluation.dart';

class EvaluationDetailScreen extends StatefulWidget {
  final String? workspaceId;
  final String? experimentId;
  final String? evaluationId;
  
  const EvaluationDetailScreen({
    Key? key, 
    this.workspaceId, 
    this.experimentId,
    this.evaluationId,
  }) : super(key: key);

  @override
  State<EvaluationDetailScreen> createState() => _EvaluationDetailScreenState();
}

class _EvaluationDetailScreenState extends State<EvaluationDetailScreen> {
  String _selectedQuery = 'all';
  
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
    
    // 해당 평가 정보 가져오기
    final Evaluation? evaluation = widget.evaluationId != null 
        ? experimentProvider.evaluations.firstWhere(
            (eval) => eval.id == widget.evaluationId,
            orElse: () => experimentProvider.evaluations.isNotEmpty 
                ? experimentProvider.evaluations.first 
                : null!,
          )
        : null;
        
    // 평가 정보 생성 시간 기반 날짜 문자열
    String getFormattedDate(DateTime date) {
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
    
    // 테스트 세트 및 훈련 세트 이름 (생성 시간 기반)
    final createdDate = evaluation?.createdAt ?? DateTime.now();
    final testSetName = 'TestSet-${getFormattedDate(createdDate)}-v${(evaluation?.id.hashCode ?? 0) % 3 + 1}';
    final trainSetName = 'TrainSet-${getFormattedDate(createdDate)}-v${(evaluation?.id.hashCode ?? 0) % 2 + 1}';
    
    // 정확도 및 오류율 계산
    final accuracy = evaluation?.accuracy ?? 85.0;
    final errorRate = 100.0 - accuracy;
    
    // 지식 데이터 정보 - null 안전성 수정
    final knowledgeInfo = evaluation != null && evaluation.id.contains('eval1') 
        ? '15 schema items, 10 examples' 
        : '20 schema items, 12 examples';

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
                  // 헤더와 뒤로가기 버튼
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Row(
                          children: [
                            const Icon(Icons.arrow_back),
                            const SizedBox(width: 8),
                            Text(
                              '<< Back to evaluations',
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // 헤더
                  const Text(
                    'Evaluation Details',
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
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 평가 이름 (헤더)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Center(
                                child: Text(
                                  widget.evaluationId != null && widget.evaluationId!.contains('eval')
                                      ? 'Evaluation ${widget.evaluationId!.replaceAll('eval', '')}'
                                      : evaluation != null 
                                          ? 'Evaluation ${evaluation.id.hashCode % 100}'
                                          : 'Evaluation 1',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // 메타데이터 그리드
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
                                        getFormattedDate(DateTime.now()),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            
                            // 결과 요약
                            const Text(
                              'Results Summary',
                              style: TextStyle(
                                fontSize: 18,
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
                                      Text('${errorRate.toStringAsFixed(1)}%'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            
                            // 테스트 결과
                            const Text(
                              'Test Results',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            
                            // 테스트 결과 테이블
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Table(
                                columnWidths: const {
                                  0: FlexColumnWidth(3),
                                  1: FlexColumnWidth(3),
                                  2: FlexColumnWidth(1),
                                },
                                border: TableBorder.all(
                                  color: Colors.grey.shade300,
                                ),
                                children: [
                                  // 헤더 행
                                  TableRow(
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                    ),
                                    children: const [
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          'Natural Language Query',
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          'Generated SQL',
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          'Status',
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                  // 데이터 행
                                  TableRow(
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text('Show customers who bought more than 5 products'),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text('SELECT c.* FROM customers c JOIN orders o ON c.customer_id = o.customer_id GROUP BY c.customer_id HAVING COUNT(*) > 5'),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Icon(
                                          accuracy >= 85 ? Icons.check_circle : Icons.close,
                                          color: accuracy >= 85 ? Colors.green : Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // 쿼리 선택 드롭다운
                            Row(
                              children: [
                                const Text('Select a query to see detailed comparison:'),
                                const SizedBox(width: 16),
                                DropdownButton<String>(
                                  value: _selectedQuery,
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'all',
                                      child: Text('Show customers who bought more than 5 products'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        _selectedQuery = value;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            
                            // 상세 비교
                            const Text(
                              'Detailed Comparison',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            
                            // SQL 비교
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Expected SQL',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          'SELECT c.* FROM customers c JOIN orders o ON c.customer_id = o.customer_id GROUP BY c.customer_id HAVING COUNT(o.order_id) > 5',
                                          style: TextStyle(
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Generated SQL',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          'SELECT c.* FROM customers c JOIN orders o ON c.customer_id = o.customer_id GROUP BY c.customer_id HAVING COUNT(*) > 5',
                                          style: TextStyle(
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // 차이점 알림
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: accuracy >= 85 ? Colors.green.shade100 : Colors.red.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                accuracy >= 85 
                                    ? 'No significant differences found.'
                                    : 'Differences detected: COUNT(*) vs COUNT(o.order_id)',
                                style: TextStyle(
                                  color: accuracy >= 85 ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // SQL 차이점
                            if (accuracy < 85) ...[
                              const Text(
                                'SQL Differences',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Hint: COUNT(*) counts all rows, while COUNT(o.order_id) only counts non-NULL order_id values. In some cases, this could lead to different results.',
                                  style: TextStyle(
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 24),
                            
                            // 액션 버튼
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                // 어시스턴트로 배포 버튼
                                ElevatedButton(
                                  onPressed: () {
                                    _deployAsAssistant(
                                      context,
                                      experimentProvider,
                                      experiment.id,
                                      widget.evaluationId ?? 'eval1',
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                  child: const Text('Deploy as Assistant'),
                                ),
                                const SizedBox(width: 16),
                                
                                // 평가 재시도 버튼 (Material Edit 페이지로 연결)
                                OutlinedButton(
                                  onPressed: () {
                                    // Material 편집 페이지로 이동
                                    Navigator.pushNamed(
                                      context, 
                                      AppRoutes.materialList,
                                      arguments: {
                                        'workspaceId': workspace.id,
                                        'experimentId': experiment.id,
                                      },
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                  ),
                                  child: const Text('Retry Evaluation'),
                                ),
                              ],
                            ),
                          ],
                        ),
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
  
  // 어시스턴트로 배포
  Future<void> _deployAsAssistant(
    BuildContext context,
    ExperimentProvider experimentProvider,
    String experimentId,
    String evaluationId,
  ) async {
    final TextEditingController nameController = TextEditingController();
    
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Deploy as Assistant'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter a name for the assistant:'),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: 'Assistant name',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  await experimentProvider.deployAssistant(
                    experimentId,
                    evaluationId,
                    nameController.text,
                  );
                  
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Assistant deployed successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              },
              child: const Text('Deploy'),
            ),
          ],
        );
      },
    );
  }
}