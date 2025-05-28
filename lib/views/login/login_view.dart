import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../auth/auth_service.dart';
import '../auth/firebase_service.dart';
import '../../viewmodels/point_provider.dart';
import '../../models/purchased_product.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final AuthService _authService = AuthService();
  final FirebaseService _firebaseService = FirebaseService();

  Future<void> _handleLogin() async {
    try {
      final user = await _authService.signInWithGoogle();
      if (user == null) return;

      final doc = await _firebaseService.getUserDoc(user.uid);

      if (!doc.exists) {
        await _firebaseService.createUser(
          uid: user.uid,
          name: user.displayName ?? 'Unknown',
          email: user.email ?? 'No Email',
          point: 20000,
          product: [],
        );

        ref.read(pointProvider.notifier).set(20000);
        ref.read(purchaseHistoryProvider.notifier).setAll([]);
      } else {
        final data = doc.data() as Map<String, dynamic>;
        final point = data['point'] ?? 0;

        final rawProducts = data['product'] as List<dynamic>? ?? [];
        final products = rawProducts
            .map((e) => PurchasedProduct.fromMap(e as Map<String, dynamic>))
            .toList();

        ref.read(pointProvider.notifier).set(point);
        ref.read(purchaseHistoryProvider.notifier).setAll(products);
      }

      if (!mounted) return;
      context.go('/main');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("로그인 실패: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          ClipPath(
            clipper: _TopWaveClipper(),
            child: Container(
              height: size.height * 0.35,
              color: Colors.blue[400],
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        "assets/images/logo.png",
                        fit: BoxFit.cover,
                        width: 160,
                        height: 160,
                        errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.error),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Enjoy Your',
                    style: TextStyle(color: Colors.black54, fontSize: 16),
                  ),
                  Text(
                    'CashDriving',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Sign in with ', style: TextStyle(fontSize: 16)),
                        Container(
                          width: 90,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(70),
                          ),
                          padding: const EdgeInsets.all(2),
                          child: Image.asset(
                            'assets/images/google.png',
                            fit: BoxFit.contain,
                          ),
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

class _TopWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.75);
    path.quadraticBezierTo(
        size.width * 0.5, size.height, size.width, size.height * 0.75);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
