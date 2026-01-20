import 'package:flutter/material.dart';

void main() {
  runApp(const EgoProxyApp());
}

class EgoProxyApp extends StatelessWidget {
  const EgoProxyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF4E6AF3),
      brightness: Brightness.light,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ego Proxy',
      theme: ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6F7FB),
        cardTheme: const CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
        ),
      ),
      home: const DashboardShell(),
    );
  }
}

enum RelationType {
  parent,
  child,
  sibling,
  partner,
}

class Person {
  const Person({
    required this.id,
    required this.name,
    required this.subtitle,
    this.isVerified = false,
  });

  final String id;
  final String name;
  final String subtitle;
  final bool isVerified;
}

class Relationship {
  const Relationship({
    required this.fromId,
    required this.toId,
    required this.type,
  });

  final String fromId;
  final String toId;
  final RelationType type;
}

class SampleData {
  static const me = Person(
    id: 'me',
    name: 'Alex Martin',
    subtitle: 'Né(e) le 12/04/1992 · Paris',
    isVerified: true,
  );

  static const persons = <Person>[
    me,
    Person(id: 'father', name: 'Jean Martin', subtitle: 'Père · 1965'),
    Person(id: 'mother', name: 'Marie Martin', subtitle: 'Mère · 1967'),
    Person(id: 'sibling', name: 'Paul Martin', subtitle: 'Frère · 1990'),
    Person(id: 'partner', name: 'Camille Durand', subtitle: 'Conjoint · 1993'),
    Person(id: 'child1', name: 'Lina Martin', subtitle: 'Enfant · 2018'),
    Person(id: 'child2', name: 'Noah Martin', subtitle: 'Enfant · 2021'),
  ];

