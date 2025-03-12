// lib/screens/materials/material_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/routes.dart';
import '../../models/experiment.dart';
import '../../models/material_model.dart';
import '../../providers/experiment_provider.dart';
import '../../providers/workspace_provider.dart';
import '../../widgets/excel_sheet_popup.dart';
import '../../widgets/sidebar_menu.dart';

class MaterialScreen extends StatefulWidget {
  final String? workspaceId;
  final String? experimentId;

  const MaterialScreen({super.key, this.workspaceId, this.experimentId});

  @override
  State<MaterialScreen> createState() => _MaterialScreenState();
}

class _MaterialScreenState extends State<MaterialScreen> {
  // 폼 컨트롤러
  final _datasetNameController = TextEditingController();
  final _tablesController = TextEditingController();
  final _columnsController = TextEditingController();

  // 현재 편집 모드인지 여부
  bool _isEditMode = false;

  // 현재 선택된 머티리얼 인덱스
  final int _selectedMaterialIndex = 0;

  // 트레이닝, 테스트, 지식 데이터 저장
  List<List<String>> _trainSetData = [];
  List<List<String>> _testSetData = [];
  List<List<String>> _knowledgeSetData = [];

  // 머티리얼 데이터
  MaterialModel? _currentMaterial;

  // 생성 모드인지 여부
  bool _isCreateMode = false;

  late Experiment _currentExperiment;

  @override
  void initState() {
    super.initState();

    // 초기화는 didChangeDependencies에서 수행
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final experimentProvider = Provider.of<ExperimentProvider>(
      context,
      listen: false,
    );

    // 현재 실험 정보 가져오기
    _currentExperiment =
        experimentProvider.selectedExperiment ??
        experimentProvider.experiments.firstWhere(
          (exp) => exp.id == widget.experimentId,
        );

    // 해당 실험의 머티리얼 목록 가져오기
    final materials = experimentProvider.getMaterialsForExperiment(
      _currentExperiment.id,
    );

    // 생성 모드 체크
    _isCreateMode = materials.isEmpty;

    if (!_isCreateMode && materials.isNotEmpty) {
      _currentMaterial = materials[_selectedMaterialIndex];

      // 데이터셋 관련 컨트롤러 초기화
      _datasetNameController.text = _currentExperiment.dataset.name;
      _tablesController.text = _currentExperiment.dataset.tables.join(', ');
      _columnsController.text =
          "customers.customer_id: 고객 고유 ID\n"
          "customers.name: 고객 이름\n"
          "orders.order_id: 주문 고유 ID\n"
          "orders.customer_id: 주문한 고객 ID";

      // 데이터 초기화
      _initializeData();
    } else {
      // 생성 모드일 때도 기본값으로 초기화
      _datasetNameController.text = _currentExperiment.dataset.name;
      _tablesController.text = _currentExperiment.dataset.tables.join(', ');
      _columnsController.text = "";
      _trainSetData = [];
      _testSetData = [];
      _knowledgeSetData = [];
    }
  }

  // 데이터 초기화
  void _initializeData() {
    if (_currentMaterial == null) return;

    // 트레이닝 데이터 초기화
    _trainSetData =
        _currentMaterial!.trainSet
            .map((item) => [item.naturalLanguage, item.sql])
            .toList();

    // 테스트 데이터 초기화
    _testSetData =
        _currentMaterial!.testSet
            .map((item) => [item.naturalLanguage, item.sql])
            .toList();

    // 지식 데이터 초기화
    _knowledgeSetData =
        _currentMaterial!.knowledgeSet
            .map((item) => [item.naturalLanguage, item.sql])
            .toList();

    // 데이터셋 관련 컨트롤러 초기화
    _datasetNameController.text = _currentExperiment.dataset.name;
    _tablesController.text = _currentExperiment.dataset.tables.join(', ');
    _columnsController.text =
        "customers.customer_id: 고객 고유 ID\ncustomers.name: 고객 이름\norders.order_id: 주문 고유 ID\norders.customer_id: 주문한 고객 ID\nproducts.product_id: 제품 고유 ID\nproducts.price: 제품 가격";
  }

