import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/login_screen.dart';
import '../../data/repositories/firestore_user_repository_impl.dart';
import '../../core/services/app_user_state.dart';

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

        final firebaseUser = authSnap.data!;

        return FutureBuilder(
          future: FirestoreUserRepositoryImpl().getOrCreateUser(
            uid: firebaseUser.uid,
            email: firebaseUser.email ?? '',
          ),
          builder: (context, userSnap) {
            if (userSnap.connectionState != ConnectionState.done) {
              return const Scaffold(
                backgroundColor: Colors.black,
                body: Center(
                  child: CircularProgressIndicator(color: Colors.green),
                ),
              );
            }

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

            // تخزين المستخدم في الذاكرة (مرة واحدة)
            AppUserState.set(userSnap.data!);

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
                        AppUserState.clear();
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
