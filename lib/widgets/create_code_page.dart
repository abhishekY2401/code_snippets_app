import 'package:flutter/material.dart';

class CreateSnippetPage extends StatefulWidget {
  @override
  _CreateSnippetPageState createState() => _CreateSnippetPageState();
}

class _CreateSnippetPageState extends State<CreateSnippetPage> {
  String snippetTitle = '';

  void _onSnippetTitleChanged(String value) {
    setState(() {
      snippetTitle = value;
    });
  }

  void _onCreateSnippetPressed() {
    // Implement logic to create todo
    print('Code Snippet Title: $snippetTitle');
    // Replace the above print statement with your actual logic to create a todo
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Code Snippet'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              onChanged: _onSnippetTitleChanged,
              decoration: const InputDecoration(
                labelText: 'Code Snippet Title',
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _onCreateSnippetPressed,
              child: const Text('Create Code Snippet'),
            ),
          ],
        ),
      ),
    );
  }
}
