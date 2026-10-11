import 'dart:math' as math;

const _contractions = <String, String>{
  "i'm": 'i am',
  "you're": 'you are',
  "we're": 'we are',
  "they're": 'they are',
  "he's": 'he is',
  "she's": 'she is',
  "it's": 'it is',
  "that's": 'that is',
  "what's": 'what is',
  "where's": 'where is',
  "there's": 'there is',
  "i've": 'i have',
  "you've": 'you have',
  "we've": 'we have',
  "they've": 'they have',
  "i'll": 'i will',
  "you'll": 'you will',
  "we'll": 'we will',
  "i'd": 'i would',
  "you'd": 'you would',
  "don't": 'do not',
  "doesn't": 'does not',
  "didn't": 'did not',
  "isn't": 'is not',
  "aren't": 'are not',
  "wasn't": 'was not',
  "weren't": 'were not',
  "can't": 'cannot',
  "won't": 'will not',
  "let's": 'let us',
};

/// Normaliza respostas: minúsculas, apóstrofos, pontuação, espaços e contrações.
String normalizeAnswer(String input) {
  var text = input
      .toLowerCase()
      .replaceAll(RegExp('[\u2018\u2019\u00b4`]'), "'")
      .replaceAll(RegExp(r"[^\p{L}\p{N}'\s]", unicode: true), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  text = text.split(' ').map((w) => _contractions[w] ?? w).join(' ');
  return text.replaceAll("'", '').replaceAll(RegExp(r'\s+'), ' ').trim();
}

int levenshtein(List<Object> a, List<Object> b) {
  if (a.isEmpty) return b.length;
  if (b.isEmpty) return a.length;
  var previous = List<int>.generate(b.length + 1, (i) => i);
  for (var i = 1; i <= a.length; i++) {
    final current = List<int>.filled(b.length + 1, 0)..[0] = i;
    for (var j = 1; j <= b.length; j++) {
      final cost = a[i - 1] == b[j - 1] ? 0 : 1;
      current[j] = math.min(
        math.min(current[j - 1] + 1, previous[j] + 1),
        previous[j - 1] + cost,
      );
    }
    previous = current;
  }
  return previous[b.length];
}

/// Similaridade (0–1) por palavras, usada na comparação de fala.
double wordSimilarity(String a, String b) {
  final wa = a.isEmpty ? <String>[] : a.split(' ');
  final wb = b.isEmpty ? <String>[] : b.split(' ');
  final longest = math.max(wa.length, wb.length);
  if (longest == 0) return 1;
  return 1 - levenshtein(wa, wb) / longest;
}

int charDistance(String a, String b) => levenshtein(a.split(''), b.split(''));
