import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';

class CodeSnippetManagerHomePage extends StatefulWidget {
  @override
  _CodeSnippetManagerHomePageState createState() =>
      _CodeSnippetManagerHomePageState();
}

class _CodeSnippetManagerHomePageState
    extends State<CodeSnippetManagerHomePage> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference snippetsCollection =
      FirebaseFirestore.instance.collection('snippets');
  List<QueryDocumentSnapshot> snippets = [];

  void _fetchCodeSnippets() async {
    QuerySnapshot snapshot = await snippetsCollection.get();
    setState(() {
      snippets = snapshot.docs;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchCodeSnippets();
  }

  void _onCreateSnippetPressed() {
    // Implement logic to navigate to create snippet page
    print("navigating to snippet page");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateSnippetPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Code Snippet Manager'),
        ),
        body: ListView.builder(
          itemCount: snippets.length,
          itemBuilder: (context, index) {
            // Access fields from QueryDocumentSnapshot using data() method
            Map<String, dynamic> snippetData =
                snippets[index].data() as Map<String, dynamic>;
            String? title = snippetData['title'];
            String? description = snippetData['readme'];
            String? fileId = snippetData['fileId']
                as String?; // Fetch additional field fileId
            String? fileName = snippetData['uploadedFileName']
                as String?; // Fetch additional field fileName

            return ListTile(
              title: Text(title ?? 'No Title'),
              subtitle: Text(description ?? 'No Description'),
              onTap: () {
                // Implement logic to navigate to snippet details page
                print('Snippet item tapped: ${snippets[index].id}');
                print('File ID: $fileId'); // Use the additional field fileId
                print(
                    'File Name: $fileName'); // Use the additional field fileName
                // Replace the above print statement with your actual logic to navigate to snippet details page
              },
            );
          },
        ),
        floatingActionButton: ElevatedButton(
          onPressed: _onCreateSnippetPressed,
          child: const Icon(Icons.add),
        ));
  }
}

class CreateSnippetPage extends StatefulWidget {
  @override
  _CreateSnippetPageState createState() => _CreateSnippetPageState();
}

class _CreateSnippetPageState extends State<CreateSnippetPage> {
  String _title = '';
  String _readme = '';
  bool _isFileUploaded = false;
  String _uploadedFileName = '';
  bool _isTitleErrorVisible = false;
  String _titleErrorText = '';
  bool _isFileErrorVisible = false;
  String _fileErrorText = '';
  bool _isReadmeErrorVisible = false;
  String _readmeErrorText = '';

  final CollectionReference snippetsCollection =
      FirebaseFirestore.instance.collection('snippets');

  TextEditingController _titleController = TextEditingController();
  TextEditingController _readmeController = TextEditingController();

  void _onTitleChanged(String value) {
    setState(() {
      _title = value;
    });
  }

  void _onReadmeChanged(String value) {
    setState(() {
      _readme = value;
    });
  }

  void _onFileUploadPressed() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'js',
        'java',
        'html',
        'css',
        'txt',
        'cpp',
        'c',
        '.ipynb'
      ],
    );

    if (result != null) {
      setState(() {
        _isFileUploaded = true;
        _uploadedFileName = result.files.single.name!;
        // You can also access the file using result.files.single.bytes
      });
    }
  }

  void _onCreateSnippetPressed() async {
    String title = _titleController.text.trim();
    String readme = _readmeController.text.trim();

    if (title.isEmpty) {
      setState(() {
        _isTitleErrorVisible = true;
        _titleErrorText = 'Title is required';
      });
      return;
    } else {
      setState(() {
        _isTitleErrorVisible = false;
      });
    }

    if (_isFileUploaded == false) {
      setState(() {
        _isFileErrorVisible = true;
        _fileErrorText = 'File is required';
      });
      return;
    } else {
      setState(() {
        _isFileErrorVisible = false;
      });
    }

    if (readme.isEmpty) {
      setState(() {
        _isReadmeErrorVisible = true;
        _readmeErrorText = 'Readme is required';
      });
      return;
    } else {
      setState(() {
        _isReadmeErrorVisible = false;
      });
    }

    try {
      // Add snippet data to Firestore
      await snippetsCollection.add({
        'title': title,
        'readme': readme,
        'uploadedFileName': _uploadedFileName, // Update with your file name
      });
      print('Snippet created successfully');
    } catch (e) {
      print('Failed to create snippet: $e');
    }

    // TODO: Implement code snippet creation logic with Firebase
    // You can use the title, _uploadedFileName, and readme variables
    // to access the user inputs and perform further actions

    // Reset input fields after successful submission
    _titleController.clear();
    _readmeController.clear();
    setState(() {
      _isFileUploaded = false;
      _uploadedFileName = '';
    });

    // Show success message or navigate to another page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Snippet'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              onChanged: _onTitleChanged,
              decoration: InputDecoration(
                labelText: 'Title',
                errorText: _isTitleErrorVisible ? _titleErrorText : null,
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _onFileUploadPressed,
              child: const Text('Upload File'),
            ),
            const Text(
                'allowed file extensions to upload (.js, .ipynb, .java, .cpp, .c)'),
            Visibility(
              visible: _isFileUploaded,
              child: Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  'Uploaded File: $_uploadedFileName',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Visibility(
              visible: _isFileErrorVisible,
              child: Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  _fileErrorText,
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _readmeController,
              onChanged: _onReadmeChanged,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Readme',
                errorText: _isReadmeErrorVisible ? _readmeErrorText : null,
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _onCreateSnippetPressed,
              child: Text('Create Snippet'),
            ),
          ],
        ),
      ),
    );
  }
}
