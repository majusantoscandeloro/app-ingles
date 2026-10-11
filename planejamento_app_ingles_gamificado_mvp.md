# Planejamento do Aplicativo de Inglês Gamificado

## 1. Visão Geral

Este documento define a estrutura inicial para desenvolvimento de um aplicativo de aprendizado de inglês inspirado na experiência de uso de plataformas como Duolingo, porém com escopo reduzido e foco em um MVP viável, escalável e com baixo custo operacional.

O objetivo inicial não é reproduzir todas as funcionalidades existentes em grandes plataformas de idiomas, mas criar uma base sólida com:

- aprendizado por unidades e lições;
- exercícios interativos;
- áudio;
- reconhecimento básico de fala;
- progresso do aluno;
- gamificação;
- painel administrativo para criação e manutenção do conteúdo;
- estrutura preparada para futuras funcionalidades com Inteligência Artificial.

---

# 2. Objetivo do MVP

O MVP deve permitir que um aluno:

1. crie uma conta;
2. acesse um curso de inglês;
3. avance por unidades e lições;
4. realize diferentes tipos de exercícios;
5. escute palavras e frases;
6. fale palavras e frases pelo microfone;
7. receba feedback básico;
8. acumule XP;
9. mantenha uma sequência diária de estudos;
10. acompanhe seu progresso;
11. revise exercícios que errou;
12. receba notificações para continuar estudando.

O administrador/professor deve conseguir cadastrar e editar todo o conteúdo sem necessidade de alteração no código do aplicativo.

---

# 3. Plataformas

## Aplicativo

Desenvolvimento principal:

- Flutter

Plataformas:

- Android
- iOS

## Painel Administrativo

Sugestão:

- React
- Next.js

Responsabilidades do painel:

- cadastrar cursos;
- cadastrar unidades;
- cadastrar lições;
- criar exercícios;
- ordenar conteúdos;
- ativar/desativar aulas;
- visualizar alunos;
- visualizar progresso dos alunos;
- acompanhar métricas básicas.

---

# 4. Stack Inicial

## Mobile

- Flutter
- Dart

## Backend

Para o MVP:

- Firebase Authentication
- Cloud Firestore
- Firebase Storage
- Firebase Cloud Messaging
- Cloud Functions quando necessário

## Painel Web

- Next.js
- React
- Firebase SDK

## Recursos locais do dispositivo

Para reduzir custos:

- Text-to-Speech nativo
- Speech-to-Text nativo
- armazenamento local para cache;
- notificações locais quando fizer sentido.

---

# 5. Estrutura Principal do Produto

A estrutura pedagógica será:

```text
Curso
 └── Unidade
      └── Lição
           └── Exercícios
```

Exemplo:

```text
Curso: Inglês Básico

Unidade 1 - Primeiros passos
    Aula 1 - Cumprimentos
    Aula 2 - Apresentação
    Aula 3 - Números
    Aula 4 - Cores
    Aula 5 - Revisão

Unidade 2 - Situações do cotidiano
    Aula 1 - Restaurante
    Aula 2 - Compras
    Aula 3 - Transporte
```

---

# 6. Fluxo Principal do Aluno

```text
Login
   ↓
Tela inicial
   ↓
Trilha de aprendizado
   ↓
Selecionar lição
   ↓
Realizar exercícios
   ↓
Resultado da lição
   ↓
Ganhar XP
   ↓
Atualizar progresso
   ↓
Liberar próxima lição
```

---

# 7. Telas do MVP

## 7.1 Splash

Exibir:

- logo;
- mascote;
- carregamento inicial.

---

## 7.2 Onboarding

Apresentação rápida do aplicativo.

Possíveis telas:

1. Aprenda inglês de forma prática.
2. Complete lições curtas.
3. Ganhe XP e mantenha sua sequência.
4. Pratique leitura, escuta e fala.

---

## 7.3 Login e Cadastro

Funcionalidades:

- email e senha;
- recuperação de senha;
- login Google;
- login Apple no iOS.

Dados mínimos:

- nome;
- email;
- data de cadastro;
- nível inicial;
- XP;
- sequência atual.

---

# 8. Teste Inicial de Nível

Pode ser opcional no MVP.

