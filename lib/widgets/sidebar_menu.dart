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
      color: Colors.grey[900],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 로고 및 앱 이름
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            color: Colors.blue[800],
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.home);
                  },
                  child: const Text(
                    'BDA Studio',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (selectedWorkspace != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      selectedWorkspace.name,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // 워크스페이스 메뉴
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildMenuHeader(
                  context: context,
                  title: 'WORKSPACE',
                  onTap: () {
                    workspaceProvider.clearSelectedWorkspace();
                    experimentProvider.clearSelectedExperiment();
                    Navigator.pushNamed(context, AppRoutes.workspaceList);
                  },
                ),
                
                // 선택된 워크스페이스가 있을 때 실험 메뉴 표시
                if (selectedWorkspace != null) ...[
                  const SizedBox(height: 16),
                  _buildMenuHeader(
                    context: context,
                    title: 'EXPERIMENTS',
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
                    _buildMenuItem(
                      context: context,
                      title: 'Materials',
                      icon: Icons.science,
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
                    _buildMenuItem(
                      context: context,
                      title: 'Evaluations',
                      icon: Icons.check_circle,
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
                    _buildMenuItem(
                      context: context,
                      title: 'Assistants',
                      icon: Icons.support_agent,
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
                    _buildMenuItem(
                      context: context,
                      title: 'Chats',
                      icon: Icons.chat,
                      onTap: () {
                        // 어시스턴트가 있는지 확인
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
                          _showNoAssistantsDialog(context);
                        }
                      },
                    ),
                  ],
                ],
              ],
            ),
          ),
          
          // 하단 메뉴 (설정 등)
          Container(
            color: Colors.grey[850],
            child: Column(
              children: [
                const Divider(color: Colors.grey, height: 1),
                _buildMenuItem(
                  context: context,
                  title: 'Settings',
                  icon: Icons.settings,
                  onTap: () {
                    // 설정 페이지로 이동 (미구현)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Settings page not implemented yet')),
                    );
                  },
                ),
                _buildMenuItem(
                  context: context,
                  title: 'Help',
                  icon: Icons.help,
                  onTap: () {
                    // 도움말 페이지로 이동 (미구현)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Help page not implemented yet')),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // 어시스턴트가 없을 때 다이얼로그 표시
  void _showNoAssistantsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('No Assistants Available'),
        content: const Text(
          'You need to create an assistant first.\n\nGo to Evaluations and deploy an evaluation as an assistant.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  // 메뉴 헤더 위젯
  Widget _buildMenuHeader({
    required BuildContext context,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.blue[300],
          ),
        ),
      ),
    );
  }
  
  // 메뉴 아이템 위젯
  Widget _buildMenuItem({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: Colors.grey[400],
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[300],
              ),
            ),
          ],
        ),
      ),
    );
  }
}