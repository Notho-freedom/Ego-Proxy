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
    Person(id: 'sister', name: 'Emma Martin', subtitle: 'Sœur · 1995'),
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
    Relationship(fromId: 'me', toId: 'sister', type: RelationType.sibling),
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
  final Size _canvasSize = const Size(1200, 800);
  final List<Person> _persons = List<Person>.from(SampleData.persons);
  final List<Relationship> _relations = List<Relationship>.from(SampleData.relations);

  String _rootId = 'me';
  String? _hoveredBranchId;

  void _openPersonSheet(BuildContext context, Person person) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _PersonSheet(
        person: person,
        onUpdate: (updated) => _updatePerson(updated),
      ),
    );
  }

  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  void _setHovered(String? id) {
    if (_hoveredBranchId == id) {
      return;
    }
    setState(() => _hoveredBranchId = id);
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

  void _centerOnNode(Offset position) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final box = _viewerKey.currentContext?.findRenderObject() as RenderBox?;
      if (box == null) {
        return;
      }
      final viewportSize = box.size;
      final target = Offset(viewportSize.width / 2, viewportSize.height / 2);
      final translation = target - position;
      _transformController.value = Matrix4.identity()..translate(translation.dx, translation.dy);
    });
  }
  List<Person> _parentsOf(String id) {
    return _relations
        .where((rel) => rel.type == RelationType.parent && rel.toId == id)
      .map((rel) => _personById(rel.fromId))
        .whereType<Person>()
        .toList();
  }

  List<Person> _childrenOf(String id) {
    return _relations
        .where((rel) => rel.type == RelationType.child && rel.fromId == id)
      .map((rel) => _personById(rel.toId))
        .whereType<Person>()
        .toList();
  }

  List<Person> _partnersOf(String id) {
    return _relations
        .where((rel) => rel.type == RelationType.partner && (rel.fromId == id || rel.toId == id))
      .map((rel) => _personById(rel.fromId == id ? rel.toId : rel.fromId))
        .whereType<Person>()
        .toList();
  }

  List<Person> _siblingsOf(String id) {
    return _relations
        .where((rel) => rel.type == RelationType.sibling && (rel.fromId == id || rel.toId == id))
      .map((rel) => _personById(rel.fromId == id ? rel.toId : rel.fromId))
        .whereType<Person>()
        .toList();
  }

  List<Person> _grandParentsOf(String id) {
    final parents = _parentsOf(id);
    final grand = <Person>[];
    for (final parent in parents) {
      grand.addAll(_parentsOf(parent.id));
    }
    return grand;
  }

  void _setRoot(String id) {
    setState(() => _rootId = id);
    _resetView();
  }

  Person? _personById(String id) {
    return _persons.firstWhere((person) => person.id == id, orElse: () => SampleData.me);
  }

  void _addRelation({
    required String branchId,
    required String name,
    required String subtitle,
    required int year,
  }) {
    final newId = '${branchId}_${DateTime.now().millisecondsSinceEpoch}';
    final resolvedSubtitle = _resolveSubtitle(subtitle, year);
    final newPerson = Person(id: newId, name: name, subtitle: resolvedSubtitle);

    setState(() {
      _persons.add(newPerson);
      switch (branchId) {
        case 'parents':
          _relations.add(Relationship(fromId: newId, toId: _rootId, type: RelationType.parent));
          break;
        case 'grandparents':
          final parents = _parentsOf(_rootId);
          if (parents.isNotEmpty) {
            _relations.add(Relationship(fromId: newId, toId: parents.first.id, type: RelationType.parent));
          } else {
            _relations.add(Relationship(fromId: newId, toId: _rootId, type: RelationType.parent));
          }
          break;
        case 'brother':
        case 'sister':
          _relations.add(Relationship(fromId: _rootId, toId: newId, type: RelationType.sibling));
          break;
        case 'partner':
          _relations.add(Relationship(fromId: _rootId, toId: newId, type: RelationType.partner));
          break;
        case 'children':
          _relations.add(Relationship(fromId: _rootId, toId: newId, type: RelationType.child));
          break;
      }
    });

    _setRoot(newId);
  }

  void _updatePerson(Person updated) {
    setState(() {
      final index = _persons.indexWhere((person) => person.id == updated.id);
      if (index == -1) {
        return;
      }
      _persons[index] = updated;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Votre arbre centré sur vous', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                    SizedBox(height: 6),
                    Text('Cliquez sur une branche pour naviguer.', style: TextStyle(color: Colors.black54)),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: _resetView,
                icon: const Icon(Icons.center_focus_strong, size: 18),
                label: const Text('Recentrer'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const _GraphLegend(),
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
                              child: Stack(
                                children: [
                                  Positioned.fill(child: _GraphBackgroundGrid()),
                                  _RecursiveGraph(
                                    root: _personById(_rootId) ?? SampleData.me,
                                    parents: _parentsOf(_rootId),
                                    grandParents: _grandParentsOf(_rootId),
                                    siblings: _siblingsOf(_rootId),
                                    partners: _partnersOf(_rootId),
                                    children: _childrenOf(_rootId),
                                    canvasSize: _canvasSize,
                                    hoveredId: _hoveredBranchId,
                                    onHover: _setHovered,
                                    onOpenPerson: (person) => _setRoot(person.id),
                                    onOpenSheet: (person) => _openPersonSheet(context, person),
                                    onCenter: _centerOnNode,
                                    onAddRelation: (branchId) => _showAddRelationSheet(
                                      context,
                                      branchId,
                                      _extractYear((_personById(_rootId)?.subtitle ?? '')),
                                      (name, subtitle, year) => _addRelation(
                                        branchId: branchId,
                                        name: name,
                                        subtitle: subtitle,
                                        year: year,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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

class _RecursiveGraph extends StatelessWidget {
  const _RecursiveGraph({
    required this.root,
    required this.parents,
    required this.grandParents,
    required this.siblings,
    required this.partners,
    required this.children,
    required this.canvasSize,
    required this.hoveredId,
    required this.onHover,
    required this.onOpenPerson,
    required this.onOpenSheet,
    required this.onCenter,
    required this.onAddRelation,
  });

  final Person root;
  final List<Person> parents;
  final List<Person> grandParents;
  final List<Person> siblings;
  final List<Person> partners;
  final List<Person> children;
  final Size canvasSize;
  final String? hoveredId;
  final ValueChanged<String?> onHover;
  final ValueChanged<Person> onOpenPerson;
  final ValueChanged<Person> onOpenSheet;
  final ValueChanged<Offset> onCenter;
  final ValueChanged<String> onAddRelation;

  @override
  Widget build(BuildContext context) {
    final center = Offset(canvasSize.width / 2, canvasSize.height / 2);

    final branches = <_BranchNodeData>[
      _BranchNodeData(
        id: 'parents',
        label: 'Parents',
        subtitle: parents.isNotEmpty ? _namesPreview(parents) : 'Ajouter',
        targets: parents,
        position: center + const Offset(0, -220),
      ),
      _BranchNodeData(
        id: 'grandparents',
        label: 'Grands-parents',
        subtitle: grandParents.isNotEmpty ? _namesPreview(grandParents) : 'Ajouter',
        targets: grandParents,
        position: center + const Offset(0, -340),
      ),
      _BranchNodeData(
        id: 'brother',
        label: 'Frère',
        subtitle: siblings.isNotEmpty ? _namesPreview(siblings) : 'Ajouter',
        targets: siblings,
        position: center + const Offset(-260, -20),
      ),
      _BranchNodeData(
        id: 'sister',
        label: 'Sœur',
        subtitle: siblings.isNotEmpty ? _namesPreview(siblings) : 'Ajouter',
        targets: siblings,
        position: center + const Offset(-260, 60),
      ),
      _BranchNodeData(
        id: 'partner',
        label: 'Conjoint',
        subtitle: partners.isNotEmpty ? _namesPreview(partners) : 'Ajouter',
        targets: partners,
        position: center + const Offset(260, 0),
      ),
      _BranchNodeData(
        id: 'children',
        label: 'Enfants',
        subtitle: children.isNotEmpty ? _namesPreview(children) : 'Ajouter',
        targets: children,
        position: center + const Offset(0, 260),
      ),
    ];

    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _GraphLinesPainter(
              center: center,
              branches: branches,
            ),
          ),
        ),
        _CenterPersonCard(
          person: root,
          position: center,
          onTap: () => onOpenSheet(root),
        ),
        for (final branch in branches)
          _RelationBranchBubble(
            data: branch,
            isHovered: hoveredId == branch.id,
            onHover: (value) => onHover(value ? branch.id : null),
            onTap: () {
              if (branch.targets.isEmpty) {
                onAddRelation(branch.id);
                return;
              }
              if (branch.targets.length == 1) {
                onCenter(branch.position);
                onOpenPerson(branch.targets.first);
                return;
              }
              _showBranchSelector(context, branch, onOpenPerson);
            },
          ),
      ],
    );
  }
}

class _BranchNodeData {
  const _BranchNodeData({
    required this.id,
    required this.label,
    required this.subtitle,
    required this.targets,
    required this.position,
  });

  final String id;
  final String label;
  final String subtitle;
  final List<Person> targets;
  final Offset position;
}

String _namesPreview(List<Person> people) {
  if (people.isEmpty) {
    return 'Ajouter';
  }
  if (people.length == 1) {
    return people.first.name;
  }
  return '${people.first.name} +${people.length - 1}';
}

class _CenterPersonCard extends StatelessWidget {
  const _CenterPersonCard({
    required this.person,
    required this.position,
    required this.onTap,
  });

  final Person person;
  final Offset position;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const size = 160.0;
    return Positioned(
      left: position.dx - size / 2,
      top: position.dy - size / 2,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F0FE),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF1A73E8), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(20),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(person.name.substring(0, 1), style: const TextStyle(color: Colors.white, fontSize: 18)),
              ),
              const SizedBox(height: 10),
              Text(person.name, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(person.subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: Colors.black54)),
            ],
          ),
        ),
      ),
    );
  }
}

