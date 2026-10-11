// Concede (ou remove) o papel de administrador via custom claim.
// Uso: GOOGLE_APPLICATION_CREDENTIALS=./service-account.json node set-admin.mjs email@dominio.com [--remove]
import { applicationDefault, initializeApp } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';

const [email, flag] = process.argv.slice(2);
if (!email) {
  console.error('Informe o e-mail: node set-admin.mjs email@dominio.com [--remove]');
  process.exit(1);
}

initializeApp({ credential: applicationDefault() });
const auth = getAuth();
const user = await auth.getUserByEmail(email);
const admin = flag !== '--remove';

await auth.setCustomUserClaims(user.uid, { ...(user.customClaims ?? {}), admin });
console.log(`✅ ${email} agora ${admin ? 'é' : 'não é'} ADMIN. O usuário precisa sair e entrar novamente.`);
