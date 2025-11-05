enum FileTransferStatus { offered, inProgress, completed, failed, canceled }

enum FileTransferDirection { incoming, outgoing }

class FileTransfer {
  const FileTransfer({
    required this.id,
    required this.fileName,
    required this.filePath,
    this.savedToPath,
    required this.bytesTransferred,
    required this.totalBytes,
    required this.status,
    required this.direction,
    this.errorDescription,
  });

  final String id;
  final String fileName;
  final String filePath;
  final String? savedToPath;
  final int bytesTransferred;
  final int totalBytes;
  final FileTransferStatus status;
  final FileTransferDirection direction;
  final String? errorDescription;

  double get progress => totalBytes == 0
      ? 0
      : bytesTransferred / totalBytes;
}
