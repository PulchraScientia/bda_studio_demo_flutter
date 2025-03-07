import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/routes.dart';
import '../../providers/workspace_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final workspaceProvider = Provider.of<WorkspaceProvider>(context);
    // 직접 selectedWorkspace != null을 확인하는 방식으로 변경
    final hasWorkspace = workspaceProvider.selectedWorkspace != null;
    
    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'BDA Studio',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              
              // 워크스페이스 정보를 보여주는 텍스트
              InkWell(
                onTap: hasWorkspace ? () {
                  Navigator.pushNamed(
                    context, 
                    AppRoutes.workspaceDetail,
                    arguments: {'workspaceId': workspaceProvider.selectedWorkspace!.id},
                  );
                } : null,
                child: Text(
                  'You are working in.. ${workspaceProvider.selectedWorkspace?.name ?? '{workspace_name}'}',
                  style: TextStyle(
                    fontSize: 18,
                    color: hasWorkspace ? Colors.blue : Colors.black54,
                    decoration: hasWorkspace ? TextDecoration.underline : TextDecoration.none,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // 워크스페이스 버튼
              SizedBox(
                width: 300,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.workspaceList);
                  },
                  child: Text(
                    hasWorkspace ? 'Go to Workspaces' : 'Create Workspace',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}