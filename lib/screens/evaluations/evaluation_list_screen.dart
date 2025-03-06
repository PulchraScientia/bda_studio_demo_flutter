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
  String? _selectedTestSet;
  
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

    // 워크스페이스 ID에 따라 다른 테스트 세트 이름 사용
    bool isWorkspaceA = workspace.id == 'ws1';
    
    // 모의 평가 결과 (워크스페이스 A용, 다른 워크스페이스는 실제 데이터 사용)
    final List<Evaluation> mockEvaluations = isWorkspaceA
        ? [
            Evaluation(
              id: 'eval1', 
              experimentId: 'exp11', 
              materialId: 'mat1', 
              accuracy: 85.0, 
              results: const [], 
              createdAt: DateTime.now().subtract(const Duration(days: 2))
            ),
            Evaluation(
              id: 'eval2', 
              experimentId: 'exp12', 
              materialId: 'mat2', 
              accuracy: 92.0, 
              results: const [], 
              createdAt: DateTime.now().subtract(const Duration(days: 1))
            ),
          ]
        : [];
    
    // 모든 평가 목록 (실제 평가 + 모의 평가)
    final List<Evaluation> combinedEvaluations = [
      ...mockEvaluations,
      ...allEvaluations,
    ];
    
    // 테스트 세트 이름 동적 생성 (평가 생성 시간 기반)
    final Map<String, String> testSetNames = {};
    for (var eval in combinedEvaluations) {
      final dateStr = '${eval.createdAt.year}${eval.createdAt.month.toString().padLeft(2, '0')}${eval.createdAt.day.toString().padLeft(2, '0')}';
      final testSetName = 'TestSet-$dateStr-v${eval.id.hashCode % 3 + 1}';
      testSetNames[eval.id] = testSetName;
    }
    
    // 테스트 세트별 평가 그룹화
    final Map<String, List<Evaluation>> evaluationsByTestSet = {};
    for (var eval in combinedEvaluations) {
      final testSetName = testSetNames[eval.id] ?? 'Unknown';
      if (!evaluationsByTestSet.containsKey(testSetName)) {
        evaluationsByTestSet[testSetName] = [];
      }
      evaluationsByTestSet[testSetName]!.add(eval);
    }
    
    // 테스트 세트 목록 (동적으로 생성)
    final List<String> testSets = evaluationsByTestSet.keys.toList();
    
    // 첫 로드 시 자동 선택
    if (_selectedTestSet == null && testSets.isNotEmpty) {
      _selectedTestSet = testSets[0];
    }
    
    // 선택된 테스트 세트로 평가 필터링
    final List<Evaluation> filteredEvaluations = _selectedTestSet == null
        ? combinedEvaluations
        : evaluationsByTestSet[_selectedTestSet] ?? [];
    
    // 실험 데이터 구성 (평가에서 추출)
    final List<Map<String, dynamic>> experimentData = filteredEvaluations.map((eval) => {
      'name': isWorkspaceA 
          ? (eval.id == 'eval1' ? 'Experiment 11' : 'Experiment 12')
          : experiment.name,
      'dataset': isWorkspaceA 
          ? (eval.id == 'eval1' ? 'my-gcp-dataset-sales_table' : 'demo-project-sales_data')
          : experiment.dataset.name,
      'testSet': testSetNames[eval.id] ?? 'Unknown',
      'accuracy': eval.accuracy,
      'id': eval.id,
    }).toList();
    
    // 그래프용 데이터 생성
    final spots = experimentData.asMap().entries.map((entry) {
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
                            // 테스트 세트 필터 (테스트 세트가 있을 경우만 표시)
                            if (testSets.isNotEmpty) ... [
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
                              const SizedBox(height: 8),
                              
                              // 테스트 세트 설명
                              if (_selectedTestSet != null)
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.info_outline, color: Colors.blue.shade700),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Test Set Information: $_selectedTestSet',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'This test set is a snapshot from ${_selectedTestSet!.split('-')[1].substring(0, 4)}-'
                                        '${_selectedTestSet!.split('-')[1].substring(4, 6)}-'
                                        '${_selectedTestSet!.split('-')[1].substring(6, 8)}. '
                                        'Evaluations using the same test set can be directly compared.',
                                        style: TextStyle(color: Colors.blue.shade700),
                                      ),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 16),
                            ],
                            
                            // 평가 데이터 테이블
                            experimentData.isEmpty
                                ? Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Center(
                                      child: Text('No evaluation data available'),
                                    ),
                                  )
                                : Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Table(
                                      columnWidths: const {
                                        0: FlexColumnWidth(3),
                                        1: FlexColumnWidth(3),
                                        2: FlexColumnWidth(2),
                                        3: FlexColumnWidth(1),
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
                                                'Accuracy',
                                                style: TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ),
                                        // 데이터 행 - 필터링된 실험 데이터로 채움
                                        ...experimentData.map((exp) => TableRow(
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
                                              child: Text('${exp['accuracy'].toStringAsFixed(1)}%'),
                                            ),
                                          ],
                                        )).toList(),
                                      ],
                                    ),
                                  ),
                            const SizedBox(height: 24),
                            
                            // 정확도 비교 섹션 (데이터가 있을 경우만 표시)
                            if (experimentData.isNotEmpty) ...[
                              Text(
                                'Accuracy Comparison for ${_selectedTestSet ?? "All Evaluations"}',
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
                                    const Text(
                                      'Accuracy Trend',
                                      style: TextStyle(
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
                                                  if (index >= 0 && index < experimentData.length) {
                                                    // 평가 ID를 간략히 표시
                                                    final evalId = experimentData[index]['id'].toString();
                                                    return Padding(
                                                      padding: const EdgeInsets.only(top: 8),
                                                      child: Text(
                                                        evalId.contains('eval') 
                                                            ? 'Eval ${evalId.replaceAll("eval", "")}'
                                                            : 'Eval ${evalId.hashCode % 100}',
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
                            ],
                            
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
                                if (_selectedTestSet != null)
                                  Row(
                                    children: [
                                      Icon(Icons.filter_list, size: 16, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
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
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // 평가 결과 목록
                            filteredEvaluations.isEmpty
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
                                    children: filteredEvaluations.map((eval) => 
                                      _buildEvaluationItem(
                                        title: eval.id.contains('eval') 
                                            ? 'Evaluation ${eval.id.replaceAll('eval', '')}'
                                            : 'Evaluation ${eval.id.hashCode % 100}', // 간단한 ID 변환
                                        accuracy: eval.accuracy,
                                        createdAt: eval.createdAt,
                                        isHighlighted: !eval.id.contains('eval'), // 사용자 생성 평가는 강조
                                        testSet: testSetNames[eval.id] ?? 'Unknown',
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
    required String testSet,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    testSet.split('-').last, // 버전만 표시 (v1, v2 등)
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
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