O aluno responde algumas questões simples.

Possíveis resultados:

- Iniciante
- Básico
- Intermediário

No MVP, o teste pode ser apenas indicativo.

Não é necessário criar inicialmente um sistema pedagógico avançado de classificação automática.

---

# 9. Tela Inicial / Trilha

Principal tela do aplicativo.

Exemplo:

```text
🔥 5 dias               ⭐ 450 XP

        UNIDADE 1
     Primeiros passos

           ●
           │
           ●
           │
          🎧
           │
          🎤
           │
          🏆

        UNIDADE 2
            🔒
```

Cada ponto representa uma lição.

Estados possíveis:

- disponível;
- concluída;
- bloqueada;
- revisão;
- desafio final.

---

# 10. Tipos de Exercícios do MVP

O sistema deve ser construído para aceitar vários tipos de exercícios.

## 10.1 Múltipla Escolha

Exemplo:

```text
What does "dog" mean?

○ Gato
○ Cachorro
○ Cavalo
○ Pássaro
```

---

## 10.2 Tradução

Exemplo:

```text
Translate:

Eu gosto de café.

Resposta:
I like coffee.
```

---

## 10.3 Montar Frase

Exemplo:

```text
Monte a frase:

[I] [coffee] [like]
```

Resposta:

```text
I like coffee.
```

---

## 10.4 Completar Frase

```text
I ___ Brazilian.

○ am
○ is
○ are
○ be
```

---

## 10.5 Associação com Imagem

Exemplo:

```text
Which image represents "apple"?
```

O aluno seleciona uma imagem.

---

# 11. Áudio

O MVP deve possuir exercícios de escuta.

Exemplo:

```text
🔊

"Where are you from?"

○ Qual o seu nome?
○ De onde você é?
○ Onde você mora?
```

## Estratégia de baixo custo

Inicialmente utilizar Text-to-Speech do próprio dispositivo.

Flutter:

```text
flutter_tts
```

Benefícios:

- não precisa armazenar milhares de arquivos de áudio;
- reduz custo de API;
- geração automática;
- suporte a diferentes vozes disponíveis no dispositivo.

Futuramente poderá ser substituído por:

- áudio gravado por professores;
- Google Cloud Text-to-Speech;
- Azure Speech;
- ElevenLabs;
- OpenAI Voice;
- outros provedores.

---

# 12. Exercícios de Fala

É possível adicionar fala já no MVP sem criar um sistema complexo de avaliação fonética.

Exemplo:

```text
🎤 FALE

"I would like a coffee."

[ Iniciar gravação ]
```

O aplicativo converte a fala do aluno em texto.

Resultado esperado:

```text
I would like a coffee
```

O sistema compara o resultado reconhecido com a frase esperada.

---

# 13. Reconhecimento de Voz no MVP

Sugestão Flutter:

```text
speech_to_text
```

Possível fluxo:

```text
Aluno toca no microfone
        ↓
Sistema inicia reconhecimento
        ↓
Aluno fala
        ↓
Speech-to-Text retorna texto
        ↓
Sistema normaliza o texto
        ↓
Compara com a resposta esperada
        ↓
Exibe resultado
```

Exemplo:

Frase esperada:

```text
I would like a coffee
```

Reconhecimento:

```text
I would like a coffee
```

Resultado:

```text
✅ Muito bem!
```

Outro exemplo:

```text
I like coffee
```

Resultado:

```text
🟡 Quase! Tente novamente.
```

---

# 14. Limitação da Pronúncia no MVP

O reconhecimento básico deve responder principalmente:

> O sistema conseguiu reconhecer o que o aluno falou?

Não deverá inicialmente avaliar de forma detalhada:

- fonemas;
- sotaque;
- entonação;
- pronúncia individual de cada palavra;
- fluência;
- precisão fonética.

Portanto, inicialmente evitar resultados como:

```text
Pronúncia: 92%
Fluência: 87%
Entonação: 73%
```

Esse tipo de recurso deverá entrar em uma futura versão avançada.

---

# 15. Sistema de Respostas

Cada exercício deve possuir:

- resposta correta;
- possíveis respostas aceitas;
- explicação opcional;
- pontuação;
- tentativas.

