"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
require("dotenv/config");
const groq_sdk_1 = __importDefault(require("groq-sdk"));
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
à Lyon 3ème arrondissement
Père: MARTIN Pierre, né le 10/01/1960
Mère: MARTIN née BERNARD Marie, née le 22/06/1962`,
    // Exemple 3: Passeport (format MRZ simulé)
    `PASSEPORT
RÉPUBLIQUE FRANÇAISE
Nom / Surname: LECLERC
Prénoms / Given names: Antoine François
Date de naissance / Date of birth: 28 JUN 1990
Lieu de naissance / Place of birth: MARSEILLE
Sexe / Sex: M
Nationalité / Nationality: FRANÇAISE
N° Passeport: 20AB12345
Date d'expiration: 15/09/2030`,
    // Exemple 4: Format désordonné (test IA)
    `Document officiel
Sophie BERNARD née le 12 janvier 1992 domiciliée à Bordeaux
nationalité française sexe F
numéro CNI: 9876543210
délivré par la préfecture de Gironde`,
];
async function testGroqExtraction() {
    const apiKey = process.env.GROQ_API_KEY;
    if (!apiKey) {
        console.error('❌ GROQ_API_KEY non définie dans .env');
        console.log('\n👉 Va sur https://console.groq.com/keys pour obtenir une clé gratuite');
        process.exit(1);
    }
    console.log('✅ GROQ_API_KEY détectée\n');
    const groq = new groq_sdk_1.default({ apiKey });
    const systemPrompt = `Tu es un expert en extraction de données de documents d'identité et d'état civil.
À partir du texte OCR brut fourni, extrais les informations et retourne UNIQUEMENT un objet JSON valide.

Types de documents possibles:
- "Passeport"
- "Carte d'identité"
- "Acte de naissance"
- "Acte de mariage"
- "Acte de décès"
- "Livret de famille"
- "Permis de conduire"
- "Document officiel" (si type non identifiable)

Champs à extraire (laisse null si non trouvé):
{
  "type": "string - type du document",
  "lastName": "string - nom de famille",
  "firstName": "string - prénom(s)",
  "birthDate": "string - date de naissance au format JJ/MM/AAAA",
  "birthPlace": "string - lieu de naissance",
  "nationality": "string - nationalité",
  "sex": "string - M ou F",
  "documentNumber": "string - numéro du document",
  "issueDate": "string - date d'émission au format JJ/MM/AAAA",
  "expiryDate": "string - date d'expiration au format JJ/MM/AAAA",
  "issuingAuthority": "string - autorité de délivrance"
}

IMPORTANT:
- Retourne UNIQUEMENT le JSON, sans markdown, sans explication
- Les noms propres en MAJUSCULES
- Les dates au format JJ/MM/AAAA
- Si le texte est illisible ou ne contient pas d'infos exploitables, retourne {"type": "Document officiel"}`;
    for (let i = 0; i < sampleOcrTexts.length; i++) {
        const text = sampleOcrTexts[i];
        console.log(`\n${'='.repeat(60)}`);
        console.log(`📄 TEST ${i + 1}/${sampleOcrTexts.length}`);
        console.log(`${'='.repeat(60)}`);
        console.log('\n📝 Texte OCR:');
        console.log(text.split('\n').map(l => `   ${l}`).join('\n'));
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
            else {
                console.log('   (réponse vide)');
            }
        }
        catch (error) {
            console.error(`\n❌ Erreur:`, error);
        }
    }
    console.log(`\n${'='.repeat(60)}`);
    console.log('🎉 Tests terminés!');
    console.log(`${'='.repeat(60)}\n`);
}
testGroqExtraction();
//# sourceMappingURL=test-ocr.js.map