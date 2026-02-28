import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'cropz_card_form_page.dart';
import 'cropz_card_preview_page.dart';
import '../providers/cropz_card_providers.dart';

class CropzCardHomePage extends ConsumerWidget {
  const CropzCardHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profiles = ref.watch(cropzProfilesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Cropz Card')),
      body: profiles.when(
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.secondary,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Icon(
                        Icons.receipt_long_outlined,
                        size: 42,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No cards yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap + to create your first Cropz Card.',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF7F9FB), Color(0xFFEFF6FF)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final profile = items[index];
              final imagePath = profile.profilePicture;
              final imageFile = imagePath != null && imagePath.isNotEmpty
                  ? File(imagePath)
                  : null;
              final hasImage = imageFile != null && imageFile.existsSync();
              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () async {
                  if (profile.id == null) {
                    return;
                  }
                  ref.invalidate(cropzCardDetailsProvider(profile.id!));
                  final details = await ref.read(
                    cropzCardDetailsProvider(profile.id!).future,
                  );
                  await Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          CropzCardFormPage(initialDetails: details),
                    ),
                  );
                  ref.invalidate(cropzProfilesProvider);
                },
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: Colors.blueGrey.shade100,
                          backgroundImage: hasImage ? FileImage(imageFile!) : null,
                          child: hasImage
                              ? null
                              : Text(
                                  _initials(profile.firmName),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile.firmName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                profile.mobile,
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  _InfoChip(
                                    label: profile.whatsapp?.isNotEmpty == true
                                        ? 'WhatsApp'
                                        : 'No WhatsApp',
                                  ),
                                  _InfoChip(
                                    label: profile.gstNo?.isNotEmpty == true
                                        ? 'GST Added'
                                        : 'No GST',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            IconButton(
                              tooltip: 'Preview',
                              icon: const Icon(Icons.preview_outlined),
                              onPressed: () async {
                                if (profile.id == null) {
                                  return;
                                }
                                ref.invalidate(
                                  cropzCardDetailsProvider(profile.id!),
                                );
                                final details = await ref.read(
                                  cropzCardDetailsProvider(profile.id!).future,
                                );
                                final data =
                                    CropzCardPreviewData.fromDetails(details);
                                if (!context.mounted) {
                                  return;
                                }
                                await Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => CropzCardPreviewPage(
                                      data: data,
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              tooltip: 'Share',
                              icon: const Icon(Icons.share_outlined),
                              onPressed: () async {
                                if (profile.id == null) {
                                  return;
                                }
                                ref.invalidate(
                                  cropzCardDetailsProvider(profile.id!),
                                );
                                final details = await ref.read(
                                  cropzCardDetailsProvider(profile.id!).future,
                                );
                                final data =
                                    CropzCardPreviewData.fromDetails(details);
                                if (!context.mounted) {
                                  return;
                                }
                                await Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => CropzCardPreviewPage(
                                      data: data,
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              tooltip: 'Edit',
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () async {
                                if (profile.id == null) {
                                  return;
                                }
                                ref.invalidate(
                                  cropzCardDetailsProvider(profile.id!),
                                );
                                final details = await ref.read(
                                  cropzCardDetailsProvider(profile.id!).future,
                                );
                                await Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => CropzCardFormPage(
                                      initialDetails: details,
                                    ),
                                  ),
                                );
                                ref.invalidate(cropzProfilesProvider);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const CropzCardFormPage()),
          );
          ref.invalidate(cropzProfilesProvider);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  String _initials(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return '--';
    }
    final letters = trimmed.replaceAll(RegExp(r'\s+'), '');
    if (letters.isEmpty) {
      return '--';
    }
    return letters.length >= 2
        ? letters.substring(0, 2).toUpperCase()
        : letters.substring(0, 1).toUpperCase();
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
