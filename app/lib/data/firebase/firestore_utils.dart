import 'package:cloud_firestore/cloud_firestore.dart';

/// Converte `Timestamp` em `DateTime` para que os models não dependam do Firestore.
Map<String, dynamic> fromFirestore(Map<String, dynamic>? data) =>
    (data ?? const {}).map((k, v) => MapEntry(k, v is Timestamp ? v.toDate() : v));
