import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/routes.dart';
import '../../providers/experiment_provider.dart';
import '../../providers/workspace_provider.dart';
import '../../widgets/sidebar_menu.dart';

class WorkspaceListScreen extends StatelessWidget {
  const WorkspaceListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final workspaceProvider = Provider.of<WorkspaceProvider>(context);
    final workspaces = workspaceProvider.workspaces;

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
                    'Workspace',
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
                              AppRoutes.workspaceCreate,
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

                  // 워크스페이스 목록
                  Expanded(
                    child: ListView.builder(
                      itemCount: workspaces.length,
                      itemBuilder: (context, index) {
                        final workspace = workspaces[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // 워크스페이스 이름
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    workspaceProvider.selectWorkspace(
                                      workspace.id,
                                    );

                                    // 선택한 워크스페이스의 실험 목록 확인
                                    final experimentProvider =
                                        Provider.of<ExperimentProvider>(
                                          context,
                                          listen: false,
                                        );
                                    final experiments = experimentProvider
                                        .getExperimentsForWorkspace(
                                          workspace.id,
                                        );

                                    if (experiments.isEmpty) {
                                      // 실험이 없으면 실험 생성 페이지로 이동
                                      Navigator.pushNamed(
                                        context,
                                        AppRoutes.experimentCreate,
                                        arguments: {
                                          'workspaceId': workspace.id,
                                        },
                                      );
                                    } else {
                                      // 실험이 있으면 실험 목록 페이지로 이동
                                      Navigator.pushNamed(
                                        context,
                                        AppRoutes.experimentList,
                                        arguments: {
                                          'workspaceId': workspace.id,
                                        },
                                      );
                                    }
                                  },
                                  child: Text(
                                    workspace.name,
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ),
                              ),

                              // 편집 버튼
                              ElevatedButton.icon(
                                onPressed: () {
                                  workspaceProvider.selectWorkspace(
                                    workspace.id,
                                  );
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.workspaceDetail,
                                    arguments: {'workspaceId': workspace.id},
                                  );
                                },
                                icon: const Icon(Icons.edit),
                                label: const Text('Edit'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                              ),
                            ],
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
