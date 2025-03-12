// lib/screens/experiments/experiment_create.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/routes.dart';
import '../../models/experiment.dart';
import '../../providers/experiment_provider.dart';
import '../../providers/workspace_provider.dart';
import '../../widgets/sidebar_menu.dart';

class ExperimentCreateScreen extends StatefulWidget {
  final String? workspaceId;

  const ExperimentCreateScreen({super.key, this.workspaceId});

  @override
  State<ExperimentCreateScreen> createState() => _ExperimentCreateScreenState();
}

class _ExperimentCreateScreenState extends State<ExperimentCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _serviceAccountController = TextEditingController();
  final _datasetController = TextEditingController();
  final _tableIdController = TextEditingController();

  final List<String> _selectedTables = [];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _serviceAccountController.dispose();
    _datasetController.dispose();
    _tableIdController.dispose();
    super.dispose();
  }

  void _addTable() {
    if (_tableIdController.text.isNotEmpty) {
      setState(() {
        _selectedTables.add(
          '${_datasetController.text}.${_tableIdController.text}',
        );
        _tableIdController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final experimentProvider = Provider.of<ExperimentProvider>(context);
    final workspaceProvider = Provider.of<WorkspaceProvider>(context);

    final workspace =
        workspaceProvider.selectedWorkspace ??
        workspaceProvider.workspaces.firstWhere(
          (ws) => ws.id == widget.workspaceId,
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
                  // 헤더
                  const Text(
                    'Experiment',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),

                  // 탭 버튼
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.experimentList,
                              arguments: {'workspaceId': workspace.id},
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                            ),
                            child: const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 12.0),
                                child: Text(
                                  'list',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 12.0),
                              child: Text(
                                'create',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 생성 폼
                  Expanded(
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
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
                            Container(
                              padding: const EdgeInsets.all(8),
                              color: Colors.grey[200],
                              child: TextFormField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  hintText: 'Enter experiment name',
                                  border: InputBorder.none,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter an experiment name';
                                  }
                                  return null;
                                },
                              ),
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
                            Container(
                              padding: const EdgeInsets.all(8),
                              color: Colors.grey[200],
                              child: TextFormField(
                                controller: _descriptionController,
                                decoration: const InputDecoration(
                                  hintText: 'Enter experiment description',
                                  border: InputBorder.none,
                                ),
                                maxLines: 3,
                              ),
                            ),
                            const SizedBox(height: 24),

                            const Text(
                              'GCP service account',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              color: Colors.grey[200],
                              child: TextFormField(
                                controller: _serviceAccountController,
                                decoration: const InputDecoration(
                                  hintText: 'Enter GCP service account',
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // 데이터셋 및 테이블 선택
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Dataset',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        color: Colors.grey[200],
                                        child: TextFormField(
                                          controller: _datasetController,
                                          decoration: const InputDecoration(
                                            hintText: 'Enter dataset name',
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'table_id',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              padding: const EdgeInsets.all(8),
                                              color: Colors.grey[200],
                                              child: TextFormField(
                                                controller: _tableIdController,
                                                decoration:
                                                    const InputDecoration(
                                                      hintText:
                                                          'Enter table ID',
                                                      border: InputBorder.none,
                                                    ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            color: Colors.grey[200],
                                            child: IconButton(
                                              onPressed: _addTable,
                                              icon: const Icon(Icons.add),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // 선택된 테이블 목록
                            if (_selectedTables.isNotEmpty) ...[
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  _selectedTables.join(', '),
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],

                            // 생성 버튼
                            Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                width: 100,
                                height: 40,
                                color: Colors.grey[200],
                                child: InkWell(
                                  onTap:
                                      experimentProvider.isLoading
                                          ? null
                                          : () async {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              final dataset = Dataset(
                                                id:
                                                    'ds${DateTime.now().millisecondsSinceEpoch}',
                                                name: _datasetController.text,
                                                tables: _selectedTables,
                                                isOutOfSync: false,
                                              );

                                              await experimentProvider
                                                  .createExperiment(
                                                    workspace.id,
                                                    _nameController.text,
                                                    _descriptionController.text,
                                                    dataset,
                                                  );

                                              if (!mounted) return;

                                              Navigator.pushNamed(
                                                context,
                                                AppRoutes.experimentDetail,
                                                arguments: {
                                                  'workspaceId': workspace.id,
                                                  'experimentId':
                                                      experimentProvider
                                                          .selectedExperiment!
                                                          .id,
                                                },
                                              );
                                            }
                                          },
                                  child: Center(
                                    child:
                                        experimentProvider.isLoading
                                            ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                            : const Text(
                                              'create',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                  ),
                                ),
                              ),
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
}
