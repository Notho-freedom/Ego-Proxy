import 'package:flutter/material.dart';

void main() {
  runApp(const EgoProxyApp());
}

class EgoProxyApp extends StatelessWidget {
  const EgoProxyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF1A73E8),
      brightness: Brightness.light,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ego Proxy',
      theme: ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F9FB),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Color(0xFFF8F9FB),
          surfaceTintColor: Color(0xFFF8F9FB),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          color: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          hintStyle: TextStyle(color: Colors.black.withAlpha(120)),
          prefixIconColor: Colors.black45,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(999),
            borderSide: BorderSide.none,
          ),
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
    Person(id: 'grandpa_f', name: 'Pierre Martin', subtitle: 'Grand-père · 1940'),
    Person(id: 'grandma_f', name: 'Lucie Martin', subtitle: 'Grand-mère · 1942'),
    Person(id: 'grandpa_m', name: 'André Durand', subtitle: 'Grand-père · 1938'),
    Person(id: 'grandma_m', name: 'Claire Durand', subtitle: 'Grand-mère · 1943'),
    Person(id: 'sibling', name: 'Paul Martin', subtitle: 'Frère · 1990'),
    Person(id: 'partner', name: 'Camille Durand', subtitle: 'Conjoint · 1993'),
    Person(id: 'child1', name: 'Lina Martin', subtitle: 'Enfant · 2018'),
    Person(id: 'child2', name: 'Noah Martin', subtitle: 'Enfant · 2021'),
  ];

  static const relations = <Relationship>[
    Relationship(fromId: 'grandpa_f', toId: 'father', type: RelationType.parent),
    Relationship(fromId: 'grandma_f', toId: 'father', type: RelationType.parent),
    Relationship(fromId: 'grandpa_m', toId: 'mother', type: RelationType.parent),
    Relationship(fromId: 'grandma_m', toId: 'mother', type: RelationType.parent),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      selectedTileColor: Theme.of(context).colorScheme.primary.withAlpha(18),
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

class _GraphView extends StatefulWidget {
  const _GraphView();

  @override
  State<_GraphView> createState() => _GraphViewState();
}

class _GraphViewState extends State<_GraphView> {
  final TransformationController _transformController = TransformationController();
  final GlobalKey _viewerKey = GlobalKey();
  String? _selectedPersonId;
  String? _hoveredPersonId;
  final Set<String> _expandedIds = {};
  final Size _canvasSize = const Size(1200, 800);
  late final Map<String, Offset> _positions;

  void _openPersonSheet(BuildContext context, Person person) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _PersonSheet(person: person),
    );
  }

  @override
  void initState() {
    super.initState();
    _positions = {
      'me': const Offset(600, 400),
      'father': const Offset(600, 160),
      'mother': const Offset(760, 230),
      'grandpa_f': const Offset(520, 40),
      'grandma_f': const Offset(680, 40),
      'grandpa_m': const Offset(860, 110),
      'grandma_m': const Offset(940, 190),
      'sibling': const Offset(300, 400),
      'partner': const Offset(900, 400),
      'child1': const Offset(480, 640),
      'child2': const Offset(720, 640),
    };
  }

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  void _setSelected(String id) {
    setState(() => _selectedPersonId = id);
  }

  void _clearSelection() {
    setState(() => _selectedPersonId = null);
  }

  void _setHovered(String? id) {
    if (_hoveredPersonId == id) {
      return;
    }
    setState(() => _hoveredPersonId = id);
  }

  void _zoom(double scaleDelta) {
    final currentMatrix = _transformController.value;
    final currentScale = currentMatrix.getMaxScaleOnAxis();
    final newScale = (currentScale * scaleDelta).clamp(0.6, 2.4);
    final scale = newScale / currentScale;
    _transformController.value = currentMatrix.scaled(scale);
  }

  void _resetView() {
    _transformController.value = Matrix4.identity();
  }

  void _centerOnNode(String id) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final box = _viewerKey.currentContext?.findRenderObject() as RenderBox?;
      final nodePosition = _positions[id];
      if (box == null || nodePosition == null) {
        return;
      }
      final viewportSize = box.size;
      final target = Offset(viewportSize.width / 2, viewportSize.height / 2);
      final translation = target - nodePosition;
      _transformController.value = Matrix4.identity()..translate(translation.dx, translation.dy);
    });
  }

  Set<String> _visibleNodeIds() {
    final visible = <String>{
      'me',
      'father',
      'mother',
      'sibling',
      'partner',
      'child1',
      'child2',
    };

    if (_expandedIds.contains('father')) {
      visible.addAll(['grandpa_f', 'grandma_f']);
    }
    if (_expandedIds.contains('mother')) {
      visible.addAll(['grandpa_m', 'grandma_m']);
    }
    return visible;
  }

  bool _isExpandable(String id) {
    return id == 'father' || id == 'mother';
  }

  void _toggleExpand(String id) {
    setState(() {
      if (_expandedIds.contains(id)) {
        _expandedIds.remove(id);
      } else {
        _expandedIds.add(id);
      }
    });
    _centerOnNode(id);
  }

  void _moveNode(String id, Offset delta) {
    setState(() {
      final current = _positions[id] ?? Offset.zero;
      _positions[id] = Offset(
        (current.dx + delta.dx).clamp(40, _canvasSize.width - 40),
        (current.dy + delta.dy).clamp(40, _canvasSize.height - 40),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Votre arbre centré sur vous', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(
            'Cliquez sur un nœud pour explorer ses relations directes.',
            style: TextStyle(color: Colors.black.withAlpha(153)),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Card(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: InteractiveViewer(
                      transformationController: _transformController,
                      minScale: 0.6,
                      maxScale: 2.4,
                      boundaryMargin: const EdgeInsets.all(120),
                      child: SizedBox(
                        key: _viewerKey,
                        width: _canvasSize.width,
                        height: _canvasSize.height,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: _clearSelection,
                                child: CustomPaint(
                                  painter: _GraphLinesPainter(
                                    positions: _positions,
                                    visibleIds: _visibleNodeIds(),
                                    relations: SampleData.relations,
                                  ),
                                ),
                              ),
                            ),
                            for (final person in SampleData.persons)
                              if (_visibleNodeIds().contains(person.id))
                                _GraphNode(
                                  person: person,
                                  position: _positions[person.id] ?? Offset.zero,
                                  size: person.id == 'me' ? 140 : 96,
                                  isCenter: person.id == 'me',
                                  isSelected: _selectedPersonId == person.id,
                                  isHovered: _hoveredPersonId == person.id,
                                  isExpandable: _isExpandable(person.id),
                                  isExpanded: _expandedIds.contains(person.id),
                                  onExpand: () => _toggleExpand(person.id),
                                  onTap: () {
                                    _setSelected(person.id);
                                    _centerOnNode(person.id);
                                    _openPersonSheet(context, person);
                                  },
                                  onDrag: (delta) => _moveNode(person.id, delta),
                                  onHover: (isHovering) => _setHovered(isHovering ? person.id : null),
                                ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 16,
                    top: 16,
                    child: Column(
                      children: [
                        _GraphActionButton(
                          icon: Icons.add,
                          onTap: () => _zoom(1.15),
                          tooltip: 'Zoom avant',
                        ),
                        const SizedBox(height: 8),
                        _GraphActionButton(
                          icon: Icons.remove,
                          onTap: () => _zoom(0.87),
                          tooltip: 'Zoom arrière',
                        ),
                        const SizedBox(height: 8),
                        _GraphActionButton(
                          icon: Icons.center_focus_strong,
                          onTap: _resetView,
                          tooltip: 'Réinitialiser',
                        ),
                      ],
                    ),
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
    required this.position,
    required this.size,
    required this.onTap,
    required this.onDrag,
    this.isSelected = false,
    this.isHovered = false,
    this.isExpandable = false,
    this.isExpanded = false,
    this.onExpand,
    this.onHover,
    this.isCenter = false,
  });

  final Person person;
  final Offset position;
  final double size;
  final VoidCallback onTap;
  final ValueChanged<Offset> onDrag;
  final bool isSelected;
  final bool isHovered;
  final bool isExpandable;
  final bool isExpanded;
  final VoidCallback? onExpand;
  final ValueChanged<bool>? onHover;
  final bool isCenter;

  @override
  Widget build(BuildContext context) {
    final nodeWidth = size;
    final nodeHeight = size + (person.isVerified ? 36 : 24);

    return Positioned(
      left: position.dx - nodeWidth / 2,
      top: position.dy - nodeHeight / 2,
      child: MouseRegion(
        onEnter: (_) => onHover?.call(true),
        onExit: (_) => onHover?.call(false),
        child: GestureDetector(
          onTap: onTap,
          onPanUpdate: (details) => onDrag(details.delta),
          child: AnimatedScale(
            duration: const Duration(milliseconds: 140),
            scale: isSelected ? 1.03 : 1.0,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: nodeWidth,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isCenter ? const Color(0xFFE8F0FE) : Colors.white,
                    borderRadius: BorderRadius.circular(isCenter ? 24 : 20),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF1A73E8) : const Color(0xFFE3E7F2),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(isHovered ? 30 : 15),
                        blurRadius: isHovered ? 18 : 12,
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
                if (isExpandable)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      elevation: 1,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: onExpand,
                        child: SizedBox(
                          height: 22,
                          width: 22,
                          child: Icon(
                            isExpanded ? Icons.remove : Icons.add,
                            size: 14,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GraphLinesPainter extends CustomPainter {
  _GraphLinesPainter({
    required this.positions,
    required this.visibleIds,
    required this.relations,
  });

  final Map<String, Offset> positions;
  final Set<String> visibleIds;
  final List<Relationship> relations;

  @override
  void paint(Canvas canvas, Size size) {
    for (final relation in relations) {
      if (!visibleIds.contains(relation.fromId) || !visibleIds.contains(relation.toId)) {
        continue;
      }
      final from = positions[relation.fromId];
      final to = positions[relation.toId];
      if (from == null || to == null) {
        continue;
      }

      final paint = Paint()
        ..color = _relationColor(relation.type)
        ..strokeWidth = 2;

      canvas.drawLine(from, to, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

Color _relationColor(RelationType type) {
  switch (type) {
    case RelationType.parent:
    case RelationType.child:
      return const Color(0xFFB8C7F3);
    case RelationType.sibling:
      return const Color(0xFFB5E5C8);
    case RelationType.partner:
      return const Color(0xFFF2B5B5);
  }
}

class _GraphActionButton extends StatelessWidget {
  const _GraphActionButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 1,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Tooltip(
          message: tooltip,
          child: SizedBox(
            height: 36,
            width: 36,
            child: Icon(icon, size: 18, color: Colors.black87),
          ),
        ),
      ),
    );
  }
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
          const Text('Relations directes', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
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
          const Text('Documents & preuves', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
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
          const Text('Paramètres', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Card(
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

class _PersonSheet extends StatelessWidget {
  const _PersonSheet({required this.person});

  final Person person;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    person.name.substring(0, 1),
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        person.name,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(person.subtitle, style: const TextStyle(color: Colors.black54)),
                    ],
                  ),
                ),
                if (person.isVerified)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCF6E8),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text('Vérifié', style: TextStyle(fontSize: 11, color: Color(0xFF2E7D32))),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: DefaultTabController(
                length: 3,
                child: Column(
                  children: [
                    const TabBar(
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.black54,
                      indicatorColor: Color(0xFF1A73E8),
                      tabs: [
                        Tab(text: 'Profil'),
                        Tab(text: 'Relations'),
                        Tab(text: 'Documents'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _PersonProfileTab(person: person),
                          const _PersonRelationsTab(),
                          const _PersonDocumentsTab(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PersonProfileTab extends StatelessWidget {
  const _PersonProfileTab({required this.person});

  final Person person;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Identité'),
            subtitle: Text(person.name),
          ),
        ),
        const SizedBox(height: 12),
        const Card(
          child: ListTile(
            leading: Icon(Icons.cake_outlined),
            title: Text('Date de naissance'),
            subtitle: Text('Non renseignée'),
          ),
        ),
        const SizedBox(height: 12),
        const Card(
          child: ListTile(
            leading: Icon(Icons.place_outlined),
            title: Text('Lieu'),
            subtitle: Text('Non renseigné'),
          ),
        ),
      ],
    );
  }
}

class _PersonRelationsTab extends StatelessWidget {
  const _PersonRelationsTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        Card(
          child: ListTile(
            leading: Icon(Icons.family_restroom_outlined),
            title: Text('Parents'),
            subtitle: Text('2 relations confirmées'),
          ),
        ),
        SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: Icon(Icons.people_outline),
            title: Text('Fratrie'),
            subtitle: Text('1 relation proposée'),
          ),
        ),
        SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: Icon(Icons.favorite_border),
            title: Text('Conjoint'),
            subtitle: Text('1 relation confirmée'),
          ),
        ),
      ],
    );
  }
}

class _PersonDocumentsTab extends StatelessWidget {
  const _PersonDocumentsTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        Card(
          child: ListTile(
            leading: Icon(Icons.description_outlined),
            title: Text('Acte de naissance'),
            subtitle: Text('Validé'),
          ),
        ),
        SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: Icon(Icons.description_outlined),
            title: Text('Livret de famille'),
            subtitle: Text('En attente'),
          ),
        ),
      ],
    );
  }
}
