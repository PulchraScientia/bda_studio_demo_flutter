// lib/screens/materials/material_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Material -> MaterialModel로 import 변경
import '../../models/material_model.dart';
import '../../config/routes.dart';
import '../../providers/workspace_provider.dart';
import '../../providers/experiment_provider.dart';
import '../../widgets/sidebar_menu.dart';
import '../../widgets/excel_sheet_popup.dart';

class MaterialScreen extends StatefulWidget {
  final String? workspaceId;
  final String? experimentId;
  
  const MaterialScreen({
    Key? key, 
    this.workspaceId, 
    this.experimentId,
  }) : super(key: key);

  @override
  State<MaterialScreen> createState() => _MaterialScreenState();
}

class _MaterialScreenState extends State<MaterialScreen> {
  // 폼 컨트롤러
  final _datasetDescriptionController = TextEditingController();
  
  // 현재 편집 모드인지 여부
  bool _isEditMode = false;
  
  // 현재 선택된 머티리얼 인덱스
  int _selectedMaterialIndex = 0;
  
  // 머티리얼 데이터 - Material -> MaterialModel로 타입 변경
  late MaterialModel _currentMaterial;
  
  @override
  void initState() {
    super.initState();
    
    // 초기화는 didChangeDependencies에서 수행
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    final experimentProvider = Provider.of<ExperimentProvider>(context, listen: false);
    
    // 현재 실험 정보 가져오기
    final experiment = experimentProvider.selectedExperiment ?? 
        experimentProvider.experiments.firstWhere((exp) => exp.id == widget.experimentId);
    
    // 해당 실험의 머티리얼 목록 가져오기
    final materials = experimentProvider.getMaterialsForExperiment(experiment.id);
    
    if (materials.isNotEmpty) {
      _currentMaterial = materials[_selectedMaterialIndex];
      _datasetDescriptionController.text = "데이터셋 설명";  // 실제로는 머티리얼의 설명 필드 사용
    }
  }
  
