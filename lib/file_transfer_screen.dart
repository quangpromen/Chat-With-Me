import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chat_offline/core/file_service.dart';
import 'package:chat_offline/data/models/file_transfer.dart';
import 'package:chat_offline/providers/app_state.dart';

class FileTransferScreen extends ConsumerWidget {
  const FileTransferScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transfers = ref.watch(transfersProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('File Transfers')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: transfers.isEmpty
            ? _EmptyState(onSelectFile: () => _pickAndSendFile(ref, context))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton.icon(
                      onPressed: () => _pickAndSendFile(ref, context),
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Send File'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.separated(
                      itemCount: transfers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final transfer = transfers[index];
                        return _TransferCard(transfer: transfer);
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _pickAndSendFile(WidgetRef ref, BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(content: Text('File picker chưa được tích hợp.')),
    );
    // TODO: integrate file picker flow then call
    // ref.read(fileServiceProvider).sendFile(pathToFile);
  }
}

class _TransferCard extends ConsumerWidget {
  const _TransferCard({required this.transfer});

  final FileTransfer transfer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCancelable =
        transfer.status == FileTransferStatus.offered ||
        transfer.status == FileTransferStatus.inProgress;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  transfer.direction == FileTransferDirection.outgoing
                      ? Icons.upload_file
                      : Icons.download,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transfer.fileName,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_formatBytes(transfer.bytesTransferred)} / ${_formatBytes(transfer.totalBytes)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _StatusChip(status: transfer.status),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              minHeight: 8,
              value: transfer.progress.clamp(0, 1),
              borderRadius: BorderRadius.circular(6),
            ),
            if (transfer.errorDescription != null) ...[
              const SizedBox(height: 8),
              Text(
                transfer.errorDescription!,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: colorScheme.error),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isCancelable)
                  TextButton.icon(
                    onPressed: () => ref
                        .read(fileServiceProvider)
                        .cancelTransfer(transfer.id),
                    icon: const Icon(Icons.cancel),
                    label: const Text('Cancel'),
                  ),
                if (transfer.status == FileTransferStatus.completed &&
                    transfer.savedToPath != null)
                  TextButton.icon(
                    onPressed: () =>
                        _openLocation(context, transfer.savedToPath!),
                    icon: const Icon(Icons.folder_open),
                    label: const Text('Open Folder'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _formatBytes(int bytes) {
    if (bytes >= 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    }
    return '$bytes B';
  }

  void _openLocation(BuildContext context, String path) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('File saved tại: $path')));
    // TODO: integrate platform-specific file opener.
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final FileTransferStatus status;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final (:background, :foreground) = _statusColors(status, colorScheme);
    final label = _statusLabel(status);
    return Chip(
      backgroundColor: background,
      label: Text(
        label,
        style: textTheme.labelMedium?.copyWith(color: foreground),
      ),
    );
  }

  ({Color background, Color foreground}) _statusColors(
    FileTransferStatus status,
    ColorScheme scheme,
  ) {
    switch (status) {
      case FileTransferStatus.offered:
        return (
          background: scheme.surfaceContainerHighest,
          foreground: scheme.onSurfaceVariant,
        );
      case FileTransferStatus.inProgress:
        return (
          background: scheme.primaryContainer,
          foreground: scheme.onPrimaryContainer,
        );
      case FileTransferStatus.completed:
        return (
          background: scheme.secondaryContainer,
          foreground: scheme.onSecondaryContainer,
        );
      case FileTransferStatus.failed:
        return (
          background: scheme.errorContainer,
          foreground: scheme.onErrorContainer,
        );
      case FileTransferStatus.canceled:
        return (
          background: scheme.surfaceContainerHigh,
          foreground: scheme.onSurface,
        );
    }
  }

  String _statusLabel(FileTransferStatus status) {
    switch (status) {
      case FileTransferStatus.offered:
        return 'Pending';
      case FileTransferStatus.inProgress:
        return 'Transferring';
      case FileTransferStatus.completed:
        return 'Completed';
      case FileTransferStatus.failed:
        return 'Failed';
      case FileTransferStatus.canceled:
        return 'Canceled';
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onSelectFile});

  final VoidCallback onSelectFile;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.file_present,
            size: 56,
            color: Theme.of(context).hintColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có truyền file nào',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: onSelectFile,
            icon: const Icon(Icons.upload_file),
            label: const Text('Gửi file'),
          ),
        ],
      ),
    );
  }
}
