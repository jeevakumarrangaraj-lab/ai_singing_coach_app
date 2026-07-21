import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../domain/onboarding_profile.dart';

class OnboardingRepositoryException implements Exception {
  const OnboardingRepositoryException([
    this.message = 'Unable to save your Tuno setup.',
  ]);

  final String message;

  @override
  String toString() => message;
}

abstract class OnboardingRepository {
  Future<OnboardingProfile?> loadProfile(String userId);

  Future<void> saveProfile(String userId, OnboardingProfile profile);

  Future<bool> hasCompletedOnboarding(String userId);
}

class OnboardingRepositoryImpl implements OnboardingRepository {
  OnboardingRepositoryImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<OnboardingProfile?> loadProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return null;
      return OnboardingProfile.fromFirestore(doc.data()!);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveProfile(String userId, OnboardingProfile profile) async {
    try {
      final docRef = _firestore.collection('users').doc(userId);
      final existingDoc = await docRef.get();
      final data = profile.toFirestore();

      data['onboardingUpdatedAt'] = FieldValue.serverTimestamp();

      if (!existingDoc.exists) {
        data['onboardingCreatedAt'] = FieldValue.serverTimestamp();
      }

      await docRef.set(data, SetOptions(merge: true));
    } catch (error, stackTrace) {
      debugPrint('Onboarding profile save failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      throw const OnboardingRepositoryException();
    }
  }

  @override
  Future<bool> hasCompletedOnboarding(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return false;

      final data = doc.data();
      if (data == null) return false;

      final completed = data['onboardingCompleted'];
      if (completed is bool) return completed;

      return false;
    } catch (_) {
      return false;
    }
  }
}
