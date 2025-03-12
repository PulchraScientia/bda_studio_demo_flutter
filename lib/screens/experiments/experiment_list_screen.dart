// lib/screens/experiments/experiment_list.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/routes.dart';
import '../../providers/experiment_provider.dart';
import '../../providers/workspace_provider.dart';
import '../../widgets/sidebar_menu.dart';

class ExperimentListScreen extends StatelessWidget {
  final String? workspaceId;

  const ExperimentListScreen({super.key, this.workspaceId});

  @override
  Widget build(BuildContext context) {
    final workspaceProvider = Provider.of<WorkspaceProvider>(context);
    final experimentProvider = Provider.of<ExperimentProvider>(context);

    // 현재 워크스페이스 정보 가져오기
    final workspace =
        workspaceProvider.selectedWorkspace ??
        workspaceProvider.workspaces.firstWhere((ws) => ws.id == workspaceId);
    workspaceProvider.selectWorkspace(workspace.id);

    // 해당 워크스페이스의 실험 목록 가져오기
    final experiments = experimentProvider.getExperimentsForWorkspace(
      workspace.id,
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
                        child: Container(
                          color: Colors.grey[200],
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
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.experimentCreate,
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
                                  'create',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 실험 목록
                  Expanded(
                    child:
                        experiments.isEmpty
                            ? const Center(
                              child: Text(
                                'No experiments found. Create one to get started.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                            : ListView.builder(
                              itemCount: experiments.length,
                              itemBuilder: (context, index) {
                                final experiment = experiments[index];
                                return InkWell(
                                  onTap: () {
                                    experimentProvider.selectExperiment(
                                      experiment.id,
                                    );
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.experimentDetail,
                                      arguments: {
                                        'workspaceId': workspace.id,
                                        'experimentId': experiment.id,
                                      },
                                    );
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color:
                                          index == 0
                                              ? Colors.grey[200]
                                              : Colors.white,
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      experiment.name,
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                  ),
                                );
                              },
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