  @override
  void dispose() {
    _datasetDescriptionController.dispose();
    super.dispose();
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
    
    // 해당 실험의 머티리얼 목록 가져오기
    final materials = experimentProvider.getMaterialsForExperiment(experiment.id);
    
    if (materials.isEmpty) {
      // 머티리얼이 없는 경우 생성 화면 표시
      return _buildCreateMaterialScreen(context, workspace.id, experiment.id, experimentProvider);
    }
    
    // 현재 선택된 머티리얼
    _currentMaterial = materials[_selectedMaterialIndex];

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
                    'Materials',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // 머티리얼 내용 표시
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 액션 버튼
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                width: 100,
                                height: 40,
                                color: Colors.grey[200],
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _isEditMode = true;
                                    });
                                  },
                                  child: const Center(
                                    child: Text('edit'),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 100,
                                height: 40,
                                color: Colors.grey[200],
                                child: InkWell(
                                  onTap: () {
                                    // 평가 실행 액션
                                    _runEvaluation(context, experimentProvider, experiment.id, _currentMaterial.id);
                                  },
                                  child: const Center(
                                    child: Text('evaluate'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          
                          // 데이터셋 설명
                          const Text(
                            'Dataset_description',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _isEditMode
                              ? TextField(
                                  controller: _datasetDescriptionController,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.all(12),
                                  ),
                                )
                              : Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(_datasetDescriptionController.text),
                                ),
                          const SizedBox(height: 20),
                          
                          // TrainSet
                          const Text(
                            'TrainSet',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _isEditMode
                              ? _buildEditableField(
                                  _currentMaterial.trainSet.isNotEmpty 
                                      ? _currentMaterial.trainSet[0].naturalLanguage 
                                      : "사용자 입력칸",
                                  onTap: () => _showExcelPopup(
                                    context, 
                                    'TrainSet', 
                                    ['Natural Language', 'SQL'], 
                                    _currentMaterial.trainSet.map((item) => [
                                      item.naturalLanguage, 
                                      item.sql,
                                    ]).toList(),
                                    (data) {
                                      // 데이터 업데이트 처리
                                      setState(() {
                                        // 실제 구현에서는 데이터를 프로바이더에 업데이트
                                      });
                                    },
                                  ),
                                )
                              : _buildNonEditableField(
                                  _currentMaterial.trainSet.isNotEmpty 
                                      ? _currentMaterial.trainSet[0].naturalLanguage 
                                      : "사용자 입력칸",
                                ),
                          const SizedBox(height: 20),
                          
                          // TestSet
                          const Text(
                            'TestSet',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _isEditMode
                              ? _buildEditableField(
                                  _currentMaterial.testSet.isNotEmpty 
                                      ? _currentMaterial.testSet[0].naturalLanguage 
                                      : "사용자 입력칸",
                                  onTap: () => _showExcelPopup(
                                    context, 
                                    'TestSet', 
                                    ['Natural Language', 'SQL'], 
                                    _currentMaterial.testSet.map((item) => [
                                      item.naturalLanguage, 
                                      item.sql,
                                    ]).toList(),
                                    (data) {
                                      // 데이터 업데이트 처리
                                      setState(() {
                                        // 실제 구현에서는 데이터를 프로바이더에 업데이트
                                      });
                                    },
                                  ),
                                )
                              : _buildNonEditableField(
                                  _currentMaterial.testSet.isNotEmpty 
                                      ? _currentMaterial.testSet[0].naturalLanguage 
                                      : "사용자 입력칸",
                                ),
                          const SizedBox(height: 20),
                          
                          // Knowledge
                          const Text(
                            'Knowledge',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _isEditMode
                              ? _buildEditableField(
                                  _currentMaterial.knowledgeSet.isNotEmpty 
                                      ? _currentMaterial.knowledgeSet[0].naturalLanguage 
                                      : "사용자 입력칸",
                                  onTap: () => _showExcelPopup(
                                    context, 
                                    'Knowledge', 
                                    ['Key', 'Value'], 
                                    _currentMaterial.knowledgeSet.map((item) => [
                                      item.naturalLanguage, 
                                      item.sql,
                                    ]).toList(),
                                    (data) {
                                      // 데이터 업데이트 처리
                                      setState(() {
                                        // 실제 구현에서는 데이터를 프로바이더에 업데이트
                                      });
                                    },
                                  ),
                                )
                              : _buildNonEditableField(
                                  _currentMaterial.knowledgeSet.isNotEmpty 
                                      ? _currentMaterial.knowledgeSet[0].naturalLanguage 
                                      : "사용자 입력칸",
                                ),
                          
                          // 편집 모드일 때 저장/취소 버튼
                          if (_isEditMode) ...[
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  width: 100,
                                  height: 40,
                                  color: Colors.grey[200],
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _isEditMode = false;
                                      });
                                    },
                                    child: const Center(
                                      child: Text('cancel'),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 100,
                                  height: 40,
                                  color: Colors.grey[200],
                                  child: InkWell(
                                    onTap: () {
                                      // 데이터 저장 처리
                                      setState(() {
                                        _isEditMode = false;
                                        // 실제 구현에서는 데이터를 프로바이더에 업데이트
                                      });
                                    },
                                    child: const Center(
                                      child: Text('save'),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
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
  
  // 편집 가능한 필드
  Widget _buildEditableField(String text, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(text),
      ),
    );
  }
  
  // 편집 불가능한 필드
  Widget _buildNonEditableField(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text),
    );
  }
  
  // 머티리얼 생성 화면
  Widget _buildCreateMaterialScreen(
    BuildContext context, 
    String workspaceId, 
    String experimentId,
    ExperimentProvider experimentProvider,
  ) {
    // 머티리얼 생성 화면은 기본적으로 편집 화면과 유사
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
                    'Materials',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // 머티리얼 생성 폼
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 액션 버튼
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                width: 100,
                                height: 40,
                                color: Colors.grey[200],
                                child: InkWell(
                                  onTap: () {
                                    // 새 머티리얼 생성 취소
                                    Navigator.pop(context);
                                  },
                                  child: const Center(
                                    child: Text('cancel'),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 100,
                                height: 40,
                                color: Colors.grey[200],
                                child: InkWell(
                                  onTap: () {
                                    // 머티리얼 저장 처리
                                    _saveMaterial(context, experimentProvider, experimentId);
                                  },
                                  child: const Center(
                                    child: Text('save'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          
                          // 데이터셋 설명
                          const Text(
                            'Dataset_description',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _datasetDescriptionController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.all(12),
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // TrainSet
                          const Text(
                            'TrainSet',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildEditableField(
                            "사용자 입력칸",
                            onTap: () => _showExcelPopup(
                              context, 
                              'TrainSet', 
                              ['Natural Language', 'SQL'], 
                              [], // 빈 데이터로 시작
                              (data) {
                                // 데이터 업데이트 처리
                                setState(() {
                                  // 훈련 데이터 저장 로직
                                  // _trainSetData = data;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // TestSet
                          const Text(
                            'TestSet',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildEditableField(
                            "사용자 입력칸",
                            onTap: () => _showExcelPopup(
                              context, 
                              'TestSet', 
                              ['Natural Language', 'SQL'], 
                              [], // 빈 데이터로 시작
                              (data) {
                                // 데이터 업데이트 처리
                                setState(() {
                                  // 테스트 데이터 저장 로직
                                  // _testSetData = data;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // Knowledge
                          const Text(
                            'Knowledge',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildEditableField(
                            "사용자 입력칸",
                            onTap: () => _showExcelPopup(
                              context, 
                              'Knowledge', 
                              ['Key', 'Value'], 
                              [], // 빈 데이터로 시작
                              (data) {
                                // 데이터 업데이트 처리
                                setState(() {
                                  // 지식 데이터 저장 로직
                                  // _knowledgeData = data;
                                });
                              },
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
  
  // Excel 시트 팝업 표시
  void _showExcelPopup(
    BuildContext context,
    String title,
    List<String> headers,
    List<List<String>> initialData,
    Function(List<List<String>>) onSave,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ExcelSheetPopup(
          title: title,
          headers: headers,
          initialData: initialData,
          onSave: onSave,
        );
      },
    );
  }
  
  // 머티리얼 저장
  Future<void> _saveMaterial(
    BuildContext context,
    ExperimentProvider experimentProvider,
    String experimentId,
  ) async {
    // 훈련 세트 생성 (실제 구현에서는 팝업에서 받은 데이터 사용)
    final trainSet = [
      MaterialItem(
        id: 'train_${DateTime.now().millisecondsSinceEpoch}',
        type: 'train',
        naturalLanguage: '샘플 자연어 쿼리',
        sql: 'SELECT * FROM table',
      ),
    ];
    
    // 테스트 세트 생성
    final testSet = [
      MaterialItem(
        id: 'test_${DateTime.now().millisecondsSinceEpoch}',
        type: 'test',
        naturalLanguage: '샘플 테스트 쿼리',
        sql: 'SELECT * FROM test_table',
      ),
    ];
    
    // 지식 세트 생성
    final knowledgeSet = [
      MaterialItem(
        id: 'knowledge_${DateTime.now().millisecondsSinceEpoch}',
        type: 'knowledge',
        naturalLanguage: '샘플 지식',
        sql: 'CREATE TABLE sample (id INT, name VARCHAR(255))',
      ),
    ];
    
    // 머티리얼 생성
    await experimentProvider.createMaterial(
      experimentId,
      trainSet,
      testSet,
      knowledgeSet,
    );
    
    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Material created successfully')),
      );
    }
  }
  
  Future<void> _runEvaluation(
    BuildContext context,
    ExperimentProvider experimentProvider,
    String experimentId,
    String materialId,
  ) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    
    // 로딩 다이얼로그 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Running evaluation...'),
          ],
        ),
      ),
    );
    
    try {
      // 평가 실행
      await experimentProvider.createEvaluation(experimentId, materialId);
      
      // 로딩 다이얼로그 닫기
      navigator.pop();
      
      // 평가 결과 화면으로 이동
      navigator.pushNamed(
        AppRoutes.evaluationList,
        arguments: {
          'workspaceId': widget.workspaceId,
          'experimentId': experimentId,
        },
      );
    } catch (e) {
      // 로딩 다이얼로그 닫기
      navigator.pop();
      
      // 오류 메시지 표시
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Failed to run evaluation: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}