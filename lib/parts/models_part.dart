part of '../main.dart';

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