class _RelationBranchBubble extends StatelessWidget {
  const _RelationBranchBubble({
    required this.data,
    required this.isHovered,
    required this.onHover,
    required this.onTap,
  });

  final _BranchNodeData data;
  final bool isHovered;
  final ValueChanged<bool> onHover;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: data.position.dx - 90,
      top: data.position.dy - 36,
      child: MouseRegion(
        onEnter: (_) => onHover(true),
        onExit: (_) => onHover(false),
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE3E7F2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(isHovered ? 25 : 12),
                  blurRadius: isHovered ? 16 : 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(30),
                  child: Icon(
                    data.targets.isEmpty ? Icons.add : Icons.people,
                    size: 14,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data.label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(data.subtitle, style: const TextStyle(fontSize: 10, color: Colors.black54)),
                  ],
                ),
                if (data.targets.length > 1)
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(Icons.expand_more, size: 16, color: Colors.black45),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _showBranchSelector(BuildContext context, _BranchNodeData branch, ValueChanged<Person> onSelect) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(branch.label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: branch.targets.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final person = branch.targets[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(30),
                        child: Text(person.name.substring(0, 1)),
                      ),
                      title: Text(person.name),
                      subtitle: Text(person.subtitle),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.of(context).pop();
                        onSelect(person);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}

void _showAddRelationSheet(
  BuildContext context,
  String branchId,
  int? rootYear,
  void Function(String name, String subtitle, int year) onSubmit,
) {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final subtitleController = TextEditingController();
  final yearController = TextEditingController();

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.fromLTRB(24, 8, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ajouter un lien · ${_branchTitle(branchId)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nom complet',
                      hintText: 'Ex. Jean Martin',
                    ),
                    validator: _validateName,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: yearController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Année de naissance',
                      hintText: 'Ex. 1965',
                    ),
                    validator: (value) => _validateYearStrict(value, branchId, rootYear),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: subtitleController,
                    decoration: const InputDecoration(
                      labelText: 'Détails',
                      hintText: 'Ex. Né(e) en 1965',
                    ),
                    validator: _validateSubtitleOptional,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  if (!(formKey.currentState?.validate() ?? false)) {
                    return;
                  }
                  final year = int.parse(yearController.text.trim());
                  onSubmit(nameController.text.trim(), subtitleController.text.trim(), year);
                  Navigator.of(context).pop();
                },
                child: const Text('Ajouter'),
              ),
            ),
          ],
        ),
      );
    },
  ).whenComplete(() {
    nameController.dispose();
    subtitleController.dispose();
    yearController.dispose();
  });
}

