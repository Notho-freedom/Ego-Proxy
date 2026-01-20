part of '../main.dart';

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
  bool _showFocusRing = false;
  final Map<String, Offset> _branchOffsets = {};
  bool _panEnabled = true;

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

  @override
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
    _transformController.value = Matrix4.copy(currentMatrix)..scaleByDouble(scale, scale, 1.0, 1.0);
  }

  double get _currentScale => _transformController.value.getMaxScaleOnAxis();

  void _resetView() {
    _transformController.value = Matrix4.identity();
    _flashCenter();
  }

  void _centerOnNode(Offset position) {
    _flashCenter();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final box = _viewerKey.currentContext?.findRenderObject() as RenderBox?;
      if (box == null) {
        return;
      }
      final viewportSize = box.size;
      final target = Offset(viewportSize.width / 2, viewportSize.height / 2);
      final translation = target - position;
      _transformController.value = Matrix4.translationValues(translation.dx, translation.dy, 0);
    });
  }

  void _flashCenter() {
    setState(() => _showFocusRing = true);
    Future<void>.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() => _showFocusRing = false);
      }
    });
  }

  void _updateBranchOffset(String id, Offset delta) {
    final scaledDelta = Offset(delta.dx / _currentScale, delta.dy / _currentScale);
    setState(() {
      final current = _branchOffsets[id] ?? Offset.zero;
      _branchOffsets[id] = current + scaledDelta;
    });
  }

  void _setPanEnabled(bool value) {
    if (_panEnabled == value) {
      return;
    }
    setState(() => _panEnabled = value);
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
    setState(() {
      _rootId = id;
      _branchOffsets.clear();
    });
    _resetView();
  }

  Person get _rootPerson => _personById(_rootId) ?? SampleData.me;

  int _relatedCount(String id) {
    return _relations.where((rel) => rel.fromId == id || rel.toId == id).length;
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
    final root = _rootPerson;
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
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(
                avatar: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(root.name.substring(0, 1), style: const TextStyle(color: Colors.white)),
                ),
                label: Text('Centre: ${root.name}'),
              ),
              _CountChip(label: 'Relations', count: _relatedCount(_rootId)),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Card(
              child: Stack(
                children: [
                  Positioned(
                    left: _canvasSize.width / 2 - 100,
                    top: _canvasSize.height / 2 - 100,
                    child: IgnorePointer(
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 250),
                        opacity: _showFocusRing ? 1 : 0,
                        child: AnimatedScale(
                          duration: const Duration(milliseconds: 350),
                          scale: _showFocusRing ? 1 : 0.92,
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF1A73E8).withAlpha(70), width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF1A73E8).withAlpha(25),
                                  blurRadius: 32,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: InteractiveViewer(
                      transformationController: _transformController,
                      minScale: 0.6,
                      maxScale: 2.4,
                      panEnabled: _panEnabled,
                      scaleEnabled: _panEnabled,
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
                                    branchOffsets: _branchOffsets,
                                    hoveredId: _hoveredBranchId,
                                    onHover: _setHovered,
                                    onOpenPerson: (person) => _setRoot(person.id),
                                    onOpenSheet: (person) => _openPersonSheet(context, person),
                                    onCenter: _centerOnNode,
                                    onDragStateChange: _setPanEnabled,
                                    onDragBranch: _updateBranchOffset,
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
                  Positioned(
                    left: 16,
                    bottom: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(230),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE3E7F2)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(10),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.pan_tool_alt_outlined, size: 16, color: Colors.black54),
                          SizedBox(width: 6),
                          Text('Glisser pour déplacer · Molette pour zoomer', style: TextStyle(color: Colors.black54)),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: _GraphMiniToolbar(
                      onAdd: () => _showAddRelationSheet(
                        context,
                        'parents',
                        _extractYear((_personById(_rootId)?.subtitle ?? '')),
                        (name, subtitle, year) => _addRelation(
                          branchId: 'parents',
                          name: name,
                          subtitle: subtitle,
                          year: year,
                        ),
                      ),
                      onShare: () {},
                      onExport: () {},
                    ),
                  ),
                  const Positioned(
                    left: 16,
                    top: 16,
                    child: _GraphMiniLegend(),
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
    required this.branchOffsets,
    required this.hoveredId,
    required this.onHover,
    required this.onOpenPerson,
    required this.onOpenSheet,
    required this.onCenter,
    required this.onDragStateChange,
    required this.onDragBranch,
    required this.onAddRelation,
  });

  final Person root;
  final List<Person> parents;
  final List<Person> grandParents;
  final List<Person> siblings;
  final List<Person> partners;
  final List<Person> children;
  final Size canvasSize;
  final Map<String, Offset> branchOffsets;
  final String? hoveredId;
  final ValueChanged<String?> onHover;
  final ValueChanged<Person> onOpenPerson;
  final ValueChanged<Person> onOpenSheet;
  final ValueChanged<Offset> onCenter;
  final ValueChanged<bool> onDragStateChange;
  final void Function(String id, Offset delta) onDragBranch;
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
        position: center + const Offset(0, -220) + (branchOffsets['parents'] ?? Offset.zero),
        color: _branchColor('parents'),
      ),
      _BranchNodeData(
        id: 'grandparents',
        label: 'Grands-parents',
        subtitle: grandParents.isNotEmpty ? _namesPreview(grandParents) : 'Ajouter',
        targets: grandParents,
        position: center + const Offset(0, -340) + (branchOffsets['grandparents'] ?? Offset.zero),
        color: _branchColor('grandparents'),
      ),
      _BranchNodeData(
        id: 'brother',
        label: 'Frère',
        subtitle: siblings.isNotEmpty ? _namesPreview(siblings) : 'Ajouter',
        targets: siblings,
        position: center + const Offset(-260, -20) + (branchOffsets['brother'] ?? Offset.zero),
        color: _branchColor('brother'),
      ),
      _BranchNodeData(
        id: 'sister',
        label: 'Sœur',
        subtitle: siblings.isNotEmpty ? _namesPreview(siblings) : 'Ajouter',
        targets: siblings,
        position: center + const Offset(-260, 60) + (branchOffsets['sister'] ?? Offset.zero),
        color: _branchColor('sister'),
      ),
      _BranchNodeData(
        id: 'partner',
        label: 'Conjoint',
        subtitle: partners.isNotEmpty ? _namesPreview(partners) : 'Ajouter',
        targets: partners,
        position: center + const Offset(260, 0) + (branchOffsets['partner'] ?? Offset.zero),
        color: _branchColor('partner'),
      ),
      _BranchNodeData(
        id: 'children',
        label: 'Enfants',
        subtitle: children.isNotEmpty ? _namesPreview(children) : 'Ajouter',
        targets: children,
        position: center + const Offset(0, 260) + (branchOffsets['children'] ?? Offset.zero),
        color: _branchColor('children'),
      ),
    ];

    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _GraphLinesPainter(
              center: center,
              branches: branches,
              hoveredId: hoveredId,
            ),
          ),
        ),
        _CenterPersonCard(
          person: root,
          position: center,
          onTap: () => onOpenSheet(root),
        ),
        for (var i = 0; i < branches.length; i++)
          _RelationBranchBubble(
            data: branches[i],
            isHovered: hoveredId == branches[i].id,
            delayMs: 80 * i,
            onDrag: (delta) => onDragBranch(branches[i].id, delta),
            onDragStateChange: onDragStateChange,
            onHover: (value) => onHover(value ? branches[i].id : null),
            onTap: () {
              final branch = branches[i];
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
    required this.color,
  });

  final String id;
  final String label;
  final String subtitle;
  final List<Person> targets;
  final Offset position;
  final Color color;
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

