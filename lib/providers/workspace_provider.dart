import 'package:flutter/foundation.dart';
import '../models/workspace.dart';

class WorkspaceProvider with ChangeNotifier {
  Workspace? _selectedWorkspace;
  List<Workspace> _workspaces = [];
  bool _isLoading = false;
  Workspace? get selectedWorkspace => _selectedWorkspace;
  List<Workspace> get workspaces => _workspaces;
  bool get isLoading => _isLoading;
  // 목업 데이터로 초기화
  WorkspaceProvider() {
    _initMockData();
  }
  void _initMockData() {
    _workspaces = [
      Workspace(
        id: 'ws1',
        name: 'Workspace A',
        description: 'First workspace for testing',
        members: ['user1@example.com', 'user2@example.com'],
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      Workspace(
        id: 'ws2',
        name: 'Workspace B',
        description: 'Second workspace for testing',
        members: ['user1@example.com'],
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Workspace(
        id: 'ws3',
        name: 'Workspace C',
        description: 'Third workspace for testing',
        members: ['user1@example.com', 'user3@example.com'],
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }
  void selectWorkspace(String workspaceId) {
    _selectedWorkspace = _workspaces.firstWhere((ws) => ws.id == workspaceId);
    notifyListeners();
  }
  Future<void> createWorkspace(String name, String description, List<String> members) async {
    _isLoading = true;
    notifyListeners();
    try {
      // 실제 구현에서는 API 호출을 통해 워크스페이스 생성
      await Future.delayed(const Duration(seconds: 1)); // API 호출 시뮬레이션
      final newWorkspace = Workspace(
        id: 'ws${_workspaces.length + 1}',
        name: name,
        description: description,
        members: members,
        createdAt: DateTime.now(),
      );
      _workspaces.add(newWorkspace);
      _selectedWorkspace = newWorkspace;
    } catch (e) {
      // 오류 처리
      debugPrint('Error creating workspace: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<void> updateWorkspace(String id, String name, String description, List<String> members) async {
    _isLoading = true;
    notifyListeners();
    try {
      // 실제 구현에서는 API 호출을 통해 워크스페이스 업데이트
      await Future.delayed(const Duration(seconds: 1)); // API 호출 시뮬레이션
      final index = _workspaces.indexWhere((ws) => ws.id == id);
      if (index != -1) {
        final updatedWorkspace = Workspace(
          id: id,
          name: name,
          description: description,
          members: members,
          createdAt: _workspaces[index].createdAt,
        );
        _workspaces[index] = updatedWorkspace;
        if (_selectedWorkspace?.id == id) {
          _selectedWorkspace = updatedWorkspace;
        }
      }
    } catch (e) {
      // 오류 처리
      debugPrint('Error updating workspace: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  void clearSelectedWorkspace() {
    _selectedWorkspace = null;
    notifyListeners();
  }
}