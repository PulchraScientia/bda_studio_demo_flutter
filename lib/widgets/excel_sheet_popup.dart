// lib/widgets/excel_sheet_popup.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ExcelSheetPopup extends StatefulWidget {
  final String title;
  final List<String> headers;
  final List<List<String>> initialData;
  final Function(List<List<String>>) onSave;

  const ExcelSheetPopup({
    Key? key,
    required this.title,
    required this.headers,
    required this.initialData,
    required this.onSave,
  }) : super(key: key);

  @override
  State<ExcelSheetPopup> createState() => _ExcelSheetPopupState();
}

class _ExcelSheetPopupState extends State<ExcelSheetPopup> {
  late List<List<String>> _data;
  final FocusNode _tableFocusNode = FocusNode();
  
  // 최소 행 수
  final int _minRows = 5;

  @override
  void initState() {
    super.initState();
    // 초기 데이터 설정 또는 빈 데이터로 시작
    _data = List.from(widget.initialData);
    
    // 최소 행 수를 맞추기 위해 필요한 경우 빈 행 추가
    while (_data.length < _minRows) {
      _data.add(List.filled(widget.headers.length, ''));
    }
  }

  @override
  void dispose() {
    _tableFocusNode.dispose();
    super.dispose();
  }

  // 클립보드의 텍스트 데이터를 2차원 배열로 변환
  List<List<String>> _parseClipboardData(String data) {
    // 줄 단위로 분할
    final rows = data.split('\n');
    
    // 각 줄을 탭으로 분할하여 셀 데이터 생성
    return rows
        .where((row) => row.trim().isNotEmpty)
        .map((row) => row.split('\t'))
        .toList();
  }

  // 클립보드에서 데이터 붙여넣기
  Future<void> _pasteFromClipboard(int startRow, int startCol) async {
    // 클립보드 데이터 가져오기
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData == null || clipboardData.text == null) return;

    final pastedData = _parseClipboardData(clipboardData.text!);
    if (pastedData.isEmpty) return;

    setState(() {
      // 데이터 붙여넣기
      for (int i = 0; i < pastedData.length; i++) {
        final rowIndex = startRow + i;
        
        // 필요한 경우 행 추가
        while (rowIndex >= _data.length) {
          _data.add(List.filled(widget.headers.length, ''));
        }
        
        // 열 데이터 복사
        for (int j = 0; j < pastedData[i].length && j + startCol < widget.headers.length; j++) {
          _data[rowIndex][j + startCol] = pastedData[i][j];
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 제목
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            // 안내 메시지
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.grey[200],
              width: double.infinity,
              child: const Text(
                '엑셀에서 데이터를 복사하여(Ctrl+C) 아래 테이블에 붙여넣기(Ctrl+V)할 수 있습니다.',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            
            // 테이블 헤더
            Row(
              children: [
                // 인덱스 열
                Container(
                  width: 60,
                  height: 40,
                  padding: const EdgeInsets.all(8),
                  color: Colors.grey[400],
                  alignment: Alignment.center,
                  child: const Text(
                    'index',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                
                // 헤더 열
                ...widget.headers.map((header) => Expanded(
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.all(8),
                    color: Colors.grey[400],
                    alignment: Alignment.center,
                    child: Text(
                      header,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                )),
              ],
            ),
            
            // 테이블 데이터
            Expanded(
              child: SingleChildScrollView(
                child: Focus(
                  focusNode: _tableFocusNode,
                  onKeyEvent: (node, event) {
                    // 키보드 이벤트 처리 로직 (Ctrl+V 처리 부분 수정)
                    if (event is KeyDownEvent &&
                        event.logicalKey == LogicalKeyboardKey.keyV &&
                        HardwareKeyboard.instance.isControlPressed) {
                      // 0, 0 위치에 붙여넣기 (실제로는 선택된 셀 위치를 사용해야 함)
                      _pasteFromClipboard(0, 0);
                      return KeyEventResult.handled;
                    }
                    return KeyEventResult.ignored;
                  },
                  child: Column(
                    children: List.generate(
                      _data.length,
                      (rowIndex) => _buildDataRow(rowIndex),
                    ),
                  ),
                ),
              ),
            ),
            
            // 액션 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    // 빈 행 제거한 데이터 전달
                    final cleanedData = _data
                        .where((row) => row.any((cell) => cell.isNotEmpty))
                        .toList();
                    widget.onSave(cleanedData);
                    Navigator.pop(context);
                  },
                  child: const Text('save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(int rowIndex) {
    // 행이 홀수 인덱스인 경우 배경색 다르게 설정
    final backgroundColor = rowIndex % 2 == 0 ? Colors.grey[200] : Colors.white;
    
    return Row(
      children: [
        // 인덱스 열
        Container(
          width: 60,
          height: 40,
          padding: const EdgeInsets.all(8),
          color: backgroundColor,
          alignment: Alignment.center,
          child: Text('${rowIndex + 1}'),
        ),
        
        // 데이터 열
        ...List.generate(
          widget.headers.length,
          (colIndex) => Expanded(
            child: InkWell(
              onTap: () {
                // 셀 클릭 시 포커스 이동
                _showEditDialog(rowIndex, colIndex);
              },
              onSecondaryTap: () {
                // 우클릭 시 붙여넣기 컨텍스트 메뉴 표시
                _showContextMenu(context, rowIndex, colIndex);
              },
              child: Container(
                height: 40,
                padding: const EdgeInsets.all(8),
                color: backgroundColor,
                alignment: Alignment.centerLeft,
                child: Text(
                  rowIndex < _data.length && colIndex < _data[rowIndex].length
                      ? _data[rowIndex][colIndex]
                      : '',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showEditDialog(int rowIndex, int colIndex) {
    if (rowIndex >= _data.length) {
      while (rowIndex >= _data.length) {
        _data.add(List.filled(widget.headers.length, ''));
      }
    }
    
    if (colIndex >= _data[rowIndex].length) {
      while (colIndex >= _data[rowIndex].length) {
        _data[rowIndex].add('');
      }
    }

    final controller = TextEditingController(text: _data[rowIndex][colIndex]);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${widget.headers[colIndex]}'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter ${widget.headers[colIndex]}',
          ),
          onSubmitted: (value) {
            setState(() {
              _data[rowIndex][colIndex] = value;
            });
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _data[rowIndex][colIndex] = controller.text;
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showContextMenu(BuildContext context, int rowIndex, int colIndex) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu(
      context: context,
      position: position,
      items: [
        PopupMenuItem(
          value: 'paste',
          child: const Text('붙여넣기'),
          onTap: () {
            // 메뉴가 닫힌 후 붙여넣기 실행
            Future.delayed(const Duration(milliseconds: 100), () {
              _pasteFromClipboard(rowIndex, colIndex);
            });
          },
        ),
      ],
    );
  }
}