  static const relations = <Relationship>[
    Relationship(fromId: 'father', toId: 'me', type: RelationType.parent),
    Relationship(fromId: 'mother', toId: 'me', type: RelationType.parent),
    Relationship(fromId: 'me', toId: 'sibling', type: RelationType.sibling),
    Relationship(fromId: 'me', toId: 'partner', type: RelationType.partner),
    Relationship(fromId: 'me', toId: 'child1', type: RelationType.child),
    Relationship(fromId: 'me', toId: 'child2', type: RelationType.child),
  ];
}

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
            title: const Text('Ego Proxy'),
            centerTitle: false,
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.search),
                tooltip: 'Recherche',
              ),
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
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('Navigation', style: TextStyle(fontWeight: FontWeight.w600)),
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
          ),
          _NavTile(
            icon: Icons.article_outlined,
            label: 'Documents',
            index: 2,
            selectedIndex: selectedIndex,
            onTap: onSelect,
          ),
          _NavTile(
            icon: Icons.settings_outlined,
            label: 'Paramètres',
            index: 3,
            selectedIndex: selectedIndex,
            onTap: onSelect,
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
  });

  final IconData icon;
  final String label;
  final int index;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = index == selectedIndex;
    return ListTile(
      leading: Icon(icon, color: isSelected ? Theme.of(context).colorScheme.primary : null),
      title: Text(label),
      selected: isSelected,
      onTap: () => onTap(index),
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

class _GraphView extends StatelessWidget {
  const _GraphView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Votre arbre centré sur vous', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(
            'Cliquez sur un nœud pour explorer ses relations directes.',
            style: TextStyle(color: Colors.black.withAlpha(153)),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _GraphLinesPainter(),
                    ),
                  ),
                  _GraphNode(
                    person: SampleData.me,
                    alignment: const Alignment(0, 0),
                    size: 140,
                    isCenter: true,
                  ),
                  _GraphNode(
                    person: SampleData.persons.firstWhere((p) => p.id == 'father'),
                    alignment: const Alignment(0, -0.7),
                    size: 96,
                  ),
                  _GraphNode(
                    person: SampleData.persons.firstWhere((p) => p.id == 'mother'),
                    alignment: const Alignment(0.4, -0.5),
                    size: 96,
                  ),
                  _GraphNode(
                    person: SampleData.persons.firstWhere((p) => p.id == 'sibling'),
                    alignment: const Alignment(-0.7, 0.0),
                    size: 92,
                  ),
                  _GraphNode(
                    person: SampleData.persons.firstWhere((p) => p.id == 'partner'),
                    alignment: const Alignment(0.7, 0.0),
                    size: 92,
                  ),
                  _GraphNode(
                    person: SampleData.persons.firstWhere((p) => p.id == 'child1'),
                    alignment: const Alignment(-0.3, 0.7),
                    size: 88,
                  ),
                  _GraphNode(
                    person: SampleData.persons.firstWhere((p) => p.id == 'child2'),
                    alignment: const Alignment(0.3, 0.7),
                    size: 88,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GraphNode extends StatelessWidget {
  const _GraphNode({
    required this.person,
    required this.alignment,
    required this.size,
    this.isCenter = false,
  });

  final Person person;
  final Alignment alignment;
  final double size;
  final bool isCenter;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: GestureDetector(
        onTap: () {},
        child: Container(
          width: size,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isCenter ? const Color(0xFFE9EEFF) : Colors.white,
            borderRadius: BorderRadius.circular(isCenter ? 24 : 20),
            border: Border.all(color: const Color(0xFFDEE3F2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(15),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: isCenter ? 24 : 18,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(person.name.substring(0, 1), style: const TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 8),
              Text(
                person.name,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                person.subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10, color: Colors.black54),
              ),
              if (person.isVerified)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCF6E8),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text('Vérifié', style: TextStyle(fontSize: 9, color: Color(0xFF2E7D32))),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GraphLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = const Color(0xFFCBD5F1)
      ..strokeWidth = 2;

    final nodes = <Offset>[
      Offset(size.width / 2, size.height * 0.2),
      Offset(size.width * 0.7, size.height * 0.28),
      Offset(size.width * 0.2, size.height / 2),
      Offset(size.width * 0.8, size.height / 2),
      Offset(size.width * 0.35, size.height * 0.8),
      Offset(size.width * 0.65, size.height * 0.8),
    ];

    for (final node in nodes) {
      canvas.drawLine(center, node, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RelationsView extends StatelessWidget {
  const _RelationsView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Relations directes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: SampleData.relations.length,
              separatorBuilder: (context, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final relation = SampleData.relations[index];
                final from = SampleData.persons.firstWhere((p) => p.id == relation.fromId);
                final to = SampleData.persons.firstWhere((p) => p.id == relation.toId);
                return Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    leading: const Icon(Icons.link),
                    title: Text('${from.name} → ${to.name}'),
                    subtitle: Text(_relationLabel(relation.type)),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentsView extends StatelessWidget {
  const _DocumentsView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Documents & preuves', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              children: const [
                _DocumentTile(title: 'Acte de naissance', status: 'Validé', color: Color(0xFF2E7D32)),
                _DocumentTile(title: 'Livret de famille', status: 'En attente', color: Color(0xFFF57C00)),
                _DocumentTile(title: 'Pièce d\'identité', status: 'Rejeté', color: Color(0xFFC62828)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentTile extends StatelessWidget {
  const _DocumentTile({required this.title, required this.status, required this.color});

  final String title;
  final String status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: const Icon(Icons.description_outlined),
        title: Text(title),
        subtitle: Text(status, style: TextStyle(color: color)),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Paramètres', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: const [
                ListTile(
                  leading: Icon(Icons.security_outlined),
                  title: Text('Confidentialité'),
                  subtitle: Text('Gérer les autorisations de partage'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.notifications_outlined),
                  title: Text('Notifications'),
                  subtitle: Text('Alertes de matching et confirmations'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _relationLabel(RelationType type) {
  switch (type) {
    case RelationType.parent:
      return 'Parent';
    case RelationType.child:
      return 'Enfant';
    case RelationType.sibling:
      return 'Fratrie';
    case RelationType.partner:
      return 'Conjoint';
  }
}