String? _validateName(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) {
    return 'Le nom est requis.';
  }
  if (text.length < 2) {
    return 'Le nom est trop court.';
  }
  if (RegExp(r'\d').hasMatch(text)) {
    return 'Le nom ne doit pas contenir de chiffres.';
  }
  return null;
}

String? _validateYearStrict(String? value, String branchId, int? rootYear) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) {
    return 'Année requise.';
  }
  final year = int.tryParse(text);
  if (year == null || text.length != 4) {
    return 'Année invalide.';
  }
  final currentYear = DateTime.now().year;
  if (year < 1900 || year > currentYear + 1) {
    return 'Année invalide.';
  }
  if (rootYear == null) {
    return 'Année du profil central requise.';
  }

  switch (branchId) {
    case 'parents':
      if (year > rootYear - 12) {
        return 'Un parent doit avoir au moins 12 ans de plus.';
      }
      break;
    case 'grandparents':
      if (year > rootYear - 24) {
        return 'Un grand-parent doit avoir au moins 24 ans de plus.';
      }
      break;
    case 'children':
      if (year < rootYear + 12) {
        return 'Un enfant doit avoir au moins 12 ans de moins.';
      }
      break;
    case 'brother':
    case 'sister':
      if (year < rootYear - 25 || year > rootYear + 25) {
        return 'Un(e) frère/sœur doit être dans un écart de ±25 ans.';
      }
      break;
    case 'partner':
      if (year < rootYear - 40 || year > rootYear + 40) {
        return 'Un conjoint doit être dans un écart de ±40 ans.';
      }
      break;
  }
  return null;
}

