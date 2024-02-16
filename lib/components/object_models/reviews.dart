import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final DateTime? data;
  final List<double> dimensoes;

  const Review({
    required this.data,
    required this.dimensoes,
  });

  Map<String, dynamic> toMap() {
    return {
      'data': data?.toIso8601String(),
      'dimensoes': dimensoes,
    };
  }
  
}

void addReviewToFirestore(String userId, Review review) {
  FirebaseFirestore.instance.collection('users').doc(userId).collection('reviews').doc(DateTime.now().toString()).set(review.toMap());
}