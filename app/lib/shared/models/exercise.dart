import 'model_utils.dart';

/// Enum central de tipos. Tipos desconhecidos (criados no painel para versões
/// futuras do app) viram [unknown] e são ignorados pela sessão.
enum ExerciseType {
  multipleChoice('MULTIPLE_CHOICE', 'Múltipla escolha'),
  translation('TRANSLATION', 'Tradução'),
  wordOrder('WORD_ORDER', 'Montar frase'),
  fillBlank('FILL_BLANK', 'Completar frase'),
  imageSelection('IMAGE_SELECTION', 'Imagem'),
  listen('LISTEN', 'Escuta'),
  speak('SPEAK', 'Fala'),
  unknown('UNKNOWN', 'Desconhecido');

  const ExerciseType(this.value, this.label);
  final String value;
  final String label;

  static ExerciseType fromValue(String? value) => ExerciseType.values.firstWhere(
        (t) => t.value == value,
        orElse: () => ExerciseType.unknown,
      );

  String get defaultInstruction => switch (this) {
        ExerciseType.multipleChoice => 'Selecione a resposta correta',
        ExerciseType.translation => 'Traduza esta frase',
        ExerciseType.wordOrder => 'Monte a frase',
        ExerciseType.fillBlank => 'Complete a frase',
        ExerciseType.imageSelection => 'Selecione a imagem correta',
        ExerciseType.listen => 'O que você ouviu?',
        ExerciseType.speak => 'Fale esta frase',
        ExerciseType.unknown => '',
      };
}

class ExerciseOption {
  const ExerciseOption({required this.text, this.imageUrl, this.emoji});

  final String text;
  final String? imageUrl;
  final String? emoji;

  bool get hasImage => imageUrl != null || emoji != null;

  /// Aceita tanto `"Dog"` quanto `{"text": "Dog", "emoji": "🐶"}`.
  factory ExerciseOption.fromJson(dynamic json) {
    if (json is Map) {
      return ExerciseOption(
        text: (json['text'] ?? '').toString(),
        imageUrl: json['imageUrl'] as String?,
        emoji: json['emoji'] as String?,
      );
    }
    return ExerciseOption(text: json.toString());
  }

  Map<String, dynamic> toJson() => {
        'text': text,
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (emoji != null) 'emoji': emoji,
      };
}

class Exercise {
  const Exercise({
    required this.id,
    required this.lessonId,
    required this.type,
    required this.correctAnswer,
    this.question = '',
    this.instruction,
    this.options = const [],
    this.words = const [],
    this.acceptedAnswers = const [],
    this.explanation,
    this.audioText,
    this.order = 0,
    this.xp = 10,
    this.active = true,
  });

  final String id;
  final String lessonId;
  final ExerciseType type;
  final String question;
  final String? instruction;
  final List<ExerciseOption> options;

  /// Banco de palavras do WORD_ORDER (pode incluir distratores).
  final List<String> words;
  final String correctAnswer;
  final List<String> acceptedAnswers;
  final String? explanation;

  /// Texto falado pelo TTS em LISTEN/SPEAK. Se vazio, usa [correctAnswer].
  final String? audioText;
  final int order;
  final int xp;
  final bool active;

  String get displayInstruction =>
      (instruction != null && instruction!.isNotEmpty) ? instruction! : type.defaultInstruction;

  String get speechText => (audioText != null && audioText!.isNotEmpty) ? audioText! : correctAnswer;

  List<String> get allAcceptedAnswers => [correctAnswer, ...acceptedAnswers];

  factory Exercise.fromMap(String id, Map<String, dynamic> map) => Exercise(
        id: id,
        lessonId: (map['lessonId'] ?? '') as String,
        type: ExerciseType.fromValue(map['type'] as String?),
        question: (map['question'] ?? '') as String,
        instruction: map['instruction'] as String?,
        options: (map['options'] as List? ?? const []).map(ExerciseOption.fromJson).toList(),
        words: parseStringList(map['words']),
        correctAnswer: (map['correctAnswer'] ?? map['expectedAnswer'] ?? '') as String,
        acceptedAnswers: parseStringList(map['acceptedAnswers']),
        explanation: map['explanation'] as String?,
        audioText: map['audioText'] as String?,
        order: parseInt(map['order']),
        xp: parseInt(map['xp'], 10),
        active: map['active'] != false,
      );
}
