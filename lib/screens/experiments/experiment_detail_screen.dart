// lib/screens/experiments/experiment_detail.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/routes.dart';
import '../../models/experiment.dart';
import '../../providers/workspace_provider.dart';
import '../../providers/experiment_provider.dart';
import '../../widgets/sidebar_menu.dart';

class ExperimentDetailScreen extends StatefulWidget {
  final String? workspaceId;
  final String? experimentId;
  
  const ExperimentDetailScreen({
    Key? key, 
    this.workspaceId, 
    this.experimentId,
  }) : super(key: key);

  @override
  State<ExperimentDetailScreen> createState() => _ExperimentDetailScreenState();
}

class _ExperimentDetailScreenState extends State<ExperimentDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    
    // 데이터 초기화는 didChangeDependencies에서 수행
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final experimentProvider = Provider.of<ExperimentProvider>(context, listen: false);
    final experiment = experimentProvider.experiments.firstWhere(
      (exp) => exp.id == widget.experimentId,
      orElse: () => experimentProvider.selectedExperiment!,
    );
    
    _nameController.text = experiment.name;
    _descriptionController.text = experiment.description;
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final experimentProvider = Provider.of<ExperimentProvider>(context);
    final workspaceProvider = Provider.of<WorkspaceProvider>(context);
    
    final workspace = workspaceProvider.selectedWorkspace!;
    final experiment = experimentProvider.experiments.firstWhere(
      (exp) => exp.id == widget.experimentId,
      orElse: () => experimentProvider.selectedExperiment!,
    );
    
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
                          Navigator.pushNamed(
                            context, 
                            AppRoutes.experimentList,
                            arguments: {'workspaceId': workspace.id},
                          );
                        },
                        child: const Row(
                          children: [
                            Icon(Icons.arrow_back),
                            SizedBox(width: 8),
                            Text('<< experiment list'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // 실험 제목
                  Text(
                    experiment.name,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // 디테일 폼
                  Expanded(
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 800),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'experiment_name',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  hintText: 'Enter experiment name',
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter an experiment name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),
                              
                              const Text(
                                'description',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _descriptionController,
                                decoration: const InputDecoration(
                                  hintText: 'Enter experiment description',
                                ),
                                maxLines: 3,
                              ),
                              const SizedBox(height: 24),
                              
                              const Text(
                                'dataset',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              
                              // 데이터셋 목록 표시
                              Column(
                                children: experiment.dataset.tables.map((table) {
                                  // 여기서는 테이블마다 랜덤하게 동기화 상태를 표시합니다 (예시용)
                                  // 실제로는 각 테이블의 실제 동기화 상태를 확인해야 합니다
                                  final isSync = table.contains('_') ? false : true; // 예시: 테이블 이름에 '_'가 있으면 비동기
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            // 데이터셋 이름을 테이블 이름 앞에 추가
                                            '${experiment.dataset.name}.$table',
                                          ),
                                        ),
                                        Container(
                                          width: 80,
                                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                          decoration: BoxDecoration(
                                            color: isSync ? Colors.green : Colors.red,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            isSync ? 'sync' : 'out of sync',
                                            style: const TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'evaluation',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                decoration: const InputDecoration(
                                  hintText: 'Select evaluation',
                                  enabled: false,
                                ),
                              ),
                              const SizedBox(height: 24),
                              
                              const Text(
                                'assistant',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                decoration: const InputDecoration(
                                  hintText: 'Select assistant',
                                  enabled: false,
                                ),
                              ),
                            ],
                          ),
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
  
  Widget _buildTableRow(String tableName, bool isSync) {
    final Color statusColor = isSync ? Colors.green : Colors.red;
    final String syncStatus = isSync ? 'sync' : 'out of sync';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  bottomLeft: Radius.circular(4),
                ),
              ),
              child: Text(tableName),
            ),
          ),
          Container(
            width: 120,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(4),
                bottomRight: Radius.circular(4),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              syncStatus,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}