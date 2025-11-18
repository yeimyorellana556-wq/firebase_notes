import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_config.dart';
import 'firestone_service.dart';
import 'login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: firebaseConfig);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notas con Firebase',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepPurple),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/notes': (context) => const NotesPage(),
      },
    );
  }
}

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});
  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final TextEditingController _controller = TextEditingController();
  final FirestoneService _service = FirestoneService();
  String _selectedCategory = 'Personal'; 
  //Categoria por defecto
  
  String _formatDate(DateTime date) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(date.day)}/${two(date.month)}/${date.year} ${two(date.hour)}:${two(date.minute)}';
  }

  final List<String> _categories = [
    'Personal',
    'Trabajo',
    'Compras',
    'Recordatorios',
    'Otros'
  ];

  Future<void> _addNote() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    await _service.addNote(text, _selectedCategory);
    _controller.clear();
  }

  Future<void> _editNote(String id, String oldText, String oldCategory) async {
    final textCtrl = TextEditingController(text: oldText);
    String selectedCategory = oldCategory;

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Editar nota'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: textCtrl),
              const SizedBox(height: 16),
              DropdownButton<String>(
                value: selectedCategory,
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? value) {
                  if (value != null) {
                    setState(() => selectedCategory = value);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, {
                'text': textCtrl.text.trim(),
                'category': selectedCategory,
              }),
              child: const Text('Guardar')
            ),
          ],
        ),
      ),
    );

    if (result == null || result['text']?.isEmpty == true) return;
    await _service.updateNote(id, result['text']!, result['category']!);
  }

  Future<void> _deleteNote(String id) async {
    await _service.deleteNote(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notas con Firebase')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: 'Escribe una nota...',
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => _addNote(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(onPressed: _addNote, child: const Text('Agregar')),
                  ],
                ),
                const SizedBox(height: 8),
                DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  items: _categories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    if (value != null) {
                      setState(() => _selectedCategory = value);
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _service.getNotesStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final notes = snapshot.data!.docs;
                if (notes.isEmpty) return const Center(child: Text('Sin notas aún'));

                return ListView.builder(
                  itemCount: notes.length,
                  itemBuilder: (context, i) {
                    final doc = notes[i];
                    // acceso seguro a los datos para tolerar documentos antiguos o incompletos
                    final data = doc.data() as Map<String, dynamic>;
                    final text = (data['text'] ?? '') as String;
                    final category = (data['category'] ?? 'Otros') as String;

                    DateTime createdAt;
                    final createdRaw = data['createdAt'];
                    if (createdRaw is Timestamp) {
                      createdAt = createdRaw.toDate();
                    } else if (createdRaw is DateTime) {
                      createdAt = createdRaw;
                    } else {
                      createdAt = DateTime.now();
                    }

                    return ListTile(
                      title: Text(text),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Categoría: $category'),
                          Text('Creado: ${_formatDate(createdAt)}'),
                        ],
                      ),
                      isThreeLine: true,
                      onTap: () => _editNote(doc.id, text, category),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteNote(doc.id),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}