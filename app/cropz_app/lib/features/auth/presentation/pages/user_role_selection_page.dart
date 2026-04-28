import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_providers.dart';

class UserRoleSelectionPage extends ConsumerWidget {
  const UserRoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final selectedType = auth.userType;

    final options = <_RoleOption>[
      const _RoleOption(
        type: UserType.dealer,
        title: 'Dealer',
        subtitle: 'Wholesaler or Retailer',
        icon: Icons.storefront_rounded,
      ),
      const _RoleOption(
        type: UserType.agriSpecialist,
        title: 'Agri-Specialist',
        subtitle: 'Coming soon',
        icon: Icons.eco_rounded,
      ),
      const _RoleOption(
        type: UserType.companyStaff,
        title: 'Company Staff',
        subtitle: 'Coming soon',
        icon: Icons.badge_rounded,
      ),
      const _RoleOption(
        type: UserType.farmer,
        title: 'Farmer',
        subtitle: 'Coming soon',
        icon: Icons.agriculture_rounded,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select User Type'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose your role to continue',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                'Dealer is currently available. Other roles will be enabled soon.',
                style: TextStyle(color: Colors.blueGrey.shade700),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  itemCount: options.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.05,
                  ),
                  itemBuilder: (context, index) {
                    final option = options[index];
                    final isSelected = selectedType == option.type;
                    return _RoleCard(
                      option: option,
                      isSelected: isSelected,
                      onTap: () async {
                        await ref
                            .read(authControllerProvider.notifier)
                            .setUserType(option.type);

                        if (option.type != UserType.dealer && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${option.title} feature coming soon.',
                              ),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final _RoleOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? scheme.primary : scheme.outlineVariant,
              width: isSelected ? 2 : 1,
            ),
            color: isSelected
                ? scheme.primary.withValues(alpha: 0.08)
                : Theme.of(context).cardColor,
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(option.icon, size: 26, color: scheme.primary),
                const Spacer(),
                Text(
                  option.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  option.subtitle,
                  style: TextStyle(color: Colors.blueGrey.shade700),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleOption {
  const _RoleOption({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final UserType type;
  final String title;
  final String subtitle;
  final IconData icon;
}
