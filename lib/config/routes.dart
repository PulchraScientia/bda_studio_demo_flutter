import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart';
import '../screens/workspace/workspace_list_screen.dart';
import '../screens/workspace/workspace_create_screen.dart';
import '../screens/workspace/workspace_detail_screen.dart';
import '../screens/experiments/experiment_list_screen.dart';
import '../screens/experiments/experiment_create_screen.dart';
import '../screens/experiments/experiment_detail_screen.dart';
// 수정된 파일 경로
import '../screens/materials/material_screen.dart';
import '../screens/evaluations/evaluation_list_screen.dart';
import '../screens/evaluations/evaluation_detail_screen.dart';
import '../screens/assistants/assistant_list_screen.dart';
// 채팅 화면 파일 경로 수정
import '../screens/chats/chat_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String workspaceList = '/workspaces';
  static const String workspaceCreate = '/workspaces/create';
  static const String workspaceDetail = '/workspaces/detail';
  static const String experimentList = '/experiments';
  static const String experimentCreate = '/experiments/create';
  static const String experimentDetail = '/experiments/detail';
  static const String materialList = '/materials';
  static const String evaluationList = '/evaluations';
  static const String evaluationDetail = '/evaluations/detail';
  static const String assistantList = '/assistants';
  static const String chatList = '/chats';
  static const String chatDetail = '/chats/detail';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case workspaceList:
        return MaterialPageRoute(builder: (_) => const WorkspaceListScreen());
      case workspaceCreate:
        return MaterialPageRoute(builder: (_) => const WorkspaceCreateScreen());
      case workspaceDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => WorkspaceDetailScreen(workspaceId: args?['workspaceId']),
        );
      case experimentList:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ExperimentListScreen(workspaceId: args?['workspaceId']),
        );
      case experimentCreate:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ExperimentCreateScreen(workspaceId: args?['workspaceId']),
        );
      case experimentDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ExperimentDetailScreen(
            workspaceId: args?['workspaceId'],
            experimentId: args?['experimentId'],
          ),
        );
      case materialList:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => MaterialScreen(
            workspaceId: args?['workspaceId'],
            experimentId: args?['experimentId'],
          ),
        );
      case evaluationList:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => EvaluationListScreen(
            workspaceId: args?['workspaceId'],
            experimentId: args?['experimentId'],
          ),
        );
      case evaluationDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => EvaluationDetailScreen(
            workspaceId: args?['workspaceId'],
            experimentId: args?['experimentId'],
            evaluationId: args?['evaluationId'],
          ),
        );
      case assistantList:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => AssistantListScreen(
            workspaceId: args?['workspaceId'],
            experimentId: args?['experimentId'],
          ),
        );
      case chatList:
      case chatDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ChatScreen(
            workspaceId: args?['workspaceId'],
            experimentId: args?['experimentId'],
            assistantId: args?['assistantId'],
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}