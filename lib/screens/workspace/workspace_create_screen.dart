import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/routes.dart';
import '../../providers/workspace_provider.dart';
import '../../widgets/sidebar_menu.dart';

class WorkspaceCreateScreen extends StatefulWidget {
  const WorkspaceCreateScreen({super.key});

  @override
  State<WorkspaceCreateScreen> createState() => _WorkspaceCreateScreenState();
}

class _WorkspaceCreateScreenState extends State<WorkspaceCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _membersController = TextEditingController();

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
                        child: InkWell(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.workspaceList,
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
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 600),
                          padding: const EdgeInsets.all(24),
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
                                        hintText:
                                            'Enter member emails (comma separated)',
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
                                    onPressed:
                                        workspaceProvider.isLoading
                                            ? null
                                            : () async {
                                              if (_formKey.currentState!
                                                  .validate()) {
                                                // 멤버 이메일 분리
                                                final List<String> members =
                                                    _membersController.text
                                                        .split(',')
                                                        .map((e) => e.trim())
                                                        .where(
                                                          (e) => e.isNotEmpty,
                                                        )
                                                        .toList();

                                                await workspaceProvider
                                                    .createWorkspace(
                                                      _nameController.text,
                                                      _descriptionController
                                                          .text,
                                                      members,
                                                    );

                                                if (!mounted) return;
                                                Navigator.pushNamed(
                                                  context,
                                                  AppRoutes.workspaceDetail,
                                                  arguments: {
                                                    'workspaceId':
                                                        workspaceProvider
                                                            .selectedWorkspace!
                                                            .id,
                                                  },
                                                );
                                              }
                                            },
                                    child:
                                        workspaceProvider.isLoading
                                            ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                            : const Text('Create'),
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