  @override
  void dispose() {
    _datasetNameController.dispose();
    _tablesController.dispose();
    _columnsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workspaceProvider = Provider.of<WorkspaceProvider>(context);
    final experimentProvider = Provider.of<ExperimentProvider>(context);

    // 현재 워크스페이스 정보 가져오기
    final workspace =
        workspaceProvider.selectedWorkspace ??
        workspaceProvider.workspaces.firstWhere(
          (ws) => ws.id == widget.workspaceId,
        );

    // 현재 실험 정보 가져오기
    final experiment =
        experimentProvider.selectedExperiment ??
        experimentProvider.experiments.firstWhere(
          (exp) => exp.id == widget.experimentId,
        );

    // 해당 실험의 머티리얼 목록 가져오기
    final materials = experimentProvider.getMaterialsForExperiment(
      experiment.id,
    );

    if (materials.isEmpty || _isCreateMode) {
      // 머티리얼이 없는 경우 생성 화면 표시
      return _buildCreateMaterialScreen(
        context,
        workspace.id,
        experiment.id,
        experimentProvider,
      );
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Materials',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // 평가 실행 버튼
                      ElevatedButton.icon(
                        onPressed: () {
                          _runEvaluation(
                            context,
                            experimentProvider,
                            experiment.id,
                            _currentMaterial!.id,
                          );
                        },
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Run Evaluation'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                      ),
                    ],
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
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 액션 버튼
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // 편집 모드 토글 버튼
                                OutlinedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _isEditMode = !_isEditMode;
                                    });
                                  },
                                  icon: Icon(
                                    _isEditMode ? Icons.check : Icons.edit,
                                  ),
                                  label: Text(_isEditMode ? 'Done' : 'Edit'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            Card(
                              margin: const EdgeInsets.only(bottom: 20),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Dataset Description',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 16),

                                    // 데이터셋 이름
                                    Row(
                                      children: [
                                        const SizedBox(
                                          width: 100,
                                          child: Text('Dataset Name:'),
                                        ),
                                        Expanded(
                                          child:
                                              _isEditMode
                                                  ? TextField(
                                                    controller:
                                                        _datasetNameController,
                                                    decoration:
                                                        const InputDecoration(
                                                          border:
                                                              OutlineInputBorder(),
                                                          contentPadding:
                                                              EdgeInsets.all(8),
                                                        ),
                                                  )
                                                  : Text(
                                                    _datasetNameController.text,
                                                  ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),

                                    // 테이블 목록
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(
                                          width: 100,
                                          child: Text('Tables:'),
                                        ),
                                        Expanded(
                                          child:
                                              _isEditMode
                                                  ? TextField(
                                                    controller:
                                                        _tablesController,
                                                    decoration: const InputDecoration(
                                                      border:
                                                          OutlineInputBorder(),
                                                      contentPadding:
                                                          EdgeInsets.all(8),
                                                      hintText:
                                                          'Enter table names (comma separated)',
                                                    ),
                                                    maxLines: 3,
                                                  )
                                                  : Text(
                                                    _tablesController.text,
                                                  ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),

                                    // 컬럼 설명
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(
                                          width: 100,
                                          child: Text('Columns:'),
                                        ),
                                        Expanded(
                                          child:
                                              _isEditMode
                                                  ? TextField(
                                                    controller:
                                                        _columnsController,
                                                    decoration: const InputDecoration(
                                                      border:
                                                          OutlineInputBorder(),
                                                      contentPadding:
                                                          EdgeInsets.all(8),
                                                      hintText:
                                                          'Enter column details (table.column: description)',
                                                    ),
                                                    maxLines: 5,
                                                  )
                                                  : Text(
                                                    _columnsController.text,
                                                  ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // TrainSet
                            _buildDataSection(
                              title: 'Training Set',
                              description: 'Examples for model training',
                              buttonText: 'Edit Training Data',
                              isEmpty: _currentMaterial!.trainSet.isEmpty,
                              data: _trainSetData,
                              onEdit:
                                  () => _showExcelPopup(
                                    context,
                                    'Training Set',
                                    ['Natural Language', 'SQL'],
                                    _trainSetData,
                                    (data) {
                                      setState(() {
                                        _trainSetData = data;
                                      });
                                    },
                                  ),
                            ),

                            // TestSet
                            _buildDataSection(
                              title: 'Test Set',
                              description: 'Examples for evaluation',
                              buttonText: 'Edit Test Data',
                              isEmpty: _currentMaterial!.testSet.isEmpty,
                              data: _testSetData,
                              onEdit:
                                  () => _showExcelPopup(
                                    context,
                                    'Test Set',
                                    ['Natural Language', 'SQL'],
                                    _testSetData,
                                    (data) {
                                      setState(() {
                                        _testSetData = data;
                                      });
                                    },
                                  ),
                            ),

                            // Knowledge
                            _buildDataSection(
                              title: 'Knowledge',
                              description:
                                  'Additional information for the model',
                              buttonText: 'Edit Knowledge Data',
                              isEmpty: _currentMaterial!.knowledgeSet.isEmpty,
                              data: _knowledgeSetData,
                              onEdit:
                                  () => _showExcelPopup(
                                    context,
                                    'Knowledge',
                                    ['Key', 'Value'],
                                    _knowledgeSetData,
                                    (data) {
                                      setState(() {
                                        _knowledgeSetData = data;
                                      });
                                    },
                                  ),
                            ),

                            // 편집 모드일 때 저장 버튼
                            if (_isEditMode) ...[
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton(
                                    onPressed: () {
                                      setState(() {
                                        _isEditMode = false;
                                        // 변경 취소하고 데이터 다시 초기화
                                        _initializeData();
                                      });
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      // 데이터 저장 처리
                                      _saveMaterial(
                                        context,
                                        experimentProvider,
                                        experiment.id,
                                      );
                                    },
                                    child: const Text('Save Changes'),
                                  ),
                                ],
                              ),
                            ],
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

  // 데이터 섹션 위젯
  Widget _buildDataSection({
    required String title,
    required String description,
    required String buttonText,
    required bool isEmpty,
    required List<List<String>> data,
    required VoidCallback onEdit,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      description,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
                if (_isEditMode)
                  OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit),
                    label: Text(buttonText),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // 데이터 미리보기
            if (isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'No data available. Click Edit button to add data.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else
              _buildDataPreview(data, title.toLowerCase()),
          ],
        ),
      ),
    );
  }

  // 데이터 미리보기 위젯
  Widget _buildDataPreview(List<List<String>> data, String type) {
    // 최대 5개 행만 표시
    final previewData = data.take(5).toList();

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: [
            const DataColumn(
              label: Text('#', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            if (previewData.isNotEmpty && previewData[0].isNotEmpty)
              DataColumn(
                label: Text(
                  // Knowledge인 경우 "Key", 그 외는 "Natural Language"
                  type == 'knowledge' ? 'Key' : 'Natural Language',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            if (previewData.isNotEmpty && previewData[0].length > 1)
              DataColumn(
                label: Text(
                  // Knowledge인 경우 "Value", 그 외는 "SQL"
                  type == 'knowledge' ? 'Value' : 'SQL',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
          ],
          rows: List.generate(previewData.length, (index) {
            return DataRow(
              cells: [
                DataCell(Text('${index + 1}')),
                if (previewData[index].isNotEmpty)
                  DataCell(
                    Container(
                      constraints: const BoxConstraints(maxWidth: 300),
                      child: Text(
                        previewData[index][0],
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                if (previewData[index].length > 1)
                  DataCell(
                    Container(
                      constraints: const BoxConstraints(maxWidth: 300),
                      child: Text(
                        previewData[index][1],
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }

  // 머티리얼 생성 화면
  Widget _buildCreateMaterialScreen(
    BuildContext context,
    String workspaceId,
    String experimentId,
    ExperimentProvider experimentProvider,
  ) {
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Create Material',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // 뒤로 가기 버튼
                      TextButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Back to Experiment'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 설명 텍스트
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'What is a Material?',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'A Material is a collection of training examples, test examples, and knowledge that will be used to train and evaluate models.',
                          ),
                          SizedBox(height: 8),
                          Text(
                            '• Training Set: Examples used to train the model',
                          ),
                          Text(
                            '• Test Set: Examples used to evaluate the model',
                          ),
                          Text(
                            '• Knowledge: Additional information for the model',
                          ),
                        ],
                      ),
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
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 데이터셋 설명
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Dataset Description',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 16),

                                    // 데이터셋 이름
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Dataset Name:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        TextField(
                                          controller: _datasetNameController,
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            hintText: 'Enter dataset name',
                                            contentPadding: EdgeInsets.all(12),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),

                                    // 테이블 목록
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Tables:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        TextField(
                                          controller: _tablesController,
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            hintText:
                                                'Enter table names (comma separated)',
                                            contentPadding: EdgeInsets.all(12),
                                          ),
                                          maxLines: 2,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),

                                    // 컬럼 설명
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Columns:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        TextField(
                                          controller: _columnsController,
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            hintText:
                                                'Enter column details (table.column: description)',
                                            contentPadding: EdgeInsets.all(12),
                                          ),
                                          maxLines: 4,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // TrainSet
                            Card(
                              margin: const EdgeInsets.only(bottom: 20),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Training Set',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              'Examples for model training',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          ],
                                        ),
                                        // 항상 보이는 편집 버튼 (생성 모드)
                                        OutlinedButton.icon(
                                          onPressed:
                                              () => _showExcelPopup(
                                                context,
                                                'Training Set',
                                                ['Natural Language', 'SQL'],
                                                _trainSetData,
                                                (data) {
                                                  setState(() {
                                                    _trainSetData = data;
                                                  });
                                                },
                                              ),
                                          icon: const Icon(Icons.edit),
                                          label: const Text(
                                            'Add Training Data',
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),

                                    // 데이터 미리보기 또는 안내 메시지
                                    _trainSetData.isEmpty
                                        ? Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          alignment: Alignment.center,
                                          child: const Text(
                                            'No data yet. Click "Add Training Data" to add your training examples.',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        )
                                        : _buildDataPreview(
                                          _trainSetData,
                                          'train',
                                        ),
                                  ],
                                ),
                              ),
                            ),

                            // TestSet
                            Card(
                              margin: const EdgeInsets.only(bottom: 20),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Test Set',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              'Examples for evaluation',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          ],
                                        ),
                                        // 항상 보이는 편집 버튼 (생성 모드)
                                        OutlinedButton.icon(
                                          onPressed:
                                              () => _showExcelPopup(
                                                context,
                                                'Test Set',
                                                ['Natural Language', 'SQL'],
                                                _testSetData,
                                                (data) {
                                                  setState(() {
                                                    _testSetData = data;
                                                  });
                                                },
                                              ),
                                          icon: const Icon(Icons.edit),
                                          label: const Text('Add Test Data'),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),

                                    // 데이터 미리보기 또는 안내 메시지
                                    _testSetData.isEmpty
                                        ? Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          alignment: Alignment.center,
                                          child: const Text(
                                            'No data yet. Click "Add Test Data" to add your test examples.',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        )
                                        : _buildDataPreview(
                                          _testSetData,
                                          'test',
                                        ),
                                  ],
                                ),
                              ),
                            ),

                            // Knowledge
                            Card(
                              margin: const EdgeInsets.only(bottom: 20),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Knowledge',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              'Additional information for the model',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          ],
                                        ),
                                        // 항상 보이는 편집 버튼 (생성 모드)
                                        OutlinedButton.icon(
                                          onPressed:
                                              () => _showExcelPopup(
                                                context,
                                                'Knowledge',
                                                ['Key', 'Value'],
                                                _knowledgeSetData,
                                                (data) {
                                                  setState(() {
                                                    _knowledgeSetData = data;
                                                  });
                                                },
                                              ),
                                          icon: const Icon(Icons.edit),
                                          label: const Text(
                                            'Add Knowledge Data',
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),

                                    // 데이터 미리보기 또는 안내 메시지
                                    _knowledgeSetData.isEmpty
                                        ? Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          alignment: Alignment.center,
                                          child: const Text(
                                            'No data yet. Click "Add Knowledge Data" to add your knowledge base.',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        )
                                        : _buildDataPreview(
                                          _knowledgeSetData,
                                          'knowledge',
                                        ),
                                  ],
                                ),
                              ),
                            ),

                            // 액션 버튼
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.experimentDetail,
                                      arguments: {
                                        'workspaceId': workspaceId,
                                        'experimentId': experimentId,
                                      },
                                    );
                                  },
                                  child: const Text('Cancel'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed:
                                      experimentProvider.isLoading
                                          ? null
                                          : () {
                                            _createMaterial(
                                              context,
                                              experimentProvider,
                                              experimentId,
                                            );
                                          },
                                  child:
                                      experimentProvider.isLoading
                                          ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                          : const Text('Create Material'),
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

  // 현재 데이터로 MaterialItem 생성
  List<MaterialItem> _createMaterialItems(
    String type,
    List<List<String>> data,
  ) {
    return data.map((row) {
      if (row.length < 2) {
        // 데이터가 부족한 경우 빈 값 추가
        row = [...row, ...List.filled(2 - row.length, '')];
      }

      return MaterialItem(
        id: '${type}_${DateTime.now().millisecondsSinceEpoch}_${row.hashCode}',
        type: type,
        naturalLanguage: row[0],
        sql: row[1],
      );
    }).toList();
  }

  // 머티리얼 생성
  Future<void> _createMaterial(
    BuildContext context,
    ExperimentProvider experimentProvider,
    String experimentId,
  ) async {
    // 유효성 검사 - 데이터셋 이름만 필수로 변경
    if (_datasetNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a dataset name')),
      );
      return;
    }

    if (_trainSetData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Training set cannot be empty')),
      );
      return;
    }

    final trainSet = _createMaterialItems('train', _trainSetData);
    final testSet = _createMaterialItems('test', _testSetData);
    final knowledgeSet = _createMaterialItems('knowledge', _knowledgeSetData);

    // 여기서부터는 기존 코드와 동일
    await experimentProvider.createMaterial(
      experimentId,
      trainSet,
      testSet,
      knowledgeSet,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Material created successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // 생성 모드 종료
      setState(() {
        _isCreateMode = false;
      });

      // 머티리얼 목록 페이지로 이동
      Navigator.pushNamed(
        context,
        AppRoutes.materialList,
        arguments: {
          'workspaceId': widget.workspaceId,
          'experimentId': experimentId,
        },
      );
    }
  }

  // 기존 머티리얼 업데이트
  Future<void> _saveMaterial(
    BuildContext context,
    ExperimentProvider experimentProvider,
    String experimentId,
  ) async {
    // 유효성 검사 - 데이터셋 이름만 필수로 변경
    if (_datasetNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a dataset name')),
      );
      return;
    }

    if (_trainSetData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Training set cannot be empty')),
      );
      return;
    }

    // 나머지 부분은 기존 코드와 동일
    final trainSet = _createMaterialItems('train', _trainSetData);
    final testSet = _createMaterialItems('test', _testSetData);
    final knowledgeSet = _createMaterialItems('knowledge', _knowledgeSetData);

    await experimentProvider.createMaterial(
      experimentId,
      trainSet,
      testSet,
      knowledgeSet,
    );

    if (context.mounted) {
      setState(() {
        _isEditMode = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Material updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // 평가 실행
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
      builder:
          (context) => const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Running evaluation. This may take a while...'),
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
