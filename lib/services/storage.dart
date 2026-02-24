import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';

class NoteStorage {
  static const _kNotesKey = 'smart_note_notes_v1';
  NoteStorage._();
  static final NoteStorage instance = NoteStorage._();

  Future<List<Note>> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kNotesKey);
    if (raw == null || raw.isEmpty) return <Note>[];
    try {
      return Note.listFromJson(raw);
    } catch (_) {
      return <Note>[];
    }
  }

  Future<void> saveNotes(List<Note> notes) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = Note.listToJson(notes);
    await prefs.setString(_kNotesKey, raw);
  }

  Future<void> addOrUpdate(Note note) async {
    final notes = await loadNotes();
    final idx = notes.indexWhere((n) => n.id == note.id);
    if (idx == -1) {
      notes.insert(0, note);
    } else {
      notes[idx] = note;
    }
    await saveNotes(notes);
  }

  Future<void> delete(String id) async {
    final notes = await loadNotes();
    notes.removeWhere((n) => n.id == id);
    await saveNotes(notes);
  }
}