Exemplo:

```text
Resposta correta:
I am Brazilian.

Respostas aceitas:
I'm Brazilian.
I am brazilian.
```

O sistema poderá normalizar:

- letras maiúsculas;
- pontuação;
- espaços extras.

---

# 16. Resultado da Lição

Ao concluir uma lição:

```text
🎉 Aula concluída!

8 / 10 corretas

+100 XP

Precisão: 80%

🔥 Sequência: 5 dias
```

Botões:

- Continuar
- Revisar erros
- Voltar para trilha

---

# 17. XP

Sistema simples de experiência.

Exemplo:

```text
Resposta correta: +10 XP
Lição concluída: +20 XP
Lição perfeita: +30 XP bônus
```

Possíveis níveis:

```text
Nível 1
Nível 2
Nível 3
...
```

Inicialmente o nível pode ser apenas gamificação e não representar nível real de inglês.

---

# 18. Sequência Diária

Sistema de streak.

Exemplo:

```text
🔥 7 dias
```

Regras iniciais:

- completou pelo menos uma lição no dia;
- sequência aumenta;
- não estudou durante o dia;
- sequência volta para zero.

Futuramente poderá existir:

- proteção de sequência;
- itens especiais;
- congelamento da streak.

---

# 19. Sistema de Corações

Inicialmente:

```text
❤️ ❤️ ❤️ ❤️ ❤️
```

Cada erro:

```text
❤️ ❤️ ❤️ ❤️
```

Ao perder todos:

Possíveis alternativas:

1. aguardar período;
2. realizar revisão;
3. assistir anúncio;
4. possuir plano premium.

Para o primeiro MVP, o sistema pode ser simplificado.

---

# 20. Revisão de Erros

Cada erro deve ser registrado.

Estrutura:

```text
user_errors
```

Informações:

- usuário;
- exercício;
- resposta enviada;
- resposta correta;
- data;
- quantidade de erros.

Tela:

```text
Praticar

12 exercícios para revisar
```

O sistema poderá reapresentar exercícios errados.

---

# 21. Gamificação Inicial

MVP:

- XP;
- streak;
- corações;
- progresso;
- lições desbloqueadas;
- conclusão de unidade.

Não obrigatório inicialmente:

- moedas;
- loja;
- ligas;
- ranking complexo.

---

# 22. Conquistas

Pode entrar ainda no MVP caso o prazo permita.

Exemplos:

```text
🏆 Primeira aula
Complete sua primeira aula

🔥 Uma semana
Estude durante 7 dias seguidos

🎧 Bom ouvinte
Complete 20 exercícios de áudio

🎤 Falante
Complete 20 exercícios de fala
```

---

# 23. Mascote

O mascote deve ser utilizado como identidade visual e ferramenta de feedback.

No MVP não é necessário utilizar animação complexa.

Possíveis estados:

- normal;
- feliz;
- comemorando;
- pensando;
- triste;
- incentivando;
- sequência;
- unidade concluída.

Quantidade inicial sugerida:

```text
8 a 15 ilustrações
```

Formatos:

- PNG;
- WebP;
- SVG.

Futuramente:

- Rive;
- Lottie;
- animações completas.

---

# 24. Notificações

Firebase Cloud Messaging.

Exemplos:

```text
🔥 Não perca sua sequência de 5 dias!

Sua próxima aula já está disponível.

Você tem exercícios para revisar.

Faltam poucos minutos para manter sua sequência de hoje.
```

---

# 25. Perfil

Informações:

- foto;
- nome;
- XP;
- sequência;
- aulas concluídas;
- unidades concluídas;
- conquistas.

Exemplo:

```text
Thauan

🔥 14 dias

⭐ 2.430 XP

Aulas concluídas: 42
```

---

# 26. Painel Administrativo

O painel é parte essencial do sistema.

Não desenvolver as aulas diretamente no código.

Estrutura:

```text
Dashboard

Cursos
Unidades
Lições
Exercícios
Alunos
Relatórios
Configurações
```

---

# 27. Cadastro de Curso

Campos:

- nome;
- descrição;
- imagem;
- nível;
- ativo/inativo.

Exemplo:

```text
Inglês Básico
Nível: A1
```

