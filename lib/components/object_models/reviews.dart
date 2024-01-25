import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final DateTime? data;
  final bool isConcluded;
  final List<DimensaoReview> dimensoes;

  const Review({
    required this.isConcluded,
    required this.data,
    required this.dimensoes,
  });

  Map<String, dynamic> toMap() {
    return {
      'data': data?.toIso8601String(),
      'dimensoes': dimensoes.map((dimensao) => dimensao.toMap()).toList(),
    };
  }

  factory Review.fromJson(Map<String, dynamic> json) {
    List<DimensaoReview> dimensoesList = [];

    for (var element in json['dimensoes']) {
      if (element.containsKey('nome') && element.containsKey('perguntas')) {
        dimensoesList.add(DimensaoReview.fromJson(element));
      }
    }

    return Review(
      isConcluded: json['isConcluded'],
      dimensoes: dimensoesList,
      data: json['data'] != null ? DateTime.parse(json['data']) : null,
    );
  }
}

class DimensaoReview {
  final String nome;
  final double? resultado;
  final List<QuestaoReview> perguntas;

  DimensaoReview({
    required this.nome,
    required this.resultado,
    required this.perguntas,
  });

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'resultado': resultado,
      'perguntas': perguntas.map((pergunta) => pergunta.toMap()).toList(),
    };
  }

  factory DimensaoReview.fromJson(Map<String, dynamic> json) {
    return DimensaoReview(
      nome: json['nome'],
      perguntas: (json['perguntas'] as List<dynamic>)
          .map((e) => QuestaoReview.fromJson(e as Map<String, dynamic>))
          .toList(),
      resultado: json['resultado'],
    );
  }
}

class QuestaoReview {
  final String? enunciado;
  final Resposta resposta;

  QuestaoReview({
    required this.enunciado,
    required this.resposta,
  });

  Map<String, dynamic> toMap() {
    return {
      'enunciado': enunciado,
      'resposta': resposta.toMap(),
    };
  }

  factory QuestaoReview.fromJson(Map<String, dynamic> json) {
    return QuestaoReview(
      enunciado: json['enunciado'],
      resposta: Resposta.fromJson(json['resposta'] as Map<String, dynamic>),
    );
  }
}

class Resposta {
  final String? texto;
  final double? valor;

  Resposta({
    required this.texto,
    required this.valor,
  });

  Map<String, dynamic> toMap() {
    return {
      'texto': texto,
      'valor': valor,
    };
  }

  factory Resposta.fromJson(Map<String, dynamic> json) {
    return Resposta(
      texto: json['texto'],
      valor: json['valor'],
    );
  }
}

void addReviewToFirestore(String userId, Review review) {
  FirebaseFirestore.instance.collection('users').doc(userId).collection('reviews').doc(DateTime.now().toString()).set(review.toMap());
}

Stream<List<Review>> getReviewsFromFirestore(String userId) {
  return FirebaseFirestore.instance.collection('users').doc(userId).collection('reviews').snapshots().map(
        (querySnapshot) => querySnapshot.docs
            .map((documentSnapshot) => Review.fromJson(documentSnapshot.data()))
            .toList(),
      );
}