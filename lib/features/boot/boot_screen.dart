import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/login_screen.dart';
import '../../data/repositories/firestore_user_repository_impl.dart';

class BootScreen extends StatelessWidget {
  const BootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnap) {
        if (authSnap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator(color: Colors.green)),
          );
        }

        if (!authSnap.hasData) {
          return const LoginScreen();
        }

        final user = authSnap.data!;

        return FutureBuilder(
          future: FirestoreUserRepositoryImpl().getOrCreateUser(
            uid: user.uid,
            email: user.email ?? '',
          ),
          builder: (context, userSnap) {
            if (userSnap.connectionState != ConnectionState.done) {
              if (userSnap.hasError) {
                return Scaffold(
                  backgroundColor: Colors.black,
                  body: Center(
                    child: Text(
                      userSnap.error.toString(),
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              return const Scaffold(
                backgroundColor: Colors.black,
                body: Center(
                  child: CircularProgressIndicator(color: Colors.green),
                ),
              );
            }

            return Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'USER READY',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                      },
                      child: const Text('LOGOUT'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