---

# 28. Cadastro de Unidade

Campos:

- curso;
- nome;
- descrição;
- ordem;
- imagem;
- status.

---

# 29. Cadastro de Lição

Campos:

- unidade;
- título;
- descrição;
- ordem;
- XP concedido;
- quantidade de vidas;
- status.

---

# 30. Cadastro de Exercício

O administrador escolhe o tipo.

```text
Tipo:

○ Múltipla escolha
○ Tradução
○ Montar frase
○ Completar frase
○ Imagem
○ Escuta
○ Fala
```

Campos dinâmicos de acordo com o exercício.

---

# 31. Exemplo de Exercício

```json
{
  "type": "MULTIPLE_CHOICE",
  "question": "What does dog mean?",
  "options": [
    "Cat",
    "Dog",
    "Horse",
    "Bird"
  ],
  "correctAnswer": "Dog",
  "xp": 10
}
```

---

# 32. Estrutura Inicial do Firestore

Sugestão:

```text
users
courses
units
lessons
exercises
user_progress
user_answers
user_errors
user_streaks
achievements
notifications
```

---

# 33. Users

Exemplo:

```json
{
  "name": "Aluno",
  "email": "aluno@email.com",
  "xp": 450,
  "currentStreak": 5,
  "longestStreak": 12,
  "hearts": 4,
  "createdAt": "timestamp"
}
```

---

# 34. Courses

```json
{
  "name": "Inglês Básico",
  "level": "A1",
  "active": true,
  "order": 1
}
```

---

# 35. Units

```json
{
  "courseId": "course_id",
  "title": "Primeiros passos",
  "order": 1,
  "active": true
}
```

---

# 36. Lessons

```json
{
  "unitId": "unit_id",
  "title": "Cumprimentos",
  "order": 1,
  "xp": 100,
  "active": true
}
```

---

# 37. Exercises

```json
{
  "lessonId": "lesson_id",
  "type": "SPEAK",
  "question": "Say the sentence",
  "expectedAnswer": "Good morning",
  "order": 4,
  "xp": 10
}
```

---

# 38. User Progress

```json
{
  "userId": "user_id",
  "courseId": "course_id",
  "unitId": "unit_id",
  "lessonId": "lesson_id",
  "completed": true,
  "score": 90,
  "completedAt": "timestamp"
}
```

---

# 39. Organização dos Tipos de Exercício

Criar enum central.

Exemplo:

```text
MULTIPLE_CHOICE
TRANSLATION
WORD_ORDER
FILL_BLANK
IMAGE_SELECTION
LISTEN
SPEAK
```

Isso permitirá adicionar novos tipos posteriormente.

---

# 40. Arquitetura Flutter

Estrutura sugerida:

```text
lib/

core/
    constants/
    services/
    theme/
    utils/

features/

    auth/
    home/
    courses/
    lessons/
    exercises/
    progress/
    profile/
    achievements/
    streak/

shared/

    widgets/
    models/
```

---

# 41. Estados do Exercício

Cada exercício deverá seguir um fluxo padrão:

```text
NOT_STARTED
ANSWERING
CORRECT
INCORRECT
COMPLETED
```

Isso facilita reutilização da interface.

---

# 42. Controle de Progresso

O desbloqueio deverá seguir regras simples.

Exemplo:

```text
Aula 1 concluída
        ↓
Aula 2 desbloqueada
        ↓
Aula 2 concluída
        ↓
Aula 3 desbloqueada
```

Pode existir uma configuração futura permitindo aulas independentes.

---

# 43. Conteúdo Pedagógico

O aplicativo fornece a tecnologia.

A criação pedagógica deverá ser tratada separadamente.

O cliente/professor deverá fornecer:

- cursos;
- unidades;
- lições;
- frases;
- exercícios;
- traduções;
- imagens;
- explicações;
- metodologia.

O sistema deverá permitir cadastrar tudo pelo painel.

---

# 44. Conteúdo Inicial

Para desenvolvimento e testes, criar um curso demonstrativo.

Exemplo:

```text
Curso Demo - Inglês Básico

Unidade 1
- Hello
- Good morning
- Good afternoon
- Good night

Unidade 2
- My name is...
- I am from...
- I live in...
```

