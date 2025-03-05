// lib/screens/evaluations/evaluation_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../config/routes.dart';
import '../../providers/workspace_provider.dart';
import '../../providers/experiment_provider.dart';
import '../../widgets/sidebar_menu.dart';
import '../../models/evaluation.dart';

class EvaluationListScreen extends StatefulWidget {
  final String? workspaceId;
  final String? experimentId;
  
  const EvaluationListScreen({
    Key? key, 
    this.workspaceId, 
    this.experimentId,
  }) : super(key: key);

  @override
  State<EvaluationListScreen> createState() => _EvaluationListScreenState();
}

class _EvaluationListScreenState extends State<EvaluationListScreen> {
  String _selectedTestSet = 'All Test Sets';
  
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
    
    // 해당 실험의 평가 목록 가져오기
    final allEvaluations = experimentProvider.getEvaluationsForExperiment(experiment.id);
    
    // 모의 데이터 - 실제로는 evaluations에서 추출
    final List<Map<String, dynamic>> mockExperimentData = [
      {
        'name': 'Experiment 11',
        'dataset': 'my-gcp-dataset-sales_table',
        'testSet': 'Default Test Set2',
        'trainingSet': 'Default Training Set',
        'accuracy': 85.0,
        'id': 'exp11'
      },
      {
        'name': 'Experiment 12',
        'dataset': 'demo-project-sales_data',
        'testSet': 'Default Test Set',
        'trainingSet': 'Default Training Set',
        'accuracy': 92.0,
        'id': 'exp12'
      },
    ];
    
    // 테스트 세트 목록 생성 (중복 제거 + 'All Test Sets' 옵션 추가)
    final Set<String> uniqueTestSets = {};
    for (var exp in mockExperimentData) {
      uniqueTestSets.add(exp['testSet'] as String);
    }
    final testSets = ['All Test Sets', ...uniqueTestSets.toList()];
    
    // 선택된 테스트 세트로 데이터 필터링
    final filteredExperiments = _selectedTestSet == 'All Test Sets'
        ? mockExperimentData
        : mockExperimentData.where((exp) => exp['testSet'] == _selectedTestSet).toList();
    
    // 선택된 테스트 세트로 평가 필터링
    final List<Evaluation> filteredEvaluations = _selectedTestSet == 'All Test Sets'
        ? allEvaluations
        : allEvaluations.where((eval) {
            // 실제로는 평가에 테스트 세트 정보가 있어야 함
            return true; // 모의 구현 - 실제로는 평가의 테스트 세트를 체크
          }).toList();
    
