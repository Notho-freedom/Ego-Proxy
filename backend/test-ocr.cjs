require('dotenv').config();
const Groq = require('groq-sdk');

const sampleOcrTexts = [
  // Exemple 1: Carte d'identité française
  `RÉPUBLIQUE FRANÇAISE
CARTE NATIONALE D'IDENTITÉ
Nom: DUPONT
Prénom(s): Jean Marie
Né(e) le: 15/03/1985
à: PARIS
Sexe: M
Nationalité: Française
N° 123456789012`,

  // Exemple 2: Acte de naissance
  `EXTRAIT D'ACTE DE NAISSANCE
Mairie de Lyon
Le quinze mars mil neuf cent quatre-vingt-cinq
est né MARTIN Sophie
de sexe féminin
à Lyon 3ème arrondissement`,

  // Exemple 3: Format désordonné (test IA)
  `Document officiel
Sophie BERNARD née le 12 janvier 1992 domiciliée à Bordeaux
nationalité française sexe F
numéro CNI: 9876543210`,
];

async function testGroqExtraction() {
  const apiKey = process.env.GROQ_API_KEY;
  
  if (!apiKey) {
    console.error('❌ GROQ_API_KEY non définie dans .env');
    console.log('👉 Va sur https://console.groq.com/keys pour obtenir une clé gratuite');
    process.exit(1);
  }

  console.log('✅ GROQ_API_KEY détectée\n');

  const groq = new Groq.default({ apiKey });

  const systemPrompt = `Tu es un expert en extraction de données de documents d'identité.
Extrais les informations et retourne UNIQUEMENT un objet JSON valide.
Champs: type, lastName, firstName, birthDate (JJ/MM/AAAA), birthPlace, nationality, sex (M/F), documentNumber.
Retourne null pour les champs non trouvés.`;

  for (let i = 0; i < sampleOcrTexts.length; i++) {
    const text = sampleOcrTexts[i];
    console.log(`\n${'='.repeat(50)}`);
    console.log(`📄 TEST ${i + 1}/${sampleOcrTexts.length}`);
    console.log(`${'='.repeat(50)}`);
    console.log('\n📝 Texte OCR:');
    console.log(text);
    
    try {
      const start = Date.now();
      const completion = await groq.chat.completions.create({
        model: 'llama-3.3-70b-versatile',
        messages: [
          { role: 'system', content: systemPrompt },
          { role: 'user', content: `Texte OCR:\n${text}` },
        ],
        temperature: 0.1,
        max_tokens: 500,
        response_format: { type: 'json_object' },
      });
      const elapsed = Date.now() - start;

      const content = completion.choices[0]?.message?.content;
      console.log(`\n✅ Réponse Groq (${elapsed}ms):`);
      
      if (content) {
        const parsed = JSON.parse(content);
        console.log(JSON.stringify(parsed, null, 2));
      }
    } catch (error) {
      console.error(`\n❌ Erreur:`, error.message || error);
    }
  }

  console.log('\n🎉 Tests terminés!\n');
}

testGroqExtraction();