Quantidade inicial sugerida:

```text
2 unidades
3 aulas por unidade
8 a 10 exercícios por aula
```

Isso é suficiente para validar a experiência.

---

# 45. Monetização

A monetização não precisa ser desenvolvida na primeira etapa caso ainda não exista modelo comercial definido.

Possíveis modelos futuros:

## Assinatura

```text
Mensal
Anual
```

## Freemium

Grátis:

- algumas unidades;
- limite de vidas;
- anúncios.

Premium:

- sem anúncios;
- vidas ilimitadas;
- conteúdos completos;
- IA;
- análise avançada.

## Escola / Curso

O aluno recebe acesso por:

- convite;
- código;
- matrícula;
- assinatura vinculada à escola.

---

# 46. Anúncios

Caso seja adotado modelo gratuito:

Possível integração:

- Google AdMob

Locais possíveis:

- após uma lição;
- recuperação de coração;
- bônus de XP.

Evitar excesso de anúncios durante exercícios.

---

# 47. MVP - Funcionalidades Obrigatórias

Checklist:

- [ ] Flutter Android
- [ ] Flutter iOS
- [ ] Login
- [ ] Cadastro
- [ ] Recuperação de senha
- [ ] Tela inicial
- [ ] Trilha
- [ ] Cursos
- [ ] Unidades
- [ ] Lições
- [ ] Múltipla escolha
- [ ] Tradução
- [ ] Montar frase
- [ ] Completar frase
- [ ] Exercício com imagem
- [ ] Exercício de áudio
- [ ] Exercício de fala
- [ ] Speech-to-Text
- [ ] Text-to-Speech
- [ ] XP
- [ ] Streak
- [ ] Corações
- [ ] Progresso
- [ ] Revisão de erros
- [ ] Perfil
- [ ] Notificações
- [ ] Painel administrativo
- [ ] Cadastro de curso
- [ ] Cadastro de unidade
- [ ] Cadastro de aula
- [ ] Cadastro de exercícios

---

# 48. Funcionalidades que Podem Entrar Depois do MVP

## Ranking

Ranking:

- semanal;
- mensal;
- entre amigos;
- entre alunos da escola.

---

## Moedas

Moedas virtuais.

Podem ser utilizadas para:

- recuperar vidas;
- comprar itens;
- desbloquear conteúdo;
- proteger streak.

---

## Loja

Itens:

- proteção de sequência;
- avatar;
- roupas para mascote;
- temas.

---

## Amigos

Funcionalidades:

- adicionar amigos;
- acompanhar XP;
- desafios;
- ranking.

---

# 49. Atualização Futura - Inteligência Artificial

A arquitetura deve ser preparada para IA, porém não é necessário integrar no MVP.

Possíveis integrações:

- OpenAI;
- Gemini;
- Claude;
- modelos próprios;
- APIs especializadas em educação.

---

# 50. IA para Conversação

Tela futura:

```text
Conversation Practice
```

Exemplo:

```text
IA:
Hello! What is your name?

Aluno:
My name is João.

IA:
Nice to meet you, João.
Where are you from?
```

Pode funcionar por:

- texto;
- voz;
- ambos.

---

# 51. IA com Voz

Fluxo:

```text
Aluno fala
    ↓
Speech-to-Text
    ↓
IA interpreta
    ↓
IA responde
    ↓
Text-to-Speech
    ↓
Aluno escuta
```

Isso cria uma experiência semelhante a uma conversa com professor virtual.

---

# 52. IA para Correção de Frases

Aluno escreve:

```text
I have 20 years.
```

IA responde:

```text
O correto seria:

I am 20 years old.

Em inglês usamos o verbo "to be" para falar idade.
```

---

# 53. IA para Criar Exercícios

O professor poderá futuramente escrever:

```text
Criar 10 exercícios sobre verbos no presente.
Nível A1.
```

A IA poderá gerar:

- perguntas;
- alternativas;
- respostas;
- explicações.

O professor revisa antes de publicar.

---

# 54. IA para Revisão Personalizada

O sistema poderá analisar erros.

Exemplo:

```text
Aluno possui dificuldade em:

- Simple Present
- Verb to be
- Prepositions
```