    // 그래프용 데이터 생성
    final spots = filteredExperiments.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value['accuracy']);
    }).toList();

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
                    'Evaluations',
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
                            // 테스트 세트 필터
                            Row(
                              children: [
                                const Text(
                                  'Filter by Test Set',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                DropdownButton<String>(
                                  value: _selectedTestSet,
                                  items: testSets.map((testSet) => 
                                    DropdownMenuItem(
                                      value: testSet,
                                      child: Text(testSet),
                                    )
                                  ).toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        _selectedTestSet = value;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // 평가 데이터 테이블
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Table(
                                columnWidths: const {
                                  0: FlexColumnWidth(3),
                                  1: FlexColumnWidth(3),
                                  2: FlexColumnWidth(2),
                                  3: FlexColumnWidth(3),
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
                                          'Experiment Name',
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          'Dataset',
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          'Test Set',
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          'Training Set',
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                  // 데이터 행 - 필터링된 실험 데이터로 채움
                                  ...filteredExperiments.map((exp) => TableRow(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(exp['name']),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(exp['dataset']),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(exp['testSet']),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(exp['trainingSet']),
                                      ),
                                    ],
                                  )).toList(),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            
                            // 정확도 비교 섹션
                            Text(
                              'Accuracy Comparison for ${_selectedTestSet == "All Test Sets" ? "All Test Sets" : "Test Set: $_selectedTestSet"}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // 정확도 트렌드 차트
                            Container(
                              height: 250,
                              width: double.infinity,
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Accuracy Trend',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Expanded(
                                    child: LineChart(
                                      LineChartData(
                                        gridData: FlGridData(show: true),
                                        titlesData: FlTitlesData(
                                          bottomTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              getTitlesWidget: (value, meta) {
                                                final index = value.toInt();
                                                if (index >= 0 && index < filteredExperiments.length) {
                                                  return Padding(
                                                    padding: const EdgeInsets.only(top: 8),
                                                    child: Text(
                                                      filteredExperiments[index]['name'].toString().replaceAll('Experiment ', 'Exp '),
                                                      style: const TextStyle(fontSize: 10),
                                                    ),
                                                  );
                                                }
                                                return const Text('');
                                              },
                                              reservedSize: 40,
                                            ),
                                          ),
                                          leftTitles: AxisTitles(
                                            axisNameWidget: const Text('Accuracy %'),
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              reservedSize: 40,
                                              getTitlesWidget: (value, meta) {
                                                return Text('${value.toInt()}');
                                              },
                                            ),
                                          ),
                                          topTitles: AxisTitles(
                                            sideTitles: SideTitles(showTitles: false),
                                          ),
                                          rightTitles: AxisTitles(
                                            sideTitles: SideTitles(showTitles: false),
                                          ),
                                        ),
                                        minY: 0,
                                        maxY: 100,
                                        lineBarsData: [
                                          LineChartBarData(
                                            spots: spots,
                                            isCurved: false,
                                            color: Colors.blue,
                                            barWidth: 3,
                                            isStrokeCapRound: true,
                                            dotData: FlDotData(show: true),
                                            belowBarData: BarAreaData(
                                              show: true,
                                              color: Colors.blue.withOpacity(0.1),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            
                            // 평가 섹션 헤더
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Evaluations',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (_selectedTestSet != 'All Test Sets')
                                  Text(
                                    'Filtered by: $_selectedTestSet',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // 사용자가 생성한 평가 결과 목록
                            // 해당 테스트 세트로 필터링된 평가만 표시
                            filteredEvaluations.isEmpty && allEvaluations.isEmpty
                                ? Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.grey[300]!),
                                    ),
                                    alignment: Alignment.center,
                                    child: Column(
                                      children: [
                                        Icon(Icons.analytics_outlined, size: 48, color: Colors.grey[400]),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'No evaluations found',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          'Run an evaluation from the Materials page to see results here.',
                                          style: TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Column(
                                    children: [
                                      // 평가 1 (샘플 데이터)
                                      _buildEvaluationItem(
                                        title: 'Evaluation 1',
                                        accuracy: 85.0,
                                        createdAt: DateTime.now().subtract(const Duration(days: 2)),
                                        isHighlighted: false,
                                        onTap: () {
                                          Navigator.pushNamed(
                                            context, 
                                            AppRoutes.evaluationDetail,
                                            arguments: {
                                              'workspaceId': workspace.id,
                                              'experimentId': experiment.id,
                                              'evaluationId': 'eval1',
                                            },
                                          );
                                        },
                                      ),
                                      
                                      // 평가 2 (샘플 데이터)
                                      _buildEvaluationItem(
                                        title: 'Evaluation 2',
                                        accuracy: 92.0,
                                        createdAt: DateTime.now().subtract(const Duration(days: 1)),
                                        isHighlighted: false,
                                        onTap: () {
                                          Navigator.pushNamed(
                                            context, 
                                            AppRoutes.evaluationDetail,
                                            arguments: {
                                              'workspaceId': workspace.id,
                                              'experimentId': experiment.id,
                                              'evaluationId': 'eval2',
                                            },
                                          );
                                        },
                                      ),
                                      
                                      // 사용자가 생성한 평가 결과 표시
                                      ...filteredEvaluations.map((eval) => 
                                        _buildEvaluationItem(
                                          title: 'Evaluation ${eval.id.replaceAll(RegExp(r'[^0-9]'), '')}',
                                          accuracy: eval.accuracy,
                                          createdAt: eval.createdAt,
                                          isHighlighted: true,
                                          onTap: () {
                                            Navigator.pushNamed(
                                              context, 
                                              AppRoutes.evaluationDetail,
                                              arguments: {
                                                'workspaceId': workspace.id,
                                                'experimentId': experiment.id,
                                                'evaluationId': eval.id,
                                              },
                                            );
                                          },
                                        ),
                                      ).toList(),
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
  
  // 평가 항목 위젯
  Widget _buildEvaluationItem({
    required String title,
    required double accuracy,
    required DateTime createdAt,
    required bool isHighlighted,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isHighlighted ? Colors.blue.withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isHighlighted ? Colors.blue.shade300 : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: accuracy >= 90 ? Colors.green : 
                         accuracy >= 70 ? Colors.orange : Colors.red,
                ),
                const SizedBox(width: 4),
                Text(
                  'Accuracy: ${accuracy.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 14,
                    color: accuracy >= 90 ? Colors.green : 
                           accuracy >= 70 ? Colors.orange : Colors.red,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  'Created: ${createdAt.toString().substring(0, 16)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}