part of '../main.dart';

class _RelationsView extends StatefulWidget {
  const _RelationsView();

  @override
  State<_RelationsView> createState() => _RelationsViewState();
}

class _RelationsViewState extends State<_RelationsView> {
  bool _isLoading = true;

  int _countRelations(RelationType type) {
    return SampleData.relations.where((relation) => relation.type == type).length;
  }

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Relations directes', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _CountChip(label: 'Parents', count: _countRelations(RelationType.parent)),
              _CountChip(label: 'Enfants', count: _countRelations(RelationType.child)),
              _CountChip(label: 'Fratrie', count: _countRelations(RelationType.sibling)),
              _CountChip(label: 'Conjoint', count: _countRelations(RelationType.partner)),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _isLoading
                ? ListView.separated(
                    itemCount: 6,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) => const _ShimmerListTile(),
                  )
                : ListView.separated(
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
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _RelationTypeChip(type: relation.type),
                              const SizedBox(width: 8),
                              const Icon(Icons.chevron_right),
                            ],
                          ),
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
  bool _isLoading = true;
  final List<_DocumentItem> _documents = [
    const _DocumentItem(title: 'Acte de naissance', status: _DocStatus.approved),
    const _DocumentItem(title: 'Livret de famille', status: _DocStatus.pending),
    const _DocumentItem(title: 'Pièce d\'identité', status: _DocStatus.rejected),
  ];

  int _countDocuments(_DocStatus status) {
    return _documents.where((doc) => doc.status == status).length;
  }

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
  }

  void _openAddDocumentSheet() {
    _showAddDocumentSheet(context, (title, status) {
      setState(() {
        _documents.insert(0, _DocumentItem(title: title, status: status));
      });
    });
  }

  Future<void> _pickAndExtract() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) {
      return;
    }

    final file = result.files.single;
    final fileName = file.name;

    if (!mounted) {
      return;
    }

    _showExtractionLoader();
    _ExtractionResult extraction;
    try {
      extraction = await _extractFromFile(file);
    } catch (_) {
      if (mounted) {
        _hideExtractionLoader();
        _showInfoSnackBar('Extraction échouée. Réessaie avec un autre document.');
      }
      return;
    }

    if (!mounted) {
      return;
    }

    _hideExtractionLoader();

    if (!mounted) {
      return;
    }

    _showExtractionPreviewSheet(
      context,
      fileName: fileName,
      extraction: extraction,
      onConfirm: () {
        setState(() {
          _documents.insert(0, _DocumentItem(title: extraction.title, status: _DocStatus.pending));
        });
      },
    );
  }

  void _showExtractionLoader() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 12),
                Text('Analyse du document…'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _hideExtractionLoader() {
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<_ExtractionResult> _extractFromFile(PlatformFile file) async {
    final extension = (file.extension ?? '').toLowerCase();
    final isPdf = extension == 'pdf';
    String extractedText = '';
    String? warning;

    if (isPdf) {
      final bytes = file.bytes ?? await readFileBytes(file.path);
      if (bytes == null) {
        warning = 'Impossible de lire le PDF.';
      } else {
        extractedText = _extractTextFromPdf(bytes);
      }
    } else {
      if (kIsWeb) {
        warning = 'OCR image non disponible sur Web pour le moment.';
      } else if (file.path == null) {
        warning = 'Impossible d’accéder à l’image.';
      } else {
        extractedText = await _extractTextFromImage(file.path!);
      }
    }

    if (extractedText.trim().isEmpty) {
      return _simulateExtraction(file.name, note: warning ?? 'Aucun texte détecté.');
    }

    final hints = await _extractEntities(extractedText);
    return _extractFromText(
      fileName: file.name,
      text: extractedText,
      note: warning,
      hints: hints,
    );
  }

  String _extractTextFromPdf(Uint8List bytes) {
    final document = PdfDocument(inputBytes: bytes);
    final extractor = PdfTextExtractor(document);
    final text = extractor.extractText();
    document.dispose();
    return text;
  }

  Future<String> _extractTextFromImage(String path) async {
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final inputImage = InputImage.fromFilePath(path);
    final result = await recognizer.processImage(inputImage);
    await recognizer.close();
    return result.text;
  }

  _ExtractionResult _extractFromText({
    required String fileName,
    required String text,
    String? note,
    _EntityHints? hints,
  }) {
    final lower = text.toLowerCase();
    final mrz = _extractMrz(text);
    final type = _inferDocType(lower, hasMrz: mrz != null);
    final name = mrz?.name ?? _extractName(text);
    final date = mrz?.birthDate ?? hints?.date ?? _extractDate(text);
    final location = hints?.location ?? _extractLocation(text);
    final idNumber = mrz?.documentNumber ?? _extractIdNumber(text);

    final fields = <_ExtractionField>[
      _ExtractionField(label: 'Fichier', value: fileName, confidence: 1),
      _ExtractionField(label: 'Type', value: type, confidence: 0.9),
      _ExtractionField(label: 'Nom', value: name ?? 'Non détecté', confidence: name == null ? 0.4 : 0.86),
      _ExtractionField(label: 'Date', value: date ?? 'Non détectée', confidence: date == null ? 0.4 : 0.8),
      _ExtractionField(label: 'Lieu', value: location ?? 'Non détecté', confidence: location == null ? 0.4 : 0.76),
      _ExtractionField(label: 'Identifiant', value: idNumber ?? 'Non détecté', confidence: idNumber == null ? 0.4 : 0.78),
    ];

    final hits = fields.where((field) => field.confidence >= 0.75).length;
    final confidence = (0.6 + hits * 0.06).clamp(0.55, 0.92);

    return _ExtractionResult(
      title: type,
      confidence: confidence,
      fields: fields,
      snippet: _buildSnippet(text),
      note: note,
    );
  }

  String _inferDocType(String lower, {bool hasMrz = false}) {
    if (hasMrz) {
      return 'Passeport';
    }
    if (lower.contains('acte de naissance') || lower.contains('naissance')) {
      return 'Acte de naissance';
    }
    if (lower.contains('acte de mariage') || lower.contains('mariage')) {
      return 'Acte de mariage';
    }
    if (lower.contains('acte de décès') || lower.contains('décès') || lower.contains('deces')) {
      return 'Acte de décès';
    }
    if (lower.contains('livret de famille') || lower.contains('livret')) {
      return 'Livret de famille';
    }
    if (lower.contains("carte d'identité") || lower.contains('carte nationale') || lower.contains('identité') || lower.contains('identite')) {
      return 'Pièce d\'identité';
    }
    if (lower.contains('passeport') || lower.contains('passport')) {
      return 'Passeport';
    }
    return 'Document officiel';
  }

  String? _extractName(String text) {
    final surnameMatch = RegExp(
      r'(?:Nom\s*/?\s*Sur?name|Nom\s*(?:de\s*famille)?|Surname)\s*[:\-]?\s*([A-Za-zÀ-ÿ\-\s]{2,})',
      caseSensitive: false,
    ).firstMatch(text);
    final givenMatch = RegExp(
      r'(?:Pr[eé]noms?\s*/?\s*Given names?|Given names?|Pr[eé]noms?)\s*[:\-]?\s*([A-Za-zÀ-ÿ\-\s]{2,})',
      caseSensitive: false,
    ).firstMatch(text);

    if (surnameMatch != null || givenMatch != null) {
      final surname = surnameMatch?.group(1)?.trim();
      final given = givenMatch?.group(1)?.trim();
      if (surname != null && given != null) {
        return _sanitizeName('$surname $given');
      }
      return _sanitizeName(surname ?? given);
    }

    final fallback = RegExp(r'(?:Nom\s+et\s+pr[eé]nom)s?\s*[:\-]?\s*([A-Za-zÀ-ÿ\-\s]{2,})', caseSensitive: false)
        .firstMatch(text);
    if (fallback != null) {
      return _sanitizeName(fallback.group(1));
    }

    final upperMatch = RegExp(r'\b([A-ZÀ-Ÿ]{2,}(?:\s+[A-ZÀ-Ÿ]{2,}){1,3})\b').firstMatch(text);
    return _sanitizeName(upperMatch?.group(1));
  }

  String? _extractDate(String text) {
    final labeled = RegExp(
      r'(?:Date\s*de\s*naissance|Date\s*of\s*birth|Naissance|Birth|DOB)\s*[:\-]?\s*(\d{1,2}[\/.\-]\d{1,2}[\/.\-]\d{2,4})',
      caseSensitive: false,
    ).firstMatch(text);
    if (labeled != null) {
      return labeled.group(1);
    }
    final match = RegExp(r'\b\d{1,2}[\/.\-]\d{1,2}[\/.\-]\d{2,4}\b').firstMatch(text);
    if (match != null) {
      return match.group(0);
    }
    final year = RegExp(r'\b(19\d{2}|20\d{2})\b').firstMatch(text);
    return year?.group(0);
  }

  String? _extractLocation(String text) {
    final patterns = [
      RegExp(r'(?:Lieu\s*(?:de\s*naissance)?|Lieu\s*de\s*d[eé]livrance|Place\s*of\s*birth|Birth\s*place|N[eé]e?\s*[àa])\s*[:\-]?\s*([A-Za-zÀ-ÿ\-\s]{3,})', caseSensitive: false),
      RegExp(r'\bà\s+([A-Za-zÀ-ÿ\-\s]{3,})', caseSensitive: false),
    ];
    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        return match.group(1)?.trim();
      }
    }
    return null;
  }

  String? _extractIdNumber(String text) {
    final match = RegExp(
      r'(?:N°|No|Num[eé]ro|Numero|ID|Passport\s*No|Document\s*No)\s*[:\-]?\s*([A-Z0-9\-]{5,})',
      caseSensitive: false,
    ).firstMatch(text);
    return match?.group(1)?.trim();
  }

  String? _sanitizeName(String? value) {
    if (value == null) {
      return null;
    }
    final cleaned = value.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (cleaned.length < 3) {
      return null;
    }
    const blocked = [
      'REPUBLIQUE',
      'REPUBLIC',
      'NATIONALE',
      'NATIONAL',
      'PASSEPORT',
      'PASSPORT',
      'CARTE',
      'IDENTITE',
      'IDENTITÉ',
      'SURETE',
      'SÛRETÉ',
      'DELEGUE',
      'DELEGUEE',
      'DELEGATE',
    ];
    final upper = cleaned.toUpperCase();
    if (blocked.any(upper.contains)) {
      return null;
    }
    return cleaned;
  }

  Future<_EntityHints> _extractEntities(String text) async {
    if (kIsWeb) {
      return _EntityHints();
    }
    final hints = _EntityHints();
    final languages = <EntityExtractorLanguage>[
      EntityExtractorLanguage.french,
      EntityExtractorLanguage.english,
    ];
    for (final language in languages) {
      final extractor = EntityExtractor(language: language);
      final annotations = await extractor.annotateText(text);
      for (final annotation in annotations) {
        for (final entity in annotation.entities) {
          switch (entity.type) {
            case EntityType.dateTime:
              hints.date ??= annotation.text;
              break;
            case EntityType.address:
              hints.location ??= annotation.text;
              break;
            default:
              break;
          }
        }
      }
      await extractor.close();
      if (hints.date != null || hints.location != null) {
        break;
      }
    }
    return hints;
  }

  _MrzInfo? _extractMrz(String text) {
    final normalized = text
        .toUpperCase()
        .replaceAll(RegExp(r'[^A-Z0-9<\n]'), '')
        .replaceAll(RegExp(r'\n+'), '\n');

    final lines = normalized.split('\n').where((line) => line.contains('P<')).toList();
    if (lines.isEmpty) {
      return null;
    }
    final line1 = lines.first;
    final line2 = lines.length > 1 ? lines[1] : '';

    final nameSection = line1.length > 5 ? line1.substring(5) : '';
    final nameParts = nameSection.split('<<');
    final surname = nameParts.isNotEmpty ? nameParts.first.replaceAll('<', ' ').trim() : '';
    final given = nameParts.length > 1 ? nameParts[1].replaceAll('<', ' ').trim() : '';
    final name = [surname, given].where((part) => part.isNotEmpty).join(' ').replaceAll(RegExp(r'\s+'), ' ').trim();

    String? birthDate;
    String? documentNumber;
    if (line2.length >= 28) {
      documentNumber = line2.substring(0, 9).replaceAll('<', '').trim();
      final rawBirth = line2.substring(13, 19);
      birthDate = _formatMrzDate(rawBirth);
    }

    if (name.isEmpty && birthDate == null && documentNumber == null) {
      return null;
    }
    return _MrzInfo(name: name.isEmpty ? null : name, birthDate: birthDate, documentNumber: documentNumber);
  }

  String? _formatMrzDate(String raw) {
    if (!RegExp(r'^\d{6}$').hasMatch(raw)) {
      return null;
    }
    final yy = int.parse(raw.substring(0, 2));
    final mm = raw.substring(2, 4);
    final dd = raw.substring(4, 6);
    final currentYear = DateTime.now().year % 100;
    final century = yy <= currentYear ? 2000 : 1900;
    return '$dd.$mm.${century + yy}';
  }

  String _buildSnippet(String text) {
    final cleaned = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (cleaned.length <= 320) {
      return cleaned;
    }
    return '${cleaned.substring(0, 320)}…';
  }

  _ExtractionResult _simulateExtraction(String fileName, {String? note}) {
    final base = fileName.replaceAll(RegExp(r'\.[^.]+$'), '');
    final normalized = base.replaceAll('_', ' ').replaceAll('-', ' ').trim();
    final lower = normalized.toLowerCase();
    final yearMatch = RegExp(r'(19\d{2}|20\d{2})').firstMatch(normalized);
    final year = yearMatch != null ? int.tryParse(yearMatch.group(0) ?? '') : null;
    final type = () {
      if (lower.contains('naissance') || lower.contains('birth')) return 'Acte de naissance';
      if (lower.contains('mariage') || lower.contains('marriage')) return 'Acte de mariage';
      if (lower.contains('identite') || lower.contains('identité') || lower.contains('id')) return 'Pièce d\'identité';
      if (lower.contains('livret')) return 'Livret de famille';
      return 'Document importé';
    }();
    final person = _deriveNameFromFileName(normalized);
    final location = lower.contains('paris') ? 'Paris' : 'Non détecté';

    return _ExtractionResult(
      title: type,
      confidence: 0.82,
      fields: [
        _ExtractionField(label: 'Fichier', value: fileName, confidence: 1),
        _ExtractionField(label: 'Nom', value: person ?? 'Nom non détecté', confidence: person == null ? 0.4 : 0.86),
        _ExtractionField(label: 'Année', value: year?.toString() ?? 'Non détectée', confidence: year == null ? 0.42 : 0.8),
        _ExtractionField(label: 'Lieu', value: location, confidence: location == 'Non détecté' ? 0.4 : 0.76),
        _ExtractionField(label: 'Type', value: type, confidence: 0.9),
      ],
      snippet: normalized,
      note: note,
    );
  }

  String? _deriveNameFromFileName(String normalized) {
    final cleaned = normalized
        .replaceAll(RegExp(r'\b(naissance|mariage|marriage|birth|acte|identite|identité|id|livret|famille|document)\b', caseSensitive: false), '')
        .replaceAll(RegExp(r'\b(19\d{2}|20\d{2})\b'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (cleaned.length < 3) {
      return null;
    }
    return cleaned;
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
              AbsorbPointer(
                absorbing: _isLoading,
                child: Opacity(
                  opacity: _isLoading ? 0.5 : 1,
                  child: Row(
                    children: [
                      FilledButton.icon(
                        onPressed: _pickAndExtract,
                        icon: const Icon(Icons.upload_file),
                        label: const Text('Uploader'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: _openAddDocumentSheet,
                        child: const Text('Saisie manuelle'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _CountChip(label: 'Validés', count: _countDocuments(_DocStatus.approved), color: _DocStatus.approved.color),
              _CountChip(label: 'En attente', count: _countDocuments(_DocStatus.pending), color: _DocStatus.pending.color),
              _CountChip(label: 'Refusés', count: _countDocuments(_DocStatus.rejected), color: _DocStatus.rejected.color),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _isLoading
                ? ListView.separated(
                    itemCount: 5,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) => const _ShimmerListTile(),
                  )
                : ListView.separated(
                    itemCount: _documents.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
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
        leading: CircleAvatar(
          backgroundColor: color.withAlpha(18),
          child: Icon(Icons.description_outlined, color: color),
        ),
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

class _SettingsView extends StatefulWidget {
  const _SettingsView();

  @override
  State<_SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<_SettingsView> {
  bool _notifyMatches = true;
  bool _notifyDocs = true;
  bool _sharePublic = false;

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
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(18),
                child: Icon(Icons.tune, color: Theme.of(context).colorScheme.primary),
              ),
              title: const Text('Préférences générales'),
              subtitle: const Text('Contrôlez la confidentialité et les alertes.'),
              trailing: const Icon(Icons.chevron_right),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Confidentialité', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  value: _sharePublic,
                  onChanged: (value) => setState(() => _sharePublic = value),
                  title: const Text('Partager l’arbre publiquement'),
                  subtitle: const Text('Permettre l’accès en lecture via un lien.'),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.security_outlined),
                  title: Text('Gestion des accès'),
                  subtitle: Text('Inviter des contributeurs et gérer les rôles.'),
                  trailing: Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('Notifications', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  value: _notifyMatches,
                  onChanged: (value) => setState(() => _notifyMatches = value),
                  title: const Text('Alertes de matching'),
                  subtitle: const Text('Nouvelles correspondances et suggestions.'),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  value: _notifyDocs,
                  onChanged: (value) => setState(() => _notifyDocs = value),
                  title: const Text('Statuts des documents'),
                  subtitle: const Text('Validation et demandes complémentaires.'),
                ),
              ],
            ),
          ),
        ],
      ),
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

class _ExtractionResult {
  const _ExtractionResult({
    required this.title,
    required this.confidence,
    required this.fields,
    this.snippet,
    this.note,
  });

  final String title;
  final double confidence;
  final List<_ExtractionField> fields;
  final String? snippet;
  final String? note;
}

class _ExtractionField {
  const _ExtractionField({
    required this.label,
    required this.value,
    required this.confidence,
  });

  final String label;
  final String value;
  final double confidence;
}

class _MrzInfo {
  const _MrzInfo({this.name, this.birthDate, this.documentNumber});

  final String? name;
  final String? birthDate;
  final String? documentNumber;
}

class _EntityHints {
  String? date;
  String? location;
}

void _showExtractionPreviewSheet(
  BuildContext context, {
  required String fileName,
  required _ExtractionResult extraction,
  required VoidCallback onConfirm,
}) {
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Prévisualisation OCR', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text(fileName, style: const TextStyle(color: Colors.black54)),
              const SizedBox(height: 12),
              if (extraction.note != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFECB3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Color(0xFFF57C00)),
                      const SizedBox(width: 10),
                      Expanded(child: Text(extraction.note!)),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: Text(extraction.title),
                  subtitle: Text('Confiance globale ${(extraction.confidence * 100).round()}%'),
                  trailing: _StatusChip(label: 'En attente', color: _DocStatus.pending.color),
                ),
              ),
              const SizedBox(height: 12),
              ...extraction.fields.map((field) {
                final confidence = (field.confidence * 100).round();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Card(
                    child: ListTile(
                      title: Text(field.label),
                      subtitle: Text(field.value),
                      trailing: _StatusChip(label: '$confidence%', color: const Color(0xFF1A73E8)),
                    ),
                  ),
                );
              }),
              if (extraction.snippet != null && extraction.snippet!.isNotEmpty)
                Card(
                  child: ExpansionTile(
                    title: const Text('Texte détecté'),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    children: [
                      Text(extraction.snippet!, style: const TextStyle(color: Colors.black54)),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Annuler'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        onConfirm();
                        Navigator.of(context).pop();
                      },
                      child: const Text('Confirmer'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
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
                    initialValue: status,
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
