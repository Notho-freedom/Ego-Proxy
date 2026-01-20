part of '../main.dart';

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
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  bool _isAuthenticated = false;

  void _setAuthenticated(bool value) {
    setState(() => _isAuthenticated = value);
  }

  @override
  Widget build(BuildContext context) {
    if (_isAuthenticated) {
      return const DashboardShell();
    }

    return _AuthShell(
      onSignedIn: () => _setAuthenticated(true),
    );
  }
}

class _AuthShell extends StatefulWidget {
  const _AuthShell({required this.onSignedIn});

  final VoidCallback onSignedIn;

  @override
  State<_AuthShell> createState() => _AuthShellState();
}

class _AuthShellState extends State<_AuthShell> {
  bool _isLogin = true;

  void _toggleMode() {
    setState(() => _isLogin = !_isLogin);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFFE9EDF3),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 960;
            final form = AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _isLogin
                  ? _LoginCard(onSignedIn: widget.onSignedIn, onToggle: _toggleMode)
                  : _SignUpCard(onSignedIn: widget.onSignedIn, onToggle: _toggleMode),
            );

            if (isWide) {
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1080),
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: _AuthSplitCard(
                      isLogin: _isLogin,
                      form: form,
                    ),
                  ),
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    children: [
                      _AuthHeroCard(isLogin: _isLogin),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(14),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: form,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AuthSplitCard extends StatelessWidget {
  const _AuthSplitCard({required this.isLogin, required this.form});

  final bool isLogin;
  final Widget form;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 520,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(child: _AuthHeroCard(isLogin: isLogin, isCompact: true)),
          Expanded(
            child: ClipPath(
              clipper: _WaveClipper(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
                color: Colors.white,
                child: form,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthHeroCard extends StatelessWidget {
  const _AuthHeroCard({required this.isLogin, this.isCompact = false});

  final bool isLogin;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final size = isCompact ? 28.0 : 34.0;
    return Container(
      padding: EdgeInsets.all(isCompact ? 28 : 36),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
        ),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(28),
          bottomLeft: const Radius.circular(28),
          topRight: Radius.circular(isCompact ? 0 : 28),
          bottomRight: Radius.circular(isCompact ? 0 : 28),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                height: size,
                width: size,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.hub, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              const Text('Ego Proxy', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Welcome to',
            style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          Text(
            isLogin ? 'Connectez-vous' : 'Créez un compte',
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            'Centralisez les liens familiaux et les preuves\navec une UX simple et moderne.',
            style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.lock_outline, size: 18, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Données privées et contrôle d’accès.',
                    style: TextStyle(color: Colors.white.withAlpha(220), fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({required this.onSignedIn, required this.onToggle});

  final VoidCallback onSignedIn;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('login'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Create your account', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          const TextField(decoration: InputDecoration(labelText: 'Name')),
          const SizedBox(height: 12),
          const TextField(decoration: InputDecoration(labelText: 'E-mail Address')),
          const SizedBox(height: 12),
          const TextField(obscureText: true, decoration: InputDecoration(labelText: 'Password')),
          const SizedBox(height: 12),
          Row(
            children: [
              Checkbox(value: true, onChanged: (_) {}),
              const Expanded(child: Text('By Signing Up, I Agree with Terms & Conditions')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: onSignedIn,
                  child: const Text('Sign Up'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: onToggle,
                  child: const Text('Sign In'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _AuthLightDivider(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onSignedIn,
                  icon: const Icon(Icons.g_mobiledata),
                  label: const Text('Google'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onSignedIn,
                  icon: const Icon(Icons.facebook),
                  label: const Text('Facebook'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SignUpCard extends StatelessWidget {
  const _SignUpCard({required this.onSignedIn, required this.onToggle});

  final VoidCallback onSignedIn;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('signup'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Sign In', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          const TextField(decoration: InputDecoration(labelText: 'E-mail Address')),
          const SizedBox(height: 12),
          const TextField(obscureText: true, decoration: InputDecoration(labelText: 'Password')),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: onSignedIn,
                  child: const Text('Sign In'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: onToggle,
                  child: const Text('Sign Up'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _AuthLightDivider(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onSignedIn,
                  icon: const Icon(Icons.g_mobiledata),
                  label: const Text('Google'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onSignedIn,
                  icon: const Icon(Icons.facebook),
                  label: const Text('Facebook'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(16, 0);
    path.quadraticBezierTo(0, size.height * 0.08, 22, size.height * 0.16);
    path.quadraticBezierTo(44, size.height * 0.24, 18, size.height * 0.32);
    path.quadraticBezierTo(-6, size.height * 0.4, 20, size.height * 0.48);
    path.quadraticBezierTo(44, size.height * 0.56, 18, size.height * 0.64);
    path.quadraticBezierTo(-6, size.height * 0.72, 22, size.height * 0.8);
    path.quadraticBezierTo(46, size.height * 0.88, 16, size.height * 0.96);
    path.lineTo(16, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _AuthLightDivider extends StatelessWidget {
  const _AuthLightDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(height: 1, color: Colors.black.withAlpha(25))),
        const SizedBox(width: 12),
        const Text('or', style: TextStyle(fontSize: 11, color: Colors.black54)),
        const SizedBox(width: 12),
        Expanded(child: Divider(height: 1, color: Colors.black.withAlpha(25))),
      ],
    );
  }
}
