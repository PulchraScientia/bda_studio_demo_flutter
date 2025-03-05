import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/routes.dart';
import '../providers/workspace_provider.dart';
import '../providers/experiment_provider.dart';

class SidebarMenu extends StatelessWidget {
  const SidebarMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final workspaceProvider = Provider.of<WorkspaceProvider>(context);
    final experimentProvider = Provider.of<ExperimentProvider>(context);
    
    final selectedWorkspace = workspaceProvider.selectedWorkspace;
    final selectedExperiment = experimentProvider.selectedExperiment;
    
    return Container(
      width: 250,
      color: Colors.grey[200],
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: InkWell(
              onTap: () {
                workspaceProvider.clearSelectedWorkspace();
                experimentProvider.clearSelectedExperiment();
                Navigator.pushNamed(context, AppRoutes.workspaceList);
              },
              child: const Text(
                'workspace',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // 선택된 워크스페이스가 있을 때 메뉴 표시
          if (selectedWorkspace != null) ...[
            _buildMenuItem(
              context: context,
              title: 'experiments',
              isSelected: selectedExperiment == null,
              onTap: () {
                experimentProvider.clearSelectedExperiment();
                Navigator.pushNamed(
                  context, 
                  AppRoutes.experimentList,
                  arguments: {'workspaceId': selectedWorkspace.id},
                );
              },
            ),
            
            // 선택된 실험이 있을 때 하위 메뉴 표시
            if (selectedExperiment != null) ...[
              _buildSubMenuItem(
                context: context,
                title: 'materials',
                onTap: () {
                  Navigator.pushNamed(
                    context, 
                    AppRoutes.materialList,
                    arguments: {
                      'workspaceId': selectedWorkspace.id,
                      'experimentId': selectedExperiment.id,
                    },
                  );
                },
              ),
              _buildSubMenuItem(
                context: context,
                title: 'evaluations',
                onTap: () {
                  Navigator.pushNamed(
                    context, 
                    AppRoutes.evaluationList,
                    arguments: {
                      'workspaceId': selectedWorkspace.id,
                      'experimentId': selectedExperiment.id,
                    },
                  );
                },
              ),
              _buildSubMenuItem(
                context: context,
                title: 'assistants',
                onTap: () {
                  Navigator.pushNamed(
                    context, 
                    AppRoutes.assistantList,
                    arguments: {
                      'workspaceId': selectedWorkspace.id,
                      'experimentId': selectedExperiment.id,
                    },
                  );
                },
              ),
              _buildSubMenuItem(
                context: context,
                title: 'chats',
                onTap: () {
                  // 첫 번째 어시스턴트의 채팅 목록으로 이동
                  final assistants = experimentProvider.getAssistantsForExperiment(selectedExperiment.id);
                  if (assistants.isNotEmpty) {
                    Navigator.pushNamed(
                      context, 
                      AppRoutes.chatList,
                      arguments: {
                        'workspaceId': selectedWorkspace.id,
                        'experimentId': selectedExperiment.id,
                        'assistantId': assistants[0].id,
                      },
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No assistants available. Please create an assistant first.')),
                    );
                  }
                },
              ),
            ],
          ],
        ],
      ),
    );
  }
  
  Widget _buildMenuItem({
    required BuildContext context,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: isSelected ? Colors.blue.withOpacity(0.1) : null,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: isSelected ? Colors.blue : Colors.black54,
          ),
        ),
      ),
    );
  }
  
  Widget _buildSubMenuItem({
    required BuildContext context,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.only(left: 32, right: 16, top: 8, bottom: 8),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }
}