import 'package:flutter/material.dart';

class FileTransferScreen extends StatelessWidget {
  final String fileId;
  const FileTransferScreen({required this.fileId, super.key});

  @override
  Widget build(BuildContext context) {
    final transfers = [
      {'name': 'photo.jpg', 'progress': 0.7, 'status': 'Receiving'},
      {'name': 'doc.pdf', 'progress': 1.0, 'status': 'Completed'},
    ];
    return Scaffold(
      appBar: AppBar(title: Text('File Transfer: $fileId')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...transfers.map(
            (t) => Card(
              child: ListTile(
                leading: const Icon(Icons.insert_drive_file),
                title: Text(t['name'] as String),
                subtitle: LinearProgressIndicator(
                  value: t['progress'] as double,
                ),
                trailing: Text(t['status'] as String),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.upload_file),
            label: const Text('Send File'),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