A IA gera automaticamente uma sessão:

```text
Revisão personalizada
10 exercícios
```

---

# 55. Avaliação Avançada de Pronúncia

Versão futura.

O sistema poderá avaliar:

- precisão;
- fluência;
- pronúncia;
- ritmo;
- entonação;
- fonemas.

Exemplo:

```text
Pronúncia: 87%
Fluência: 92%
Precisão: 81%
```

Possíveis provedores:

- Azure Speech Pronunciation Assessment;
- Google Speech;
- APIs especializadas.

---

# 56. Feedback de Pronúncia

Exemplo futuro:

```text
Palavra:
THREE

Resultado:

TH: precisa melhorar
R: correto
EE: correto
```

Poderá incluir instruções:

```text
Posicione a língua levemente entre os dentes ao pronunciar "TH".
```

---

# 57. IA como Professor Virtual

Possível recurso premium.

Usuário poderá escolher:

```text
Treinar:
- Restaurante
- Aeroporto
- Hotel
- Trabalho
- Entrevista
- Viagem
```

Exemplo:

```text
Você está em um restaurante.

IA:
Good evening!
What would you like to order?
```

---

# 58. Cenários Interativos

Versão futura.

Exemplo:

```text
Missão:

Pedir comida em um restaurante.
```

Objetivos:

```text
✓ Cumprimentar
✓ Pedir bebida
✓ Pedir comida
✓ Solicitar conta
```

---

# 59. Personagens com IA

Futuramente cada personagem poderá possuir:

- personalidade;
- voz;
- nível de dificuldade;
- contexto;
- estilo de conversa.

Exemplo:

```text
Emma
Professora amigável
Nível A1-A2
```

---

# 60. Avatares Animados

Versão avançada.

Tecnologias possíveis:

- Rive;
- Lottie;
- Live2D;
- 3D;
- geração de avatar por IA.

Não recomendado para MVP.

---

# 61. Sistema Adaptativo

Versão futura avançada.

O sistema aprende quais conteúdos o aluno possui maior dificuldade.

Exemplo:

```text
Sistema detectou:

Simple Past: 58% acerto
Vocabulary: 91%
Listening: 72%
```

O algoritmo passa a apresentar mais exercícios de Simple Past.

---

# 62. Dashboard Inteligente

Futuramente:

```text
Seu desempenho

Vocabulário      92%
Leitura          88%
Listening        73%
Speaking         65%
Gramática        81%
```

---

# 63. Roadmap

## Fase 1 - Base

- projeto Flutter;
- Firebase;
- autenticação;
- estrutura de cursos;
- estrutura de unidades;
- estrutura de aulas.

---

## Fase 2 - Motor de Exercícios

Criar sistema reutilizável para:

- múltipla escolha;
- tradução;
- montar frase;
- completar frase;
- imagem.

---

## Fase 3 - Áudio e Voz

Adicionar:

- Text-to-Speech;
- Speech-to-Text;
- exercícios de listening;
- exercícios de speaking.

---

## Fase 4 - Gamificação

Adicionar:

- XP;
- streak;
- corações;
- progresso;
- conquistas.

---

## Fase 5 - Painel Administrativo

Criar:

- gestão de cursos;
- gestão de unidades;
- gestão de aulas;
- gestão de exercícios;
- visualização de alunos.

---

## Fase 6 - Revisão

Adicionar:

- registro de erros;
- tela de revisão;
- estatísticas básicas.

---

## Fase 7 - Publicação

- Google Play;
- App Store;
- Firebase produção;
- analytics;
- crash reporting.

---

## Fase 8 - Monetização

Caso necessário:

- assinatura;
- premium;
- anúncios;
- controle de acesso.

---

## Fase 9 - Inteligência Artificial

Adicionar progressivamente:

1. correção de frases;
2. geração de exercícios;
3. conversação em texto;
4. conversação por voz;
5. feedback inteligente;
6. revisão personalizada.

---

## Fase 10 - Pronúncia Avançada

Adicionar:

- score de pronúncia;
- fonemas;
- fluência;
- feedback detalhado.

---

# 64. Funcionalidades Fora do MVP

