// Popula o Firestore com o curso demonstrativo (mesmo JSON usado pelo modo demo do app).
// Uso: GOOGLE_APPLICATION_CREDENTIALS=./service-account.json npm run seed
import { readFile } from 'node:fs/promises';
import { applicationDefault, initializeApp } from 'firebase-admin/app';
import { FieldValue, getFirestore } from 'firebase-admin/firestore';

const seedPath = new URL('../../app/assets/seed/demo_course.json', import.meta.url);
const data = JSON.parse(await readFile(seedPath, 'utf8'));

initializeApp({ credential: applicationDefault() });
const db = getFirestore();

const collections = ['courses', 'units', 'lessons', 'exercises'];
let batch = db.batch();
let pending = 0;
let total = 0;

for (const name of collections) {
  for (const { id, ...doc } of data[name] ?? []) {
    batch.set(db.collection(name).doc(id), { ...doc, updatedAt: FieldValue.serverTimestamp() }, { merge: true });
    pending++;
    total++;
    if (pending === 450) {
      await batch.commit();
      batch = db.batch();
      pending = 0;
    }
  }
}
if (pending > 0) await batch.commit();

console.log(`✅ ${total} documentos gravados em: ${collections.join(', ')}`);
