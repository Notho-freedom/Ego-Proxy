# Ego Proxy MVP

MVP Flutter pour un graphe généalogique centré utilisateur (ego graph). Cette version fournit :

- Une UI navigable avec top bar, sidebar et zones principales.
- Une vue « Arbre » statique avec nœuds et liens visuels.
- Des vues « Relations », « Documents » et « Paramètres » en placeholder.

## Lancer l’application

```bash
flutter run
```

## Dépendances MVP intégrées

- Graphe : graphview
- State : provider
- UI : animations, modal_bottom_sheet
- Documents/OCR : file_picker, google_ml_kit, syncfusion_flutter_pdf (extraction PDF)
- Auth : firebase_auth (avec firebase_core)
- Notifications : flutter_local_notifications
- Storage : hive, hive_flutter
- Temps réel : web_socket_channel
- UI polish : flutter_svg, shimmer, flutter_spinkit

## Configuration requise

1. Installer les dépendances :

```bash
flutter pub get
```

2. Firebase (si activé)
	- Créer un projet Firebase et ajouter les apps Android/iOS/Web.
	- Placer `google-services.json` et `GoogleService-Info.plist` dans leurs dossiers.
	- Générer `firebase_options.dart` via FlutterFire CLI si besoin.

3. Notifications locales (Android)
	- La permission `POST_NOTIFICATIONS` est déclarée dans le manifest.
	- Demander l’autorisation côté app avant d’émettre des notifications.

4. OCR (mobile)
	- `google_ml_kit` fonctionne sur Android/iOS (pas sur Web/Desktop).

5. Extraction PDF (Web + mobile)
	- `syncfusion_flutter_pdf` peut nécessiter une licence gratuite Community (Syncfusion).

## Structure rapide

- UI principale et données de démonstration : lib/main.dart

Remplace les données de SampleData et branche l’API quand prêt.