Evitar inicialmente:

- conversa ilimitada com IA;
- avaliação fonética avançada;
- dezenas de personagens animados;
- vídeos gerados por IA;
- avatares 3D;
- multiplayer;
- ranking complexo;
- ligas;
- loja avançada;
- algoritmo adaptativo sofisticado;
- geração automática de curso completo;
- videochamada com IA;
- sincronização offline completa.

---

# 65. Regra de Desenvolvimento

Toda funcionalidade deve ser criada pensando em expansão.

Evitar regras fixas dentro das telas.

Exemplo ruim:

```text
Aula 1 = múltipla escolha
Aula 2 = áudio
```

Exemplo correto:

```text
lesson.exercises[]

exercise.type
```

A interface decide qual componente renderizar baseado no tipo.

---

# 66. Motor de Exercícios

Idealmente criar um componente central:

```text
ExerciseRenderer
```

Exemplo lógico:

```text
if MULTIPLE_CHOICE
    MultipleChoiceExercise

if TRANSLATION
    TranslationExercise

if WORD_ORDER
    WordOrderExercise

if LISTEN
    ListeningExercise

if SPEAK
    SpeakingExercise
```

Assim novos exercícios poderão ser adicionados no futuro.

---

# 67. Eventos Importantes para Analytics

Registrar eventos como:

```text
lesson_started
lesson_completed
exercise_answered
exercise_wrong
exercise_correct
speaking_started
speaking_completed
streak_updated
unit_completed
```

Isso será importante futuramente para entender:

- onde usuários abandonam;
- quais exercícios são mais difíceis;
- quais aulas possuem maior erro;
- frequência de estudo.

---

# 68. Segurança

Criar regras para que:

Aluno:

- leia cursos liberados;
- registre apenas seu próprio progresso.

Administrador:

- possa criar e editar conteúdo.

Nunca permitir que o aplicativo cliente tenha controle administrativo apenas por interface.

Utilizar:

- Firebase Security Rules;
- Custom Claims ou roles;
- validações no backend quando necessário.

---

# 69. Roles

Sugestão:

```text
STUDENT
TEACHER
ADMIN
SUPER_ADMIN
```

Inicialmente podem ser usados:

```text
STUDENT
ADMIN
```

---

# 70. Objetivo Final do MVP

O usuário precisa sentir que:

> está avançando em um curso;

e não simplesmente:

> respondendo um formulário.

Para isso, os elementos mais importantes são:

1. trilha visual;
2. aulas curtas;
3. diferentes tipos de exercícios;
4. áudio;
5. fala;
6. feedback imediato;
7. XP;
8. sequência;
9. progresso;
10. desbloqueio de conteúdo.

Esses elementos geram a experiência principal de um aplicativo gamificado de idiomas sem exigir a complexidade de uma grande plataforma.

---

# 71. Resumo Técnico

```text
APP
Flutter
Android + iOS

BACKEND
Firebase

DATABASE
Cloud Firestore

AUTH
Firebase Authentication

FILES
Firebase Storage

PUSH
Firebase Cloud Messaging

AUDIO
Text-to-Speech nativo

VOICE
Speech-to-Text nativo

ADMIN
Next.js / React

FUTURO
IA
Pronúncia avançada
Professor virtual
Conversação
Sistema adaptativo
```

---

# 72. Prioridade do Projeto

Ordem recomendada:

```text
1. Estrutura do projeto
2. Autenticação
3. Banco de dados
4. Cursos
5. Unidades
6. Lições
7. Motor de exercícios
8. Progresso
9. Áudio
10. Fala
11. XP
12. Streak
13. Corações
14. Revisão
15. Painel administrativo
16. Notificações
17. Publicação
18. Monetização
19. IA
```

---

# 73. Princípio Principal

O MVP deve ser:

- simples;
- visualmente agradável;
- rápido;
- gamificado;
- barato de operar;
- fácil de administrar;
- preparado para crescimento.

A primeira versão deve validar:

> Os usuários realmente utilizam o aplicativo para aprender e continuam voltando?

Somente após validar isso devem ser adicionados recursos mais caros e complexos como Inteligência Artificial, avaliação avançada de pronúncia e personagens altamente interativos.
