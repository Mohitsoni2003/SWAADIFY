import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseServices {
  static Future<void> resetPassword({required String email}) async {
    await auth.sendPasswordResetEmail(email: email.trim());
  }

  static Future<void> updateUserProfile({required String name}) async {
    final user = currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    await user.updateDisplayName(name.trim());

    await firestore.collection('users').doc(user.uid).update({
      'name': name.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<Set<String>> getFavouriteDishNames() async {
    final user = currentUser;

    if (user == null) {
      return {};
    }

    final snapshot = await firestore
        .collection('users')
        .doc(user.uid)
        .collection('favourites')
        .get();

    return snapshot.docs.map((doc) => doc.data()["name"].toString()).toSet();
  }

  static Future<void> removeFavouriteDish(String dishName) async {
    final user = currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    final dishId = dishName.toLowerCase().replaceAll(" ", "_");

    await firestore
        .collection('users')
        .doc(user.uid)
        .collection('favourites')
        .doc(dishId)
        .delete();
  }

  static final FirebaseAuth auth = FirebaseAuth.instance;
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  static User? get currentUser => auth.currentUser;

  static bool get isLoggedIn => currentUser != null;

  static Future<void> signUpUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final userCredential = await auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    final user = userCredential.user;

    if (user != null) {
      await user.updateDisplayName(name.trim());

      await firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': name.trim(),
        'email': email.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  static Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    await auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  static Future<void> saveFavouriteDish(Map<String, dynamic> dish) async {
    final user = currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    final dishId = dish["name"].toString().toLowerCase().replaceAll(" ", "_");

    await firestore
        .collection('users')
        .doc(user.uid)
        .collection('favourites')
        .doc(dishId)
        .set({...dish, 'savedAt': FieldValue.serverTimestamp()});
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getFavouriteDishes() {
    final user = currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    return firestore
        .collection('users')
        .doc(user.uid)
        .collection('favourites')
        .orderBy('savedAt', descending: true)
        .snapshots();
  }

  static Future<void> logoutUser() async {
    await auth.signOut();
  }
}
