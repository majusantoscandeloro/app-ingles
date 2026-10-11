// Placeholder: será sobrescrito ao rodar `flutterfire configure` na pasta app/.
// Enquanto o Firebase não estiver configurado, o app roda em modo demonstração.
import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform =>
      throw UnsupportedError('Firebase ainda não configurado. Rode `flutterfire configure`.');
}