String? _validateSubtitleOptional(String? value) {
  return null;
}

int? _extractYear(String text) {
  final match = RegExp(r'(19\d{2}|20\d{2})').firstMatch(text);
  if (match == null) {
    return null;
  }
  return int.tryParse(match.group(0) ?? '');
}

String _resolveSubtitle(String subtitle, int year) {
  final trimmed = subtitle.trim();
  if (trimmed.isEmpty) {
    return 'Né(e) en $year';
  }
  if (_extractYear(trimmed) != null) {
    return trimmed;
  }
  return '$trimmed · $year';
}

String _branchTitle(String branchId) {
  switch (branchId) {
    case 'parents':
      return 'Parents';
    case 'grandparents':
      return 'Grands-parents';
    case 'brother':
      return 'Frère';
    case 'sister':
      return 'Sœur';
    case 'partner':
      return 'Conjoint';
    case 'children':
      return 'Enfants';
    default:
      return 'Relation';
  }
}

class _GraphLinesPainter extends CustomPainter {
  _GraphLinesPainter({
    required this.center,
    required this.branches,
  });

  final Offset center;
  final List<_BranchNodeData> branches;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFCBD5F1)
      ..strokeWidth = 2;

    for (final branch in branches) {
      canvas.drawLine(center, branch.position, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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

class _GraphLegend extends StatelessWidget {
  const _GraphLegend();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: const [
        _LegendChip(label: 'Parent/Enfant', color: Color(0xFFB8C7F3)),
        _LegendChip(label: 'Fratrie', color: Color(0xFFB5E5C8)),
        _LegendChip(label: 'Conjoint', color: Color(0xFFF2B5B5)),
        _LegendChip(label: 'Cliquez sur une branche', color: Color(0xFFE3E7F2)),
      ],
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color),
      ),
      child: Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
    );
  }
}

class _GraphBackgroundGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GridPainter(),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFEFF2F8)
      ..strokeWidth = 1;

    const step = 80.0;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
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
    return const _DocumentsViewBody();
  }
}

class _DocumentsViewBody extends StatefulWidget {
  const _DocumentsViewBody();

  @override
  State<_DocumentsViewBody> createState() => _DocumentsViewBodyState();
}

class _DocumentsViewBodyState extends State<_DocumentsViewBody> {
  final List<_DocumentItem> _documents = [
    const _DocumentItem(title: 'Acte de naissance', status: _DocStatus.approved),
    const _DocumentItem(title: 'Livret de famille', status: _DocStatus.pending),
    const _DocumentItem(title: 'Pièce d\'identité', status: _DocStatus.rejected),
  ];

