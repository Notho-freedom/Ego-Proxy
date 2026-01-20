part of '../main.dart';

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
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (_person.id == 'me')
                            const _InfoChip(
                              icon: Icons.star_outline,
                              label: 'Profil principal',
                              color: Color(0xFF1A73E8),
                            )
                          else
                            const _InfoChip(
                              icon: Icons.group_outlined,
                              label: 'Profil lié',
                            ),
                          if (_person.isVerified)
                            const _InfoChip(
                              icon: Icons.verified_outlined,
                              label: 'Vérifié',
                              color: Color(0xFF2E7D32),
                            )
                          else
                            const _InfoChip(
                              icon: Icons.info_outline,
                              label: 'À confirmer',
                              color: Color(0xFFF57C00),
                            ),
                        ],
                      ),
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
        Row(
          children: const [
            Expanded(child: _StatCard(label: 'Relations', value: '7', icon: Icons.link)),
            SizedBox(width: 12),
            Expanded(child: _StatCard(label: 'Documents', value: '3', icon: Icons.description_outlined)),
            SizedBox(width: 12),
            Expanded(child: _StatCard(label: 'Confiance', value: 'Élevée', icon: Icons.verified_outlined)),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Identité'),
            subtitle: Text(person.name),
            trailing: const Icon(Icons.chevron_right),
          ),
        ),
        const SizedBox(height: 12),
        const Card(
          child: ListTile(
            leading: Icon(Icons.cake_outlined),
            title: Text('Date de naissance'),
            subtitle: Text('Renseignée'),
            trailing: Icon(Icons.chevron_right),
          ),
        ),
        const SizedBox(height: 12),
        const Card(
          child: ListTile(
            leading: Icon(Icons.place_outlined),
            title: Text('Lieu'),
            subtitle: Text('Non renseigné'),
            trailing: Icon(Icons.chevron_right),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.verified_outlined),
            title: const Text('Niveau de confiance'),
            subtitle: Text(person.isVerified ? 'Élevé' : 'Moyen'),
            trailing: const Icon(Icons.chevron_right),
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
      children: [
        _RelationCategoryTile(
          icon: Icons.family_restroom_outlined,
          title: 'Parents',
          subtitle: '2 relations confirmées',
          chip: _StatusChip(label: 'Validé', color: const Color(0xFF2E7D32)),
        ),
        const SizedBox(height: 12),
        _RelationCategoryTile(
          icon: Icons.people_outline,
          title: 'Fratrie',
          subtitle: '1 relation proposée',
          chip: _StatusChip(label: 'À confirmer', color: const Color(0xFFF57C00)),
        ),
        const SizedBox(height: 12),
        _RelationCategoryTile(
          icon: Icons.favorite_border,
          title: 'Conjoint',
          subtitle: '1 relation confirmée',
          chip: _StatusChip(label: 'Validé', color: const Color(0xFF2E7D32)),
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
      children: [
        _DocumentCategoryTile(
          title: 'Acte de naissance',
          subtitle: 'Validé',
          color: const Color(0xFF2E7D32),
        ),
        const SizedBox(height: 12),
        _DocumentCategoryTile(
          title: 'Livret de famille',
          subtitle: 'En attente',
          color: const Color(0xFFF57C00),
        ),
      ],
    );
  }
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
