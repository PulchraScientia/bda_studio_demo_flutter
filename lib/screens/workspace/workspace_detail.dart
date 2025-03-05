import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/routes.dart';
import '../../providers/workspace_provider.dart';
import '../../widgets/sidebar_menu.dart';

class WorkspaceDetailScreen extends StatefulWidget {
  final String? workspaceId;
  
  const WorkspaceDetailScreen({Key? key, this.workspaceId}) : super(key: key);

  @override
  State<WorkspaceDetailScreen> createState() => _WorkspaceDetailScreenState();
}

class _WorkspaceDetailScreenState extends State<WorkspaceDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _membersController;
  
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _membersController = TextEditingController();
    
    // 데이터 초기화는 didChangeDependencies에서 수행
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final workspaceProvider = Provider.of<WorkspaceProvider>(context, listen: false);
    final workspace = workspaceProvider.workspaces.firstWhere(
      (ws) => ws.id == widget.workspaceId,
      orElse: () => workspaceProvider.selectedWorkspace!,
    );
    
    _nameController.text = workspace.name;
    _descriptionController.text = workspace.description;
    _membersController.text = workspace.members.join(', ');
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _membersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workspaceProvider = Provider.of<WorkspaceProvider>(context);
    final workspace = workspaceProvider.workspaces.firstWhere(
      (ws) => ws.id == widget.workspaceId,
      orElse: () => workspaceProvider.selectedWorkspace!,
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
                          Navigator.pushNamed(context, AppRoutes.workspaceList);
                        },
                        child: const Row(
                          children: [
                            Icon(Icons.arrow_back),
                            SizedBox(width: 8),
                            Text('workspace list')
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // 워크스페이스 제목
                  Text(
                    workspace.name,
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
                          constraints: const BoxConstraints(maxWidth: 600),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'workspace_name',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  hintText: 'Enter workspace name',
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a workspace name';
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
                                  hintText: 'Enter workspace description',
                                ),
                                maxLines: 3,
                              ),
                              const SizedBox(height: 24),
                              
                              const Text(
                                'members',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _membersController,
                                      decoration: const InputDecoration(
                                        hintText: 'Enter member emails (comma separated)',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    color: Colors.grey[200],
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    child: const Text('add'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                              
                              Center(
                                child: SizedBox(
                                  width: 200,
                                  child: ElevatedButton(
                                    onPressed: workspaceProvider.isLoading
                                        ? null
                                        : () async {
                                            if (_formKey.currentState!.validate()) {
                                              // 멤버 이메일 분리
                                              final List<String> members = _membersController.text
                                                  .split(',')
                                                  .map((e) => e.trim())
                                                  .where((e) => e.isNotEmpty)
                                                  .toList();
                                              
                                              await workspaceProvider.updateWorkspace(
                                                workspace.id,
                                                _nameController.text,
                                                _descriptionController.text,
                                                members,
                                              );
                                              
                                              if (!mounted) return;
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('Workspace updated successfully')),
                                              );
                                            }
                                          },
                                    child: workspaceProvider.isLoading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Text('Update'),
                                  ),
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
}