  void _openAddDocumentSheet() {
    _showAddDocumentSheet(context, (title, status) {
      setState(() {
        _documents.insert(0, _DocumentItem(title: title, status: status));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Documents & preuves', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
              ),
              FilledButton.icon(
                onPressed: _openAddDocumentSheet,
                icon: const Icon(Icons.upload_file),
                label: const Text('Ajouter'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: _documents.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final doc = _documents[index];
                return _DocumentTile(
                  title: doc.title,
                  status: doc.status.label,
                  color: doc.status.color,
                  chip: _StatusChip(label: doc.status.label, color: doc.status.color),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentTile extends StatelessWidget {
  const _DocumentTile({
    required this.title,
    required this.status,
    required this.color,
    required this.chip,
  });

  final String title;
  final String status;
  final Color color;
  final Widget chip;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.description_outlined),
        title: Text(title),
        subtitle: Text(status, style: TextStyle(color: color)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            chip,
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right),
          ],
        ),
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

class _PersonSheet extends StatefulWidget {
  const _PersonSheet({required this.person, required this.onUpdate});

  final Person person;
  final ValueChanged<Person> onUpdate;

  @override
  State<_PersonSheet> createState() => _PersonSheetState();
}

class _PersonSheetState extends State<_PersonSheet> {
  late Person _person;

  @override
  void initState() {
    super.initState();
    _person = widget.person;
  }

  void _openEditSheet() {
    _showEditPersonSheet(
      context,
      _person,
      (updated) {
        widget.onUpdate(updated);
        setState(() => _person = updated);
      },
    );
  }

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
                    _person.name.substring(0, 1),
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _person.name,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(_person.subtitle, style: const TextStyle(color: Colors.black54)),
                    ],
                  ),
                ),
                if (_person.isVerified)
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
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _openEditSheet,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Modifier'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.link),
                    label: const Text('Relier'),
                  ),
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
                          _PersonProfileTab(person: _person),
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
            subtitle: Text('Renseignée'),
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
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.verified_outlined),
            title: const Text('Niveau de confiance'),
            subtitle: Text(person.isVerified ? 'Élevé' : 'Moyen'),
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
            trailing: Icon(Icons.chevron_right),
          ),
        ),
        SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: Icon(Icons.people_outline),
            title: Text('Fratrie'),
            subtitle: Text('1 relation proposée'),
            trailing: Icon(Icons.chevron_right),
          ),
        ),
        SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: Icon(Icons.favorite_border),
            title: Text('Conjoint'),
            subtitle: Text('1 relation confirmée'),
            trailing: Icon(Icons.chevron_right),
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
            trailing: Icon(Icons.chevron_right),
          ),
        ),
        SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: Icon(Icons.description_outlined),
            title: Text('Livret de famille'),
            subtitle: Text('En attente'),
            trailing: Icon(Icons.chevron_right),
          ),
        ),
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

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 11)),
    );
  }
}

enum _DocStatus { approved, pending, rejected }

extension on _DocStatus {
  String get label {
    switch (this) {
      case _DocStatus.approved:
        return 'Validé';
      case _DocStatus.pending:
        return 'En attente';
      case _DocStatus.rejected:
        return 'Rejeté';
    }
  }

  Color get color {
    switch (this) {
      case _DocStatus.approved:
        return const Color(0xFF2E7D32);
      case _DocStatus.pending:
        return const Color(0xFFF57C00);
      case _DocStatus.rejected:
        return const Color(0xFFC62828);
    }
  }
}

class _DocumentItem {
  const _DocumentItem({required this.title, required this.status});

  final String title;
  final _DocStatus status;
}

void _showAddDocumentSheet(
  BuildContext context,
  void Function(String title, _DocStatus status) onSubmit,
) {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  _DocStatus status = _DocStatus.pending;

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.fromLTRB(24, 8, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: StatefulBuilder(
          builder: (context, setModalState) {
            return Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ajouter un document', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Titre',
                      hintText: 'Ex. Acte de naissance',
                    ),
                    validator: (value) {
                      if ((value ?? '').trim().isEmpty) {
                        return 'Le titre est requis.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<_DocStatus>(
                    value: status,
                    decoration: const InputDecoration(labelText: 'Statut'),
                    items: _DocStatus.values
                        .map((status) => DropdownMenuItem(
                              value: status,
                              child: Text(status.label),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setModalState(() => status = value);
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        if (!(formKey.currentState?.validate() ?? false)) {
                          return;
                        }
                        onSubmit(titleController.text.trim(), status);
                        Navigator.of(context).pop();
                      },
                      child: const Text('Ajouter'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  ).whenComplete(() => titleController.dispose());
}

void _showEditPersonSheet(
  BuildContext context,
  Person person,
  ValueChanged<Person> onSubmit,
) {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: person.name);
  final subtitleController = TextEditingController(text: person.subtitle);
  bool verified = person.isVerified;

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.fromLTRB(24, 8, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: StatefulBuilder(
          builder: (context, setModalState) {
            return Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Modifier le profil', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nom complet'),
                    validator: _validateName,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: subtitleController,
                    decoration: const InputDecoration(labelText: 'Détails'),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    value: verified,
                    onChanged: (value) => setModalState(() => verified = value),
                    title: const Text('Vérifié'),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        if (!(formKey.currentState?.validate() ?? false)) {
                          return;
                        }
                        onSubmit(Person(
                          id: person.id,
                          name: nameController.text.trim(),
                          subtitle: subtitleController.text.trim(),
                          isVerified: verified,
                        ));
                        Navigator.of(context).pop();
                      },
                      child: const Text('Enregistrer'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  ).whenComplete(() {
    nameController.dispose();
    subtitleController.dispose();
  });
}
