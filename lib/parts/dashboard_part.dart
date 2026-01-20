part of '../main.dart';

class DashboardShell extends StatefulWidget {
  const DashboardShell({super.key});

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  int _selectedIndex = 0;

  void _onSelect(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        return Scaffold(
          appBar: AppBar(
            title: const _BrandTitle(),
            actions: [
              SizedBox(
                width: isWide ? 360 : 220,
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Rechercher une personne, un lieu, un document',
                    prefixIcon: Icon(Icons.search),
                    contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none),
                tooltip: 'Notifications',
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 16,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: const Text('A', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 16),
            ],
          ),
          drawer: isWide ? null : _AppDrawer(selectedIndex: _selectedIndex, onSelect: _onSelect),
          body: Row(
            children: [
              if (isWide)
                SizedBox(
                  width: 220,
                  child: _Sidebar(selectedIndex: _selectedIndex, onSelect: _onSelect),
                ),
              Expanded(child: _DashboardContent(selectedIndex: _selectedIndex)),
            ],
          ),
        );
      },
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.selectedIndex, required this.onSelect});

  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 4),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('Workspace', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FB),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  CircleAvatar(radius: 16, child: Text('A')),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Alex Martin', style: TextStyle(fontWeight: FontWeight.w600)),
                        Text('Profil principal', style: TextStyle(fontSize: 11, color: Colors.black54)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('Navigation', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black54)),
          ),
          _NavTile(
            icon: Icons.account_tree_outlined,
            label: 'Arbre',
            index: 0,
            selectedIndex: selectedIndex,
            onTap: onSelect,
          ),
          _NavTile(
            icon: Icons.people_outline,
            label: 'Relations',
            index: 1,
            selectedIndex: selectedIndex,
            onTap: onSelect,
            trailing: _Badge(count: 3),
          ),
          _NavTile(
            icon: Icons.article_outlined,
            label: 'Documents',
            index: 2,
            selectedIndex: selectedIndex,
            onTap: onSelect,
            trailing: _Badge(count: 2),
          ),
          _NavTile(
            icon: Icons.settings_outlined,
            label: 'Paramètres',
            index: 3,
            selectedIndex: selectedIndex,
            onTap: onSelect,
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('Actions rapides', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black54)),
          ),
          _SidebarQuickActions(
            onAddRelation: () => onSelect(0),
            onImport: () {},
            onShare: () {},
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('Progression', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black54)),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: _SidebarProgressCard(value: 0.62),
          ),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('MVP · UI statique', style: TextStyle(color: Colors.black54)),
          ),
        ],
      ),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  const _AppDrawer({required this.selectedIndex, required this.onSelect});

  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: _Sidebar(selectedIndex: selectedIndex, onSelect: (index) {
          Navigator.of(context).pop();
          onSelect(index);
        }),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.label,
    required this.index,
    required this.selectedIndex,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final int index;
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final isSelected = index == selectedIndex;
    return ListTile(
      leading: Icon(icon, color: isSelected ? Theme.of(context).colorScheme.primary : null),
      title: Text(label),
      selected: isSelected,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      selectedTileColor: Theme.of(context).colorScheme.primary.withAlpha(18),
      trailing: trailing,
      onTap: () => onTap(index),
    );
  }
}

class _SidebarQuickActions extends StatelessWidget {
  const _SidebarQuickActions({
    required this.onAddRelation,
    required this.onImport,
    required this.onShare,
  });

  final VoidCallback onAddRelation;
  final VoidCallback onImport;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton.icon(
            onPressed: onAddRelation,
            icon: const Icon(Icons.add),
            label: const Text('Ajouter relation'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: onImport,
            icon: const Icon(Icons.upload_file),
            label: const Text('Importer'),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onShare,
            icon: const Icon(Icons.share_outlined),
            label: const Text('Partager'),
          ),
        ],
      ),
    );
  }
}

class _SidebarProgressCard extends StatelessWidget {
  const _SidebarProgressCard({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    final percent = (value * 100).round();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5EAF4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Arbre complété', style: TextStyle(color: Colors.black.withAlpha(160), fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 8,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text('$percent% de données vérifiées', style: const TextStyle(color: Colors.black54, fontSize: 12)),
        ],
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.selectedIndex});

  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    switch (selectedIndex) {
      case 1:
        return const _RelationsView();
      case 2:
        return const _DocumentsView();
      case 3:
        return const _SettingsView();
      case 0:
      default:
        return const _GraphView();
    }
  }
}

class _BrandTitle extends StatelessWidget {
  const _BrandTitle();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 32,
          width: 32,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.hub, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 12),
        const Text('Ego Proxy', style: TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withAlpha(20),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text('$count', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 11)),
    );
  }
}
