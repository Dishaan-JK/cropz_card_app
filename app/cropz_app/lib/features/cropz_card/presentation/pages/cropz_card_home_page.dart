import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import 'cropz_card_form_page.dart';
import 'cropz_card_preview_page.dart';
import '../providers/cropz_card_providers.dart';

class CropzCardHomePage extends ConsumerWidget {
  const CropzCardHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profiles = ref.watch(cropzProfilesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cropz Cards'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
            icon: const Icon(Icons.logout_rounded),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5F8FC), Color(0xFFEAF2FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: profiles.when(
          data: (items) {
            if (items.isEmpty) {
              return _EmptyState(
                onCreate: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const CropzCardFormPage(),
                    ),
                  );
                  ref.invalidate(cropzProfilesProvider);
                },
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: items.length + 1,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _SummaryCard(totalCards: items.length);
                }

                final profile = items[index - 1];
                final imagePath = profile.profilePicture;
                final imageFile = imagePath != null && imagePath.isNotEmpty
                    ? File(imagePath)
                    : null;
                final hasImage = imageFile != null && imageFile.existsSync();
                final avatarImage = hasImage && imageFile != null
                    ? FileImage(imageFile)
                    : null;

                return InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () async {
                    if (profile.id == null) {
                      return;
                    }
                    ref.invalidate(cropzCardDetailsProvider(profile.id!));
                    final details = await ref.read(
                      cropzCardDetailsProvider(profile.id!).future,
                    );
                    if (!context.mounted) {
                      return;
                    }
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
                            radius: 27,
                            backgroundColor: Colors.blueGrey.shade100,
                            backgroundImage: avatarImage,
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
                                  style: TextStyle(color: Colors.grey.shade700),
                                ),
                                const SizedBox(height: 9),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: [
                                    _InfoChip(
                                      label:
                                          profile.whatsapp?.isNotEmpty == true
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
                                    cropzCardDetailsProvider(
                                      profile.id!,
                                    ).future,
                                  );
                                  final data = CropzCardPreviewData.fromDetails(
                                    details,
                                  );
                                  if (!context.mounted) {
                                    return;
                                  }
                                  await Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) =>
                                          CropzCardPreviewPage(data: data),
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
                                    cropzCardDetailsProvider(
                                      profile.id!,
                                    ).future,
                                  );
                                  final data = CropzCardPreviewData.fromDetails(
                                    details,
                                  );
                                  if (!context.mounted) {
                                    return;
                                  }
                                  await Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) =>
                                          CropzCardPreviewPage(data: data),
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
                                    cropzCardDetailsProvider(
                                      profile.id!,
                                    ).future,
                                  );
                                  if (!context.mounted) {
                                    return;
                                  }
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
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Error: $error')),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const CropzCardFormPage()),
          );
          if (!context.mounted) {
            return;
          }
          ref.invalidate(cropzProfilesProvider);
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Card'),
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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.totalCards});

  final int totalCards;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [scheme.primary, scheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.space_dashboard_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dashboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$totalCards cards available',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.92)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreate});

  final Future<void> Function() onCreate;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 98,
              height: 98,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [scheme.primary, scheme.secondary],
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
            const SizedBox(height: 18),
            const Text(
              'No cards created yet',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first Cropz Card with modern share-ready details.',
              style: TextStyle(color: Colors.grey.shade700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add_circle_outline_rounded),
              label: const Text('Create First Card'),
            ),
          ],
        ),
      ),
    );
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
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
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
