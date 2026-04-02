import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/presentation/providers/theme_mode_provider.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/cropz_card_providers.dart';
import 'cropz_card_form_page.dart';
import 'cropz_card_preview_page.dart';

enum _SidebarItem { dashboard, settings }

class CropzCardHomePage extends ConsumerStatefulWidget {
  const CropzCardHomePage({super.key});

  @override
  ConsumerState<CropzCardHomePage> createState() => _CropzCardHomePageState();
}

class _CropzCardHomePageState extends ConsumerState<CropzCardHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  bool _sidebarCollapsed = false;
  _SidebarItem _activeItem = _SidebarItem.dashboard;
  int _interactionTick = 0;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _triggerBackgroundPulse() {
    setState(() => _interactionTick++);
  }

  Future<void> _openForm({int? profileId}) async {
    _triggerBackgroundPulse();
    if (profileId == null) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const CropzCardFormPage()),
      );
      if (!mounted) {
        return;
      }
      ref.invalidate(cropzProfilesProvider);
      ref.invalidate(searchableProfilesProvider);
      return;
    }

    ref.invalidate(cropzCardDetailsProvider(profileId));
    final details = await ref.read(cropzCardDetailsProvider(profileId).future);
    if (!mounted) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CropzCardFormPage(initialDetails: details),
      ),
    );
    ref.invalidate(cropzProfilesProvider);
    ref.invalidate(searchableProfilesProvider);
  }

  Future<void> _openPreview(int profileId) async {
    _triggerBackgroundPulse();
    ref.invalidate(cropzCardDetailsProvider(profileId));
    final details = await ref.read(cropzCardDetailsProvider(profileId).future);
    final data = CropzCardPreviewData.fromDetails(details);
    if (!mounted) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => CropzCardPreviewPage(data: data)),
    );
  }

  bool _matchesQuery(SearchableProfile item, String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return true;
    }
    return item.searchCorpus.contains(normalized);
  }

  @override
  Widget build(BuildContext context) {
    final searchable = ref.watch(searchableProfilesProvider);
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWide = MediaQuery.sizeOf(context).width >= 980;
    final query = _searchController.text;
    final hasCards = searchable.asData?.value.isNotEmpty == true;

    return Scaffold(
      key: _scaffoldKey,
      drawer: isWide
          ? null
          : Drawer(
              backgroundColor: Colors.transparent,
              child: _GlassSidebar(
                collapsed: false,
                activeItem: _activeItem,
                onToggleCollapse: null,
                onSelect: (item) {
                  _triggerBackgroundPulse();
                  setState(() => _activeItem = item);
                  Navigator.of(context).pop();
                },
              ),
            ),
      body: Stack(
        children: [
          Positioned.fill(
            child: _AnimatedMeshBackground(interactionTick: _interactionTick),
          ),
          SafeArea(
            child: Row(
              children: [
                if (isWide)
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: _GlassSidebar(
                      collapsed: _sidebarCollapsed,
                      activeItem: _activeItem,
                      onToggleCollapse: () {
                        _triggerBackgroundPulse();
                        setState(() => _sidebarCollapsed = !_sidebarCollapsed);
                      },
                      onSelect: (item) {
                        _triggerBackgroundPulse();
                        setState(() => _activeItem = item);
                      },
                    ),
                  ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(isWide ? 0 : 14, 14, 14, 14),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            if (!isWide)
                              _ScaleButton(
                                onTap: () {
                                  _triggerBackgroundPulse();
                                  _scaffoldKey.currentState?.openDrawer();
                                },
                                child: _TopActionBox(
                                  icon: Icons.menu_rounded,
                                  scheme: scheme,
                                ),
                              ),
                            if (!isWide) const SizedBox(width: 10),
                            Expanded(
                              child: _AnimatedSearchBar(
                                controller: _searchController,
                                focusNode: _searchFocusNode,
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                            const SizedBox(width: 10),
                            _ScaleButton(
                              onTap: () {
                                _triggerBackgroundPulse();
                                ref.read(themeModeProvider.notifier).toggle();
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 220),
                                width: 96,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).cardColor.withValues(alpha: 0.76),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: scheme.outline.withValues(
                                      alpha: 0.45,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      isDark
                                          ? Icons.nights_stay_rounded
                                          : Icons.light_mode_rounded,
                                      size: 18,
                                      color: scheme.primary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      isDark ? 'Dark' : 'Light',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Expanded(
                          child: _activeItem == _SidebarItem.settings
                              ? _SettingsPanel(
                                  onAddAccount: () {
                                    _triggerBackgroundPulse();
                                    ref
                                        .read(authControllerProvider.notifier)
                                        .logout();
                                  },
                                  onLogout: () {
                                    _triggerBackgroundPulse();
                                    ref
                                        .read(authControllerProvider.notifier)
                                        .logout();
                                  },
                                )
                              : _buildDashboard(searchable, query),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _activeItem == _SidebarItem.dashboard && hasCards
          ? FloatingActionButton.extended(
              onPressed: () => _openForm(),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create Card'),
            )
          : null,
    );
  }

  Widget _buildDashboard(
    AsyncValue<List<SearchableProfile>> searchable,
    String query,
  ) {
    return searchable.when(
      data: (items) {
        final filtered = items
            .where((item) => _matchesQuery(item, query))
            .toList(growable: false);

        if (items.isEmpty) {
          return _EmptyState(onCreate: () => _openForm());
        }

        return ListView.separated(
          padding: const EdgeInsets.only(bottom: 24),
          itemCount: filtered.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final entry = filtered[index];
            final profile = entry.profile;
            final imagePath = profile.profilePicture;
            final imageFile = imagePath != null && imagePath.isNotEmpty
                ? File(imagePath)
                : null;
            final hasImage = imageFile != null && imageFile.existsSync();

            final ownerName = (profile.ownerName ?? '').trim();

            return _ScaleButton(
              onTap: profile.id == null
                  ? null
                  : () => _openPreview(profile.id!),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 27,
                        backgroundColor: Colors.blueGrey.shade100,
                        backgroundImage: hasImage ? FileImage(imageFile) : null,
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
                            if (ownerName.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(ownerName),
                            ],
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
                                  label: profile.whatsapp?.isNotEmpty == true
                                      ? 'WhatsApp'
                                      : 'No WhatsApp',
                                ),
                                _InfoChip(
                                  label: profile.gstNo?.isNotEmpty == true
                                      ? 'GST Added'
                                      : 'No GST',
                                ),
                                if (entry.citySet.isNotEmpty)
                                  _InfoChip(
                                    label: entry.citySet.first
                                        .split(' ')
                                        .map(
                                          (word) => word.isEmpty
                                              ? ''
                                              : '${word[0].toUpperCase()}${word.substring(1)}',
                                        )
                                        .join(' '),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      _ScaleIconButton(
                        tooltip: 'Edit',
                        icon: Icons.edit_outlined,
                        onTap: profile.id == null
                            ? null
                            : () => _openForm(profileId: profile.id!),
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

class _TopActionBox extends StatelessWidget {
  const _TopActionBox({required this.icon, required this.scheme});

  final IconData icon;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.45)),
      ),
      child: Icon(icon),
    );
  }
}

class _AnimatedSearchBar extends StatefulWidget {
  const _AnimatedSearchBar({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  State<_AnimatedSearchBar> createState() => _AnimatedSearchBarState();
}

class _AnimatedSearchBarState extends State<_AnimatedSearchBar> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final focused = widget.focusNode.hasFocus;
    final scheme = Theme.of(context).colorScheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor.withValues(alpha: 0.74),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: focused
                ? scheme.primary
                : _hovering
                ? scheme.outline.withValues(alpha: 0.7)
                : scheme.outline.withValues(alpha: 0.35),
            width: focused ? 1.4 : 1,
          ),
        ),
        child: TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          onChanged: widget.onChanged,
          decoration: const InputDecoration(
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search_rounded),
            hintText: 'Search by name, firm, city, or address',
          ),
        ),
      ),
    );
  }
}

class _GlassSidebar extends StatelessWidget {
  const _GlassSidebar({
    required this.collapsed,
    required this.activeItem,
    required this.onSelect,
    required this.onToggleCollapse,
  });

  final bool collapsed;
  final _SidebarItem activeItem;
  final ValueChanged<_SidebarItem> onSelect;
  final VoidCallback? onToggleCollapse;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      width: collapsed ? 88 : 266,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: Theme.of(context).cardColor.withValues(alpha: 0.72),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.38)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 18, 10, 20),
        child: Column(
          crossAxisAlignment: collapsed
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: collapsed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.spaceBetween,
              children: [
                if (!collapsed)
                  const Text(
                    'Cropz Hub',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  )
                else
                  Icon(Icons.grid_view_rounded, color: scheme.primary),
                if (onToggleCollapse != null)
                  _ScaleIconButton(
                    tooltip: collapsed ? 'Expand' : 'Collapse',
                    icon: collapsed
                        ? Icons.chevron_right_rounded
                        : Icons.chevron_left_rounded,
                    onTap: onToggleCollapse,
                  ),
              ],
            ),
            const SizedBox(height: 14),
            if (!collapsed)
              Padding(
                padding: const EdgeInsets.only(left: 6, bottom: 8),
                child: Text(
                  'Elements',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface.withValues(alpha: 0.65),
                  ),
                ),
              ),
            _SidebarNavButton(
              collapsed: collapsed,
              icon: Icons.dashboard_outlined,
              label: 'Dashboard',
              selected: activeItem == _SidebarItem.dashboard,
              onTap: () => onSelect(_SidebarItem.dashboard),
            ),
            _SidebarNavButton(
              collapsed: collapsed,
              icon: Icons.settings_outlined,
              label: 'Settings',
              selected: activeItem == _SidebarItem.settings,
              onTap: () => onSelect(_SidebarItem.settings),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarNavButton extends StatelessWidget {
  const _SidebarNavButton({
    required this.collapsed,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final bool collapsed;
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: _ScaleButton(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 46,
          padding: EdgeInsets.symmetric(horizontal: collapsed ? 0 : 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: selected
                ? scheme.primary.withValues(alpha: 0.16)
                : Colors.transparent,
            border: Border.all(
              color: selected
                  ? scheme.primary.withValues(alpha: 0.5)
                  : scheme.outline.withValues(alpha: 0.28),
            ),
          ),
          child: Row(
            mainAxisAlignment: collapsed
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              Icon(icon, color: selected ? scheme.primary : null),
              if (!collapsed) ...[
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: selected ? scheme.primary : null,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ScaleButton extends StatefulWidget {
  const _ScaleButton({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  State<_ScaleButton> createState() => _ScaleButtonState();
}

class _ScaleButtonState extends State<_ScaleButton> {
  bool _hover = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final scale = _pressed
        ? 0.97
        : _hover
        ? 1.01
        : 1.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() {
        _hover = false;
        _pressed = false;
      }),
      child: GestureDetector(
        onTapDown: widget.onTap == null
            ? null
            : (_) => setState(() => _pressed = true),
        onTapUp: widget.onTap == null
            ? null
            : (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 130),
          scale: scale,
          child: widget.child,
        ),
      ),
    );
  }
}

class _ScaleIconButton extends StatelessWidget {
  const _ScaleIconButton({
    required this.tooltip,
    required this.icon,
    required this.onTap,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: _ScaleButton(
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          margin: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).cardColor.withValues(alpha: 0.56),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.35),
            ),
          ),
          child: Icon(icon, size: 20),
        ),
      ),
    );
  }
}

class _AnimatedMeshBackground extends StatefulWidget {
  const _AnimatedMeshBackground({required this.interactionTick});

  final int interactionTick;

  @override
  State<_AnimatedMeshBackground> createState() =>
      _AnimatedMeshBackgroundState();
}

class _AnimatedMeshBackgroundState extends State<_AnimatedMeshBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 26),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark
        ? const [Color(0xFF0F172A), Color(0xFF111827), Color(0xFF1E293B)]
        : const [Color(0xFFEFFBF1), Color(0xFFF7FAFF), Color(0xFFECFDF3)];

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          final driftX = math.sin(t * math.pi * 2) * 0.35;
          final driftY = math.cos(t * math.pi * 2) * 0.35;

          return DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Align(
                  alignment: Alignment(-0.8 + driftX, -0.9 + driftY),
                  child: _GlowOrb(
                    size: 280,
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.16),
                  ),
                ),
                Align(
                  alignment: Alignment(0.9 - driftY, -0.2 + driftX),
                  child: _GlowOrb(
                    size: 230,
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.14),
                  ),
                ),
                Align(
                  alignment: Alignment(-0.3 - driftX, 1.0 - driftY),
                  child: _GlowOrb(
                    size: 320,
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.11),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  color: Theme.of(context).colorScheme.primary.withValues(
                    alpha: widget.interactionTick.isEven ? 0.015 : 0.08,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
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
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
      ),
    );
  }
}

class _SettingsPanel extends StatelessWidget {
  const _SettingsPanel({required this.onAddAccount, required this.onLogout});

  final VoidCallback onAddAccount;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(
                      colors: [
                        scheme.primary.withValues(alpha: 0.16),
                        scheme.secondary.withValues(alpha: 0.16),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: scheme.primary.withValues(alpha: 0.4),
                    ),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Multilingual Feature Coming Soon',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'We are building seamless language switching for profile data, address labels, and search-aware transliteration.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: onAddAccount,
                  icon: const Icon(Icons.switch_account_outlined),
                  label: const Text('Add Accounts'),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: onLogout,
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Log Out Account'),
                ),
              ],
            ),
          ),
        ),
      ],
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
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
