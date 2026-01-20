import { Injectable, Logger } from '@nestjs/common';
import Groq from 'groq-sdk';

export interface ExtractedDocument {
  type: string;
  lastName?: string;
  firstName?: string;
  birthDate?: string;
  birthPlace?: string;
  nationality?: string;
  sex?: string;
  documentNumber?: string;
  issueDate?: string;
  expiryDate?: string;
  issuingAuthority?: string;
}

@Injectable()
export class AiService {
  private readonly logger = new Logger(AiService.name);
  private groq: Groq | null = null;

  constructor() {
    const apiKey = process.env.GROQ_API_KEY;
    if (apiKey) {
      this.groq = new Groq({ apiKey });
      this.logger.log('Groq AI initialized');
    } else {
      this.logger.warn('GROQ_API_KEY not set - AI extraction disabled');
    }
  }

  isAvailable(): boolean {
    return this.groq !== null;
  }

  async extractDocument(ocrText: string): Promise<ExtractedDocument | null> {
    if (!this.groq) {
      this.logger.warn('Groq not available, skipping AI extraction');
      return null;
    }

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

    try {
      const completion = await this.groq.chat.completions.create({
        model: 'llama-3.3-70b-versatile',
        messages: [
          { role: 'system', content: systemPrompt },
          { role: 'user', content: `Texte OCR:\n${ocrText}` },
        ],
        temperature: 0.1,
        max_tokens: 500,
        response_format: { type: 'json_object' },
      });

      const content = completion.choices[0]?.message?.content;
      if (!content) {
        this.logger.warn('Empty response from Groq');
        return null;
      }

      this.logger.debug(`Groq raw response: ${content}`);

      const parsed = JSON.parse(content) as ExtractedDocument;
      return parsed;
    } catch (error) {
      this.logger.error(`Groq extraction failed: ${error}`);
      return null;
    }
  }
}
