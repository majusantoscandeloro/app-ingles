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

int levenshtein(List<Object> a, List<Object> b, {bool Function(Object a, Object b)? equals}) {
  if (a.isEmpty) return b.length;
  if (b.isEmpty) return a.length;
  bool same(Object x, Object y) => equals?.call(x, y) ?? x == y;
  var previous = List<int>.generate(b.length + 1, (i) => i);
  for (var i = 1; i <= a.length; i++) {
    final current = List<int>.filled(b.length + 1, 0)..[0] = i;
    for (var j = 1; j <= b.length; j++) {
      final cost = same(a[i - 1], b[j - 1]) ? 0 : 1;
      current[j] = math.min(
        math.min(current[j - 1] + 1, previous[j] + 1),
        previous[j - 1] + cost,
      );
    }
    previous = current;
  }
  return previous[b.length];
}

/// Remove consoantes repetidas em sequência (`anna` → `ana`).
/// Vogais dobradas ficam, para `good` não virar `god`.
String withoutRepeatedConsonants(String word) {
  if (word.isEmpty) return word;
  final buffer = StringBuffer(word[0]);
  for (var i = 1; i < word.length; i++) {
    final repeatedConsonant = word[i] == word[i - 1] && !'aeiou'.contains(word[i]);
    if (!repeatedConsonant) buffer.write(word[i]);
  }
  return buffer.toString();
}

bool sameSpokenWord(String a, String b) => a == b || withoutRepeatedConsonants(a) == withoutRepeatedConsonants(b);

/// Similaridade (0–1) por palavras, usada na comparação de fala.
double wordSimilarity(String a, String b) => _tokenSimilarity(a, b);

/// Igual a [wordSimilarity], mas aceita consoante dobrada pelo reconhecedor
/// (`Ana` ouvida como `Anna`).
double spokenSimilarity(String a, String b) =>
    _tokenSimilarity(a, b, equals: (x, y) => sameSpokenWord(x as String, y as String));

double _tokenSimilarity(String a, String b, {bool Function(Object, Object)? equals}) {
  final wa = a.isEmpty ? <String>[] : a.split(' ');
  final wb = b.isEmpty ? <String>[] : b.split(' ');
  final longest = math.max(wa.length, wb.length);
  if (longest == 0) return 1;
  return 1 - levenshtein(wa, wb, equals: equals) / longest;
}

int charDistance(String a, String b) => levenshtein(a.split(''), b.split(''));
