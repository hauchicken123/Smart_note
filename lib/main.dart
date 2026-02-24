import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models/note.dart';
import 'services/storage.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

void main() => runApp(const SmartNoteApp());

class SmartNoteApp extends StatelessWidget {
  const SmartNoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Note',
      theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal)),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _storage = NoteStorage.instance;
  List<Note> _notes = [];
  String _query = '';
  final _fmt = DateFormat('dd/MM/yyyy HH:mm');

  // Replace with your actual name and student id
  final _studentName = 'Trần Hữu Hậu';
  final _studentId = '2351060443';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final notes = await _storage.loadNotes();
    setState(() => _notes = notes);
  }

  List<Note> get _filtered => _query.isEmpty
      ? _notes
      : _notes.where((n) => n.title.toLowerCase().contains(_query.toLowerCase())).toList();

  Future<void> _openEditor([Note? note]) async {
    final isNew = note == null;
    final n = note ?? Note(id: DateTime.now().microsecondsSinceEpoch.toString(), title: '', content: '');
    final res = await Navigator.of(context).push<Note>(
      MaterialPageRoute(builder: (_) => DetailScreen(note: n)),
    );
    if (res != null) {
      await _storage.addOrUpdate(res);
      await _load();
    } else if (isNew) {
      // if editor returned null and it was a new note, do nothing
    } else {
      await _load();
    }
  }

  Future<bool> _confirmDelete() async {
    final r = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa ghi chú này không?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(c).pop(false), child: const Text('Hủy')),
          ElevatedButton(onPressed: () => Navigator.of(c).pop(true), child: const Text('OK')),
        ],
      ),
    );
    return r == true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Smart Note - $_studentName - $_studentId'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm theo tiêu đề',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                filled: true,
              ),
            ),
          ),
          Expanded(
            child: _notes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.note_alt, size: 96, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        const Text('Bạn chưa có ghi chú nào, hãy tạo mới nhé!', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: MasonryGridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      itemCount: _filtered.length,
                      itemBuilder: (context, index) {
                        final n = _filtered[index];
                        return Dismissible(
                          key: ValueKey(n.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          confirmDismiss: (_) async => await _confirmDelete(),
                          onDismissed: (_) async {
                            await _storage.delete(n.id);
                            await _load();
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa ghi chú')));
                          },
                          child: GestureDetector(
                            onTap: () => _openEditor(n),
                            child: Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 3,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(n.title.isEmpty ? '(Chưa có tiêu đề)' : n.title,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 8),
                                    Text(n.content,
                                        style: TextStyle(color: Colors.grey[700]),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 12),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: Text(_fmt.format(n.updatedAt), style: const TextStyle(fontSize: 11, color: Colors.black54)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class DetailScreen extends StatefulWidget {
  final Note note;
  const DetailScreen({super.key, required this.note});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late TextEditingController _titleCtrl;
  late TextEditingController _contentCtrl;
  final _storage = NoteStorage.instance;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.note.title);
    _contentCtrl = TextEditingController(text: widget.note.content);
  }

  Future<void> _autoSaveAndPop() async {
    final updated = Note(
      id: widget.note.id,
      title: _titleCtrl.text.trim(),
      content: _contentCtrl.text.trim(),
      updatedAt: DateTime.now(),
    );
    if (updated.title.isEmpty && updated.content.isEmpty) {
      // do not save empty note
      Navigator.of(context).pop(null);
      return;
    }
    await _storage.addOrUpdate(updated);
    Navigator.of(context).pop(updated);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _autoSaveAndPop();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Soạn thảo'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _autoSaveAndPop(),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _titleCtrl,
                decoration: const InputDecoration(hintText: 'Tiêu đề', border: InputBorder.none),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                maxLines: 1,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: TextField(
                  controller: _contentCtrl,
                  decoration: const InputDecoration(hintText: 'Nội dung', border: InputBorder.none),
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
