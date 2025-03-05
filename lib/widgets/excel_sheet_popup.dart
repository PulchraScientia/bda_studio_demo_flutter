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
  
  // 현재 선택된 셀 위치
  int _selectedRow = 0;
  int _selectedCol = 0;
  
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
    
    // 클립보드 이벤트를 감지하기 위한 포커스 요청
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tableFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _tableFocusNode.dispose();
    super.dispose();
  }

  // 클립보드의 텍스트 데이터를 2차원 배열로 변환
  List<List<String>> _parseClipboardData(String data) {
    // 줄 단위로 분할
    final rows = data.split(RegExp(r'\r\n|\r|\n'));
    
    // 각 줄을 탭으로 분할하여 셀 데이터 생성
    return rows
        .where((row) => row.trim().isNotEmpty)
        .map((row) => row.split('\t'))
        .toList();
  }

  // 클립보드에서 데이터 붙여넣기
  Future<void> _pasteFromClipboard(int startRow, int startCol) async {
    try {
      // 클립보드 데이터 가져오기
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData == null || clipboardData.text == null) {
        _showSnackBar('No data in clipboard');
        return;
      }

      final pastedData = _parseClipboardData(clipboardData.text!);
      if (pastedData.isEmpty) {
        _showSnackBar('No valid data to paste');
        return;
      }

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
      
      _showSnackBar('Data pasted successfully');
    } catch (e) {
      _showSnackBar('Error pasting data: $e');
    }
  }
  
  // 현재 데이터를 클립보드에 복사
  Future<void> _copyToClipboard(int startRow, int startCol, int endRow, int endCol) async {
    try {
      // 범위 조정
      endRow = endRow.clamp(0, _data.length - 1);
      endCol = endCol.clamp(0, widget.headers.length - 1);
      
      final StringBuffer buffer = StringBuffer();
      
      for (int i = startRow; i <= endRow; i++) {
        for (int j = startCol; j <= endCol; j++) {
          buffer.write(_data[i][j]);
          if (j < endCol) buffer.write('\t');
        }
        if (i < endRow) buffer.write('\n');
      }
      
      await Clipboard.setData(ClipboardData(text: buffer.toString()));
      _showSnackBar('Data copied to clipboard');
    } catch (e) {
      _showSnackBar('Error copying data: $e');
    }
  }
  
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
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
              padding: const EdgeInsets.all(12),
              color: Colors.blue.withOpacity(0.1),
              width: double.infinity,
              child: Column(
                children: const [
                  Text(
                    '엑셀에서 데이터를 복사하여(Ctrl+C) 아래 테이블에 붙여넣기(Ctrl+V)할 수 있습니다.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '셀을 클릭하여 직접 편집하거나, 셀을 우클릭하여 메뉴를 사용할 수 있습니다.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                ],
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
                  color: Colors.grey[700],
                  alignment: Alignment.center,
                  child: const Text(
                    'index',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                
                // 헤더 열
                ...widget.headers.map((header) => Expanded(
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.all(8),
                    color: Colors.grey[700],
                    alignment: Alignment.center,
                    child: Text(
                      header,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
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
                    // 키보드 이벤트 처리 로직
                    if (event is KeyDownEvent) {
                      // Ctrl+V 처리
                      if (event.logicalKey == LogicalKeyboardKey.keyV &&
                          HardwareKeyboard.instance.isControlPressed) {
                        _pasteFromClipboard(_selectedRow, _selectedCol);
                        return KeyEventResult.handled;
                      }
                      
                      // Ctrl+C 처리
                      if (event.logicalKey == LogicalKeyboardKey.keyC &&
                          HardwareKeyboard.instance.isControlPressed) {
                        _copyToClipboard(_selectedRow, _selectedCol, _selectedRow, _selectedCol);
                        return KeyEventResult.handled;
                      }
                      
                      // 화살표 키 처리
                      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                        setState(() {
                          _selectedRow = (_selectedRow - 1).clamp(0, _data.length - 1);
                        });
                        return KeyEventResult.handled;
                      }
                      
                      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                        setState(() {
                          _selectedRow = (_selectedRow + 1).clamp(0, _data.length - 1);
                          // 필요한 경우 새 행 추가
                          if (_selectedRow >= _data.length - 1) {
                            _data.add(List.filled(widget.headers.length, ''));
                          }
                        });
                        return KeyEventResult.handled;
                      }
                      
                      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                        setState(() {
                          _selectedCol = (_selectedCol - 1).clamp(0, widget.headers.length - 1);
                        });
                        return KeyEventResult.handled;
                      }
                      
                      if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
                        setState(() {
                          _selectedCol = (_selectedCol + 1).clamp(0, widget.headers.length - 1);
                        });
                        return KeyEventResult.handled;
                      }
                      
                      // Enter 키 처리
                      if (event.logicalKey == LogicalKeyboardKey.enter) {
                        _showEditDialog(_selectedRow, _selectedCol);
                        return KeyEventResult.handled;
                      }
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
            
            // 액션 버튼들
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // 행 추가 버튼
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _data.add(List.filled(widget.headers.length, ''));
                      _selectedRow = _data.length - 1;
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('행 추가'),
                ),
                const SizedBox(width: 8),
                
                // 취소 버튼
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                
                // 저장 버튼
                ElevatedButton(
                  onPressed: () {
                    // 빈 행 제거한 데이터 전달
                    final cleanedData = _data
                        .where((row) => row.any((cell) => cell.isNotEmpty))
                        .toList();
                    widget.onSave(cleanedData);
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
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
    final backgroundColor = rowIndex % 2 == 0 ? Colors.grey[100] : Colors.white;
    
    return Row(
      children: [
        // 인덱스 열
        Container(
          width: 60,
          height: 40,
          padding: const EdgeInsets.all(8),
          color: Colors.grey[300],
          alignment: Alignment.center,
          child: Text('${rowIndex + 1}'),
        ),
        
        // 데이터 열
        ...List.generate(
          widget.headers.length,
          (colIndex) => Expanded(
            child: InkWell(
              onTap: () {
                // 셀 클릭 시 포커스 이동 및 셀 선택
                setState(() {
                  _selectedRow = rowIndex;
                  _selectedCol = colIndex;
                });
                _showEditDialog(rowIndex, colIndex);
              },
              onSecondaryTap: () {
                // 우클릭 시 컨텍스트 메뉴 표시
                setState(() {
                  _selectedRow = rowIndex;
                  _selectedCol = colIndex;
                });
                _showContextMenu(context, rowIndex, colIndex);
              },
              child: Container(
                height: 40,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _selectedRow == rowIndex && _selectedCol == colIndex
                      ? Colors.blue.withOpacity(0.2)
                      : backgroundColor,
                  border: _selectedRow == rowIndex && _selectedCol == colIndex
                      ? Border.all(color: Colors.blue, width: 2)
                      : null,
                ),
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
    // 데이터 행이 부족한 경우 추가
    while (rowIndex >= _data.length) {
      _data.add(List.filled(widget.headers.length, ''));
    }
    
    // 데이터 열이 부족한 경우 추가
    while (colIndex >= _data[rowIndex].length) {
      _data[rowIndex].add('');
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
            border: const OutlineInputBorder(),
          ),
          maxLines: 5,  // 여러 줄 입력 가능하도록 수정
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
          value: 'copy',
          child: const Text('복사'),
          onTap: () {
            // 메뉴가 닫힌 후 복사 실행
            Future.delayed(const Duration(milliseconds: 100), () {
              _copyToClipboard(rowIndex, colIndex, rowIndex, colIndex);
            });
          },
        ),
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
        PopupMenuItem(
          value: 'edit',
          child: const Text('편집'),
          onTap: () {
            // 메뉴가 닫힌 후 편집 다이얼로그 표시
            Future.delayed(const Duration(milliseconds: 100), () {
              _showEditDialog(rowIndex, colIndex);
            });
          },
        ),
        PopupMenuItem(
          value: 'insert_row',
          child: const Text('행 삽입'),
          onTap: () {
            // 메뉴가 닫힌 후 행 삽입
            Future.delayed(const Duration(milliseconds: 100), () {
              setState(() {
                _data.insert(rowIndex, List.filled(widget.headers.length, ''));
              });
            });
          },
        ),
        PopupMenuItem(
          value: 'delete_row',
          child: const Text('행 삭제'),
          onTap: () {
            // 메뉴가 닫힌 후 행 삭제
            Future.delayed(const Duration(milliseconds: 100), () {
              if (_data.length > 1) {  // 최소 한 행은 유지
                setState(() {
                  _data.removeAt(rowIndex);
                  _selectedRow = (_selectedRow - 1).clamp(0, _data.length - 1);
                });
              } else {
                _showSnackBar('마지막 행은 삭제할 수 없습니다');
              }
            });
          },
        ),
      ],
    );
  }
}