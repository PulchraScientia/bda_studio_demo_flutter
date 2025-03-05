import 'package:flutter/foundation.dart';
import '../models/experiment.dart';
import '../models/material.dart';
import '../models/evaluation.dart';
import '../models/assistant.dart';
import '../models/chat.dart';
class ExperimentProvider with ChangeNotifier {
  Experiment? _selectedExperiment;
  List<Experiment> _experiments = [];
  List<Material> _materials = [];
  List<Evaluation> _evaluations = [];
  List<Assistant> _assistants = [];
  List<Chat> _chats = [];
  bool _isLoading = false;
  Experiment? get selectedExperiment => _selectedExperiment;
  List<Experiment> get experiments => _experiments;
  List<Material> get materials => _materials;
  List<Evaluation> get evaluations => _evaluations;
  List<Assistant> get assistants => _assistants;
  List<Chat> get chats => _chats;
  bool get isLoading => _isLoading;
  // 목업 데이터로 초기화
  ExperimentProvider() {
    _initMockData();
  }
  void _initMockData() {
    // 목업 실험 데이터 생성
    _experiments = [
      Experiment(
        id: 'exp1',
        workspaceId: 'ws1',
        name: 'First SQL Experiment',
        description: 'Testing SQL generation with basic queries',
        dataset: Dataset(
          id: 'ds1',
          name: 'e-commerce_data',
          tables: ['customers', 'orders', 'products'],
          isOutOfSync: false,
        ),
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Experiment(
        id: 'exp2',
        workspaceId: 'ws1',
        name: 'Advanced Joins',
        description: 'Testing complex join operations',
        dataset: Dataset(
          id: 'ds2',
          name: 'hr_data',
          tables: ['employees', 'departments', 'salaries'],
          isOutOfSync: true,  // 데이터셋이 변경됨
        ),
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
    // 재료(Materials) 목업 데이터
    _materials = [
      Material(
        id: 'mat1',
        experimentId: 'exp1',
        trainSet: [
          MaterialItem(
            id: 'train1',
            type: 'train',
            naturalLanguage: 'Find all customers who made a purchase in the last month',
            sql: 'SELECT * FROM customers WHERE customer_id IN (SELECT customer_id FROM orders WHERE order_date > DATE_SUB(NOW(), INTERVAL 1 MONTH))',
          ),
          MaterialItem(
            id: 'train2',
            type: 'train',
            naturalLanguage: 'List products with inventory less than 10',
            sql: 'SELECT * FROM products WHERE inventory < 10',
          ),
        ],
        testSet: [
          MaterialItem(
            id: 'test1',
            type: 'test',
            naturalLanguage: 'Show customers who bought more than 5 products',
            sql: 'SELECT c.* FROM customers c JOIN orders o ON c.customer_id = o.customer_id GROUP BY c.customer_id HAVING COUNT(o.order_id) > 5',
          ),
        ],
        knowledgeSet: [
          MaterialItem(
            id: 'know1',
            type: 'knowledge',
            naturalLanguage: 'Database schema information',
            sql: 'CREATE TABLE customers (customer_id INT, name VARCHAR(255), email VARCHAR(255));\nCREATE TABLE orders (order_id INT, customer_id INT, order_date DATETIME);\nCREATE TABLE products (product_id INT, name VARCHAR(255), price DECIMAL, inventory INT);',
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
      Material(
        id: 'mat2',
        experimentId: 'exp2',
        trainSet: [
          MaterialItem(
            id: 'train3',
            type: 'train',
            naturalLanguage: 'Find employees with salary higher than department average',
            sql: 'SELECT e.* FROM employees e JOIN departments d ON e.department_id = d.id JOIN salaries s ON e.id = s.employee_id WHERE s.amount > (SELECT AVG(s2.amount) FROM salaries s2 JOIN employees e2 ON s2.employee_id = e2.id WHERE e2.department_id = e.department_id)',
          ),
        ],
        testSet: [
          MaterialItem(
            id: 'test2',
            type: 'test',
            naturalLanguage: 'List departments sorted by average employee salary',
            sql: 'SELECT d.name, AVG(s.amount) as avg_salary FROM departments d JOIN employees e ON d.id = e.department_id JOIN salaries s ON e.id = s.employee_id GROUP BY d.id ORDER BY avg_salary DESC',
          ),
        ],
        knowledgeSet: [
          MaterialItem(
            id: 'know2',
            type: 'knowledge',
            naturalLanguage: 'HR database schema',
            sql: 'CREATE TABLE employees (id INT, name VARCHAR(255), department_id INT);\nCREATE TABLE departments (id INT, name VARCHAR(255));\nCREATE TABLE salaries (id INT, employee_id INT, amount DECIMAL, effective_date DATE);',
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
    // 평가(Evaluations) 목업 데이터
    _evaluations = [
      Evaluation(
        id: 'eval1',
        experimentId: 'exp1',
        materialId: 'mat1',
        accuracy: 85.5,
        results: [
          EvaluationResult(
            id: 'res1',
            testItemId: 'test1',
            expectedSql: 'SELECT c.* FROM customers c JOIN orders o ON c.customer_id = o.customer_id GROUP BY c.customer_id HAVING COUNT(o.order_id) > 5',
            generatedSql: 'SELECT c. FROM customers c JOIN orders o ON c.customer_id = o.customer_id GROUP BY c.customer_id HAVING COUNT() > 5',
            isCorrect: false,
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Evaluation(
        id: 'eval2',
        experimentId: 'exp2',
        materialId: 'mat2',
        accuracy: 92.0,
        results: [
          EvaluationResult(
            id: 'res2',
            testItemId: 'test2',
            expectedSql: 'SELECT d.name, AVG(s.amount) as avg_salary FROM departments d JOIN employees e ON d.id = e.department_id JOIN salaries s ON e.id = s.employee_id GROUP BY d.id ORDER BY avg_salary DESC',
            generatedSql: 'SELECT d.name, AVG(s.amount) as avg_salary FROM departments d JOIN employees e ON d.id = e.department_id JOIN salaries s ON e.id = s.employee_id GROUP BY d.id ORDER BY avg_salary DESC',
            isCorrect: true,
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
    // 어시스턴트(Assistants) 목업 데이터
    _assistants = [
      Assistant(
        id: 'assist1',
        name: 'SQL Helper v1',
        experimentId: 'exp1',
        evaluationId: 'eval1',
        version: 1,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Assistant(
        id: 'assist2',
        name: 'Advanced SQL Helper',
        experimentId: 'exp2',
        evaluationId: 'eval2',
        version: 1,
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
    ];
    // 채팅(Chats) 목업 데이터
    _chats = [
      Chat(
        id: 'chat1',
        assistantId: 'assist1',
        experimentId: 'exp1',
        name: 'First conversation',
        messages: [
          ChatMessage(
            id: 'msg1',
            isUser: true,
            content: 'How do I find customers who made multiple purchases?',
            timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          ),
          ChatMessage(
            id: 'msg2',
            isUser: false,
            content: 'You can use a query like this:\n\n```sql\nSELECT c.* \nFROM customers c \nJOIN orders o ON c.customer_id = o.customer_id \nGROUP BY c.customer_id \nHAVING COUNT(o.order_id) > 1\n```\n\nThis will return all customers who have placed more than one order.',
            timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ];
  }
  void selectExperiment(String experimentId) {
    _selectedExperiment = _experiments.firstWhere((exp) => exp.id == experimentId);
    notifyListeners();
  }
  List<Experiment> getExperimentsForWorkspace(String workspaceId) {
    return _experiments.where((exp) => exp.workspaceId == workspaceId).toList();
  }
  List<Material> getMaterialsForExperiment(String experimentId) {
    return _materials.where((mat) => mat.experimentId == experimentId).toList();
  }
  List<Evaluation> getEvaluationsForExperiment(String experimentId) {
    return _evaluations.where((eval) => eval.experimentId == experimentId).toList();
  }
  List<Assistant> getAssistantsForExperiment(String experimentId) {
    return _assistants.where((assist) => assist.experimentId == experimentId).toList();
  }
  List<Chat> getChatsForAssistant(String assistantId) {
    return _chats.where((chat) => chat.assistantId == assistantId).toList();
  }

Future<void> createExperiment(String workspaceId, String name, String description, Dataset dataset) async {
    _isLoading = true;
    notifyListeners();
    try {
      // 실제 구현에서는 API 호출을 통해 실험 생성
      await Future.delayed(const Duration(seconds: 1)); // API 호출 시뮬레이션
      final newExperiment = Experiment(
        id: 'exp${_experiments.length + 1}',
        workspaceId: workspaceId,
        name: name,
        description: description,
        dataset: dataset,
        createdAt: DateTime.now(),
      );
      _experiments.add(newExperiment);
      _selectedExperiment = newExperiment;
    } catch (e) {
      // 오류 처리
      debugPrint('Error creating experiment: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<void> createMaterial(String experimentId, List<MaterialItem> trainSet, List<MaterialItem> testSet, List<MaterialItem> knowledgeSet) async {
    _isLoading = true;
    notifyListeners();
    try {
      // 실제 구현에서는 API 호출을 통해 머티리얼 생성
      await Future.delayed(const Duration(seconds: 1)); // API 호출 시뮬레이션
      final newMaterial = Material(
        id: 'mat${_materials.length + 1}',
        experimentId: experimentId,
        trainSet: trainSet,
        testSet: testSet,
        knowledgeSet: knowledgeSet,
        createdAt: DateTime.now(),
      );
      _materials.add(newMaterial);
    } catch (e) {
      // 오류 처리
      debugPrint('Error creating material: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<void> createEvaluation(String experimentId, String materialId) async {
    _isLoading = true;
    notifyListeners();
    try {
      // 실제 구현에서는 API 호출을 통해 평가 실행
      await Future.delayed(const Duration(seconds: 2)); // 평가 실행 시뮬레이션
      // 평가 결과 예시를 무작위로 생성
      final material = _materials.firstWhere((m) => m.id == materialId);
      final results = <EvaluationResult>[];
      double correctCount = 0;
      for (var testItem in material.testSet) {
        final isCorrect = DateTime.now().millisecond % 2 == 0; // 무작위 정확도
        if (isCorrect) correctCount++;
        results.add(EvaluationResult(
          id: 'res${DateTime.now().millisecondsSinceEpoch}',
          testItemId: testItem.id,
          expectedSql: testItem.sql,
          generatedSql: isCorrect
              ? testItem.sql
              : testItem.sql.replaceAll('ORDER BY', 'ORDER BY /* modified */'),
          isCorrect: isCorrect,
        ));
      }
      final accuracy = material.testSet.isEmpty ?
          0.0 : (correctCount / material.testSet.length) * 100;
      final newEvaluation = Evaluation(
        id: 'eval${_evaluations.length + 1}',
        experimentId: experimentId,
        materialId: materialId,
        accuracy: accuracy,
        results: results,
        createdAt: DateTime.now(),
      );
      _evaluations.add(newEvaluation);
    } catch (e) {
      // 오류 처리
      debugPrint('Error creating evaluation: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<void> deployAssistant(String experimentId, String evaluationId, String name) async {
    _isLoading = true;
    notifyListeners();
    try {
      // 실제 구현에서는 API 호출을 통해 어시스턴트 배포
      await Future.delayed(const Duration(seconds: 1)); // API 호출 시뮬레이션
      // 동일한 이름의 어시스턴트가 있는지 확인
      final existingAssistant = _assistants.where((a) =>
          a.name == name && a.experimentId == experimentId).toList();
      int version = 1;
      if (existingAssistant.isNotEmpty) {
        // 버전 업그레이드
        version = existingAssistant.map((a) => a.version).reduce(
            (a, b) => a > b ? a : b) + 1;
      }
      final newAssistant = Assistant(
        id: 'assist${_assistants.length + 1}',
        name: name,
        experimentId: experimentId,
        evaluationId: evaluationId,
        version: version,
        createdAt: DateTime.now(),
      );
      _assistants.add(newAssistant);
    } catch (e) {
      // 오류 처리
      debugPrint('Error deploying assistant: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<void> createChat(String assistantId, String experimentId, String initialMessage) async {
    _isLoading = true;
    notifyListeners();
    try {
      // 실제 구현에서는 API 호출을 통해 채팅 생성
      await Future.delayed(const Duration(seconds: 1)); // API 호출 시뮬레이션
      final newChat = Chat(
        id: 'chat${_chats.length + 1}',
        assistantId: assistantId,
        experimentId: experimentId,
        name: 'Chat ${_chats.length + 1}',
        messages: [
          ChatMessage(
            id: 'msg${DateTime.now().millisecondsSinceEpoch}',
            isUser: true,
            content: initialMessage,
            timestamp: DateTime.now(),
          )
        ],
        createdAt: DateTime.now(),
      );
      _chats.add(newChat);
    } catch (e) {
      // 오류 처리
      debugPrint('Error creating chat: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<void> sendMessage(String chatId, String content) async {
    _isLoading = true;
    notifyListeners();
    try {
      // 실제 구현에서는 API 호출을 통해 메시지 전송
      await Future.delayed(const Duration(seconds: 1)); // API 호출 시뮬레이션
      final index = _chats.indexWhere((c) => c.id == chatId);
      if (index != -1) {
        final chat = _chats[index];
        // 사용자 메시지 추가
        final userMessage = ChatMessage(
          id: 'msg${DateTime.now().millisecondsSinceEpoch}',
          isUser: true,
          content: content,
          timestamp: DateTime.now(),
        );
        // 모의 AI 응답 생성
        await Future.delayed(const Duration(seconds: 1)); // 응답 생성 시뮬레이션
        final aiMessage = ChatMessage(
          id: 'msg${DateTime.now().millisecondsSinceEpoch + 1}',
          isUser: false,
          content: 'This is a mock response to "$content". In a real implementation, this would be generated by the AI assistant.',
          timestamp: DateTime.now().add(const Duration(seconds: 1)),
        );
        final updatedMessages = [...chat.messages, userMessage, aiMessage];
        _chats[index] = Chat(
          id: chat.id,
          assistantId: chat.assistantId,
          experimentId: chat.experimentId,
          name: chat.name,
          messages: updatedMessages,
          createdAt: chat.createdAt,
        );
      }
    } catch (e) {
      // 오류 처리
      debugPrint('Error sending message: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  void clearSelectedExperiment() {
    _selectedExperiment = null;
    notifyListeners();
  }
}