Color _branchColor(String branchId) {
  switch (branchId) {
    case 'parents':
    case 'grandparents':
      return const Color(0xFFB8C7F3);
    case 'brother':
    case 'sister':
      return const Color(0xFFB5E5C8);
    case 'partner':
      return const Color(0xFFF2B5B5);
    case 'children':
      return const Color(0xFFB8C7F3);
    default:
      return const Color(0xFFE3E7F2);
  }
}

class _CenterPersonCard extends StatefulWidget {
  const _CenterPersonCard({
    required this.person,
    required this.position,
    required this.onTap,
  });

  final Person person;
  final Offset position;
  final VoidCallback onTap;

  @override
  State<_CenterPersonCard> createState() => _CenterPersonCardState();
}

class _CenterPersonCardState extends State<_CenterPersonCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));
    _scale = Tween<double>(begin: 0.985, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const size = 160.0;
    return Positioned(
      left: widget.position.dx - size / 2,
      top: widget.position.dy - size / 2,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          child: ScaleTransition(
            scale: _scale,
            child: Container(
              width: size,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F0FE),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF1A73E8), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1A73E8).withAlpha(35),
                    blurRadius: 20,
                    offset: const Offset(0, 12),
                  ),
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
                    child: Text(widget.person.name.substring(0, 1), style: const TextStyle(color: Colors.white, fontSize: 18)),
                  ),
                  const SizedBox(height: 10),
                  Text(widget.person.name, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(
                    widget.person.subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                ],
              ),
            ),
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
    required this.delayMs,
    required this.onDrag,
    required this.onDragStateChange,
    required this.onHover,
    required this.onTap,
  });

  final _BranchNodeData data;
  final bool isHovered;
  final int delayMs;
  final ValueChanged<Offset> onDrag;
  final ValueChanged<bool> onDragStateChange;
  final ValueChanged<bool> onHover;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: data.position.dx - 90,
      top: data.position.dy - 36,
      child: _StaggeredAppear(
        delayMs: delayMs,
        child: MouseRegion(
          onEnter: (_) => onHover(true),
          onExit: (_) => onHover(false),
          child: GestureDetector(
            onTap: onTap,
            onPanStart: (_) => onDragStateChange(false),
            onPanUpdate: (details) => onDrag(details.delta),
            onPanEnd: (_) => onDragStateChange(true),
            onPanCancel: () => onDragStateChange(true),
            child: AnimatedScale(
              duration: const Duration(milliseconds: 140),
              scale: isHovered ? 1.03 : 1,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 140),
                opacity: isHovered ? 1 : 0.92,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 140),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: data.color.withAlpha(120)),
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
                        backgroundColor: data.color.withAlpha(28),
                        child: Icon(
                          data.targets.isEmpty ? Icons.add : Icons.people,
                          size: 14,
                          color: data.color,
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
                      if (data.targets.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: data.color.withAlpha(18),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${data.targets.length}',
                            style: TextStyle(
                              color: data.color,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      if (data.targets.length > 1)
                        const Padding(
                          padding: EdgeInsets.only(left: 6),
                          child: Icon(Icons.expand_more, size: 16, color: Colors.black45),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StaggeredAppear extends StatefulWidget {
  const _StaggeredAppear({required this.child, required this.delayMs});

  final Widget child;
  final int delayMs;

  @override
  State<_StaggeredAppear> createState() => _StaggeredAppearState();
}

class _StaggeredAppearState extends State<_StaggeredAppear> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 320));
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _offset = Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    Future<void>.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _offset,
        child: widget.child,
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
                separatorBuilder: (context, index) => const SizedBox(height: 8),
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
    required this.hoveredId,
  });

  final Offset center;
  final List<_BranchNodeData> branches;
  final String? hoveredId;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..strokeWidth = 2;

    for (final branch in branches) {
      final isHovered = hoveredId != null && branch.id == hoveredId;
      paint
        ..color = branch.color.withAlpha(isHovered ? 180 : 90)
        ..strokeWidth = isHovered ? 2.6 : 1.6;
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
    final borderColor = const Color(0xFFE3E7F2);
    final iconColor = Theme.of(context).colorScheme.primary;
    return Material(
      color: Colors.white,
      shape: CircleBorder(side: BorderSide(color: borderColor)),
      elevation: 1,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Tooltip(
          message: tooltip,
          child: SizedBox(
            height: 36,
            width: 36,
            child: Icon(icon, size: 18, color: iconColor),
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

class _GraphMiniLegend extends StatelessWidget {
  const _GraphMiniLegend();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(235),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE3E7F2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Wrap(
        spacing: 10,
        children: const [
          _MiniLegendDot(label: 'Parent/Enfant', color: Color(0xFFB8C7F3)),
          _MiniLegendDot(label: 'Fratrie', color: Color(0xFFB5E5C8)),
          _MiniLegendDot(label: 'Conjoint', color: Color(0xFFF2B5B5)),
        ],
      ),
    );
  }
}

class _MiniLegendDot extends StatelessWidget {
  const _MiniLegendDot({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
      ],
    );
  }
}

class _GraphMiniToolbar extends StatelessWidget {
  const _GraphMiniToolbar({
    required this.onAdd,
    required this.onShare,
    required this.onExport,
  });

  final VoidCallback onAdd;
  final VoidCallback onShare;
  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(235),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE3E7F2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _GraphToolbarButton(icon: Icons.add, tooltip: 'Ajouter', onTap: onAdd),
          const SizedBox(width: 6),
          _GraphToolbarButton(icon: Icons.share_outlined, tooltip: 'Partager', onTap: onShare),
          const SizedBox(width: 6),
          _GraphToolbarButton(icon: Icons.download_outlined, tooltip: 'Exporter', onTap: onExport),
        ],
      ),
    );
  }
}

class _GraphToolbarButton extends StatelessWidget {
  const _GraphToolbarButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Tooltip(
          message: tooltip,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          ),
        ),
      ),
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
