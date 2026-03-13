const functions = require('firebase-functions');
const admin = require('firebase-admin');
const { Configuration, OpenAIApi } = require('openai');
admin.initializeApp();
const db = admin.firestore();

exports.onQuizSubmit = functions.firestore
  .document('progress/{uid}/subjects/{subjectId}')
  .onWrite(async (change, context) => {
    const { uid } = context.params;
    const xpGain = 15;
    await db.doc(`users/${uid}`).set({
      xp: admin.firestore.FieldValue.increment(xpGain),
      lastActive: admin.firestore.Timestamp.now(),
    }, { merge: true });
    await updateStreak(uid);
    await updateLeaderboard(uid, xpGain);
  });

async function updateStreak(uid) {
  const userRef = db.doc(`users/${uid}`);
  await db.runTransaction(async tx => {
    const snap = await tx.get(userRef);
    const data = snap.data() || {};
    const last = data.lastActive ? data.lastActive.toDate() : null;
    let streak = data.streak || 0;
    const today = new Date();
    if (!last || diffDays(last, today) > 1) {
      streak = 1;
    } else if (diffDays(last, today) === 1) {
      streak += 1;
    }
    tx.set(userRef, { streak, lastActive: admin.firestore.Timestamp.fromDate(today) }, { merge: true });
  });
}

function diffDays(a, b) {
  const start = new Date(a.getFullYear(), a.getMonth(), a.getDate());
  const end = new Date(b.getFullYear(), b.getMonth(), b.getDate());
  return Math.round((end - start) / 86400000);
}

async function updateLeaderboard(uid, xpGain) {
  const ref = db.doc(`leaderboard/daily/${uid}`);
  await ref.set({
    xp: admin.firestore.FieldValue.increment(xpGain),
    updatedAt: admin.firestore.Timestamp.now(),
  }, { merge: true });
}

exports.generateLesson = functions.https.onCall(async (data, context) => {
  const { subject, topic } = data;
  const key = functions.config().openai.key;
  const ai = new OpenAIApi(new Configuration({ apiKey: key }));
  const prompt = `Create a beginner lesson for ${subject} on ${topic}. Provide concept, example, practice question, and 3 quiz options with answers.`;
  const completion = await ai.createChatCompletion({
    model: 'gpt-4.1-mini',
    messages: [{ role: 'system', content: 'Educational content generator' }, { role: 'user', content: prompt }],
    temperature: 0.5,
  });
  const content = completion.data.choices[0].message?.content ?? '';
  const doc = await db.collection('lessons').add({ subject, topic, content, generated: true });
  return { id: doc.id };
});
