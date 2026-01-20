import { Injectable, Logger } from '@nestjs/common';
import { AiService, ExtractedDocument } from '../ai/ai.service';

@Injectable()
export class OcrService {
  private readonly logger = new Logger(OcrService.name);

  constructor(private readonly aiService: AiService) {}

  async extractFromText(fileName: string, text: string) {
    // Essayer d'abord l'extraction IA
    if (this.aiService.isAvailable()) {
      this.logger.log('Using AI extraction (Groq)');
      const aiResult = await this.aiService.extractDocument(text);
      if (aiResult && this.isValidAiResult(aiResult)) {
        this.logger.log('AI extraction successful');
        return this.buildFromAiResult(fileName, aiResult, text);
      }
      this.logger.warn('AI extraction returned empty/invalid result, falling back to regex');
    } else {
      this.logger.log('AI not available, using regex extraction');
    }

    // Fallback: extraction regex classique
    return this.extractWithRegex(fileName, text);
  }

  private isValidAiResult(result: ExtractedDocument): boolean {
    // Considérer valide si au moins un champ utile est présent
    return !!(
      result.lastName ||
      result.firstName ||
      result.birthDate ||
      result.birthPlace ||
      result.documentNumber
    );
  }

  private buildFromAiResult(fileName: string, ai: ExtractedDocument, text: string) {
    const name = [ai.lastName, ai.firstName].filter(Boolean).join(' ') || undefined;

    const fields = [
      { label: 'Fichier', value: fileName, confidence: 1 },
      { label: 'Type', value: ai.type || 'Document officiel', confidence: 0.95 },
      { label: 'Nom', value: name ?? 'Non détecté', confidence: name ? 0.95 : 0.4 },
      { label: 'Date de naissance', value: ai.birthDate ?? 'Non détectée', confidence: ai.birthDate ? 0.95 : 0.4 },
      { label: 'Lieu de naissance', value: ai.birthPlace ?? 'Non détecté', confidence: ai.birthPlace ? 0.95 : 0.4 },
      { label: 'Nationalité', value: ai.nationality ?? 'Non détectée', confidence: ai.nationality ? 0.95 : 0.4 },
      { label: 'Sexe', value: ai.sex ?? 'Non détecté', confidence: ai.sex ? 0.95 : 0.4 },
      { label: 'Numéro document', value: ai.documentNumber ?? 'Non détecté', confidence: ai.documentNumber ? 0.95 : 0.4 },
      { label: "Date d'émission", value: ai.issueDate ?? 'Non détectée', confidence: ai.issueDate ? 0.9 : 0.4 },
      { label: "Date d'expiration", value: ai.expiryDate ?? 'Non détectée', confidence: ai.expiryDate ? 0.9 : 0.4 },
    ];

    const hits = fields.filter((f) => f.confidence >= 0.9).length;
    const confidence = Math.min(0.98, 0.7 + hits * 0.03);

    return {
      title: ai.type || 'Document officiel',
      confidence,
      fields,
      snippet: this.buildSnippet(text),
      extractionMethod: 'ai',
    };
  }

  private extractWithRegex(fileName: string, text: string) {
    const mrz = this.extractMrz(text);
    const labeled = this.extractLabeledFields(text);
    const surname = labeled['Nom'];
    const given = labeled['Prénoms'];
    const name = mrz?.name ?? this.sanitizeName(this.combineName(surname, given)) ?? this.extractName(text);
    const date = mrz?.birthDate ?? labeled['Date de naissance'] ?? this.extractDate(text);
    const location = labeled['Lieu de naissance'] ?? this.extractLocation(text);
    const nationality = labeled['Nationalité'];
    const sex = labeled['Sexe'];
    const idNumber = mrz?.documentNumber ?? labeled['Numéro document'] ?? this.extractIdNumber(text);
    const type = this.inferDocType(text, mrz !== null);

    const fields = [
      { label: 'Fichier', value: fileName, confidence: 1 },
      { label: 'Type', value: type, confidence: 0.9 },
      { label: 'Nom', value: name ?? 'Non détecté', confidence: name ? 0.9 : 0.4 },
      { label: 'Date de naissance', value: date ?? 'Non détectée', confidence: date ? 0.88 : 0.4 },
      { label: 'Lieu de naissance', value: location ?? 'Non détecté', confidence: location ? 0.82 : 0.4 },
      { label: 'Nationalité', value: nationality ?? 'Non détectée', confidence: nationality ? 0.82 : 0.4 },
      { label: 'Sexe', value: sex ?? 'Non détecté', confidence: sex ? 0.78 : 0.4 },
      { label: 'Numéro document', value: idNumber ?? 'Non détecté', confidence: idNumber ? 0.86 : 0.4 },
    ];

    const hits = fields.filter((field) => field.confidence >= 0.75).length;
    const confidence = Math.min(0.92, Math.max(0.55, 0.6 + hits * 0.06));

    return {
      title: type,
      confidence,
      fields,
      snippet: this.buildSnippet(text),
      extractionMethod: 'regex',
    };
  }

  private inferDocType(text: string, hasMrz: boolean) {
    const lower = text.toLowerCase();
    if (hasMrz) return 'Passeport';
    if (lower.includes('acte de naissance') || lower.includes('naissance')) return 'Acte de naissance';
    if (lower.includes('acte de mariage') || lower.includes('mariage')) return 'Acte de mariage';
    if (lower.includes('acte de décès') || lower.includes('décès') || lower.includes('deces')) return 'Acte de décès';
    if (lower.includes('livret de famille') || lower.includes('livret')) return 'Livret de famille';
    if (lower.includes("carte d'identité") || lower.includes('carte nationale') || lower.includes('identité') || lower.includes('identite')) return "Pièce d'identité";
    if (lower.includes('passeport') || lower.includes('passport')) return 'Passeport';
    return 'Document officiel';
  }

  private extractName(text: string) {
    const surnameMatch = /(?:Nom\s*\/?\s*Sur?name|Nom\s*(?:de\s*famille)?|Surname)\s*[:\-]?\s*([A-Za-zÀ-ÿ\-\s]{2,})/i.exec(text);
    const givenMatch = /(?:Pr[eé]noms?\s*\/?\s*Given names?|Given names?|Pr[eé]noms?)\s*[:\-]?\s*([A-Za-zÀ-ÿ\-\s]{2,})/i.exec(text);
    if (surnameMatch || givenMatch) {
      const surname = surnameMatch?.[1]?.trim();
      const given = givenMatch?.[1]?.trim();
      if (surname && given) return this.sanitizeName(`${surname} ${given}`);
      return this.sanitizeName(surname ?? given ?? undefined);
    }
    const fallback = /(?:Nom\s+et\s+pr[eé]nom)s?\s*[:\-]?\s*([A-Za-zÀ-ÿ\-\s]{2,})/i.exec(text);
    if (fallback) return this.sanitizeName(fallback[1]);
    const upperMatch = /\b([A-ZÀ-Ÿ]{2,}(?:\s+[A-ZÀ-Ÿ]{2,}){1,3})\b/.exec(text);
    return this.sanitizeName(upperMatch?.[1]);
  }

  private combineName(surname?: string, given?: string) {
    if (!surname && !given) return undefined;
    return [surname, given].filter(Boolean).join(' ').replace(/\s+/g, ' ').trim();
  }

  private extractLabeledFields(text: string) {
    const result: Record<string, string> = {};
    const lines = text.split(/\r?\n/).map((line) => line.trim()).filter(Boolean);
    for (const line of lines) {
      const match = /^([A-Za-zÀ-ÿ/ ]{3,})\s*[:\-]\s*(.+)$/.exec(line) || /^([A-Za-zÀ-ÿ/ ]{3,})\s{2,}(.+)$/.exec(line);
      if (!match) continue;
      const rawLabel = match[1].trim();
      const value = match[2].trim();
      const key = this.normalizeLabel(rawLabel);
      if (key && value && !result[key]) {
        result[key] = value;
      }
    }
    return result;
  }

  private normalizeLabel(label: string) {
    const cleaned = this.normalizeText(label);
    if (cleaned.includes('nom') || cleaned.includes('surname')) return 'Nom';
    if (cleaned.includes('prenom') || cleaned.includes('given name')) return 'Prénoms';
    if (cleaned.includes('date de naissance') || cleaned.includes('date of birth') || cleaned === 'birth') return 'Date de naissance';
    if (cleaned.includes('lieu de naissance') || cleaned.includes('place of birth') || cleaned.includes('birth place')) return 'Lieu de naissance';
    if (cleaned.includes('nationalite') || cleaned.includes('nationality')) return 'Nationalité';
    if (cleaned.includes('sexe') || cleaned.includes('sex')) return 'Sexe';
    if (cleaned.includes('numero') || cleaned.includes('no') || cleaned.includes('id') || cleaned.includes('passport') || cleaned.includes('document')) {
      return 'Numéro document';
    }
    return undefined;
  }

  private normalizeText(input: string) {
    const lower = input.toLowerCase();
    const map: Record<string, string> = {
      à: 'a',
      â: 'a',
      ä: 'a',
      á: 'a',
      ã: 'a',
      å: 'a',
      ç: 'c',
      é: 'e',
      è: 'e',
      ê: 'e',
      ë: 'e',
      í: 'i',
      ì: 'i',
      î: 'i',
      ï: 'i',
      ñ: 'n',
      ó: 'o',
      ò: 'o',
      ô: 'o',
      ö: 'o',
      ú: 'u',
      ù: 'u',
      û: 'u',
      ü: 'u',
      ÿ: 'y',
      œ: 'oe',
      æ: 'ae',
    };
    return lower
      .split('')
      .map((char) => map[char] ?? char)
      .join('');
  }

  private sanitizeName(value?: string) {
    if (!value) return undefined;
    const cleaned = value.replace(/\s+/g, ' ').trim();
    if (cleaned.length < 3) return undefined;
    const blocked = [
      'REPUBLIQUE',
      'REPUBLIC',
      'NATIONALE',
      'NATIONAL',
      'PASSEPORT',
      'PASSPORT',
      'CARTE',
      'IDENTITE',
      'IDENTITÉ',
      'SURETE',
      'SÛRETÉ',
      'DELEGUE',
      'DELEGUEE',
      'DELEGATE',
    ];
    const upper = cleaned.toUpperCase();
    if (blocked.some((word) => upper.includes(word))) return undefined;
    return cleaned;
  }

  private extractDate(text: string) {
    const labeled = /(?:Date\s*de\s*naissance|Date\s*of\s*birth|Naissance|Birth|DOB)\s*[:\-]?\s*(\d{1,2}[\/.\-]\d{1,2}[\/.\-]\d{2,4})/i.exec(text);
    if (labeled) return labeled[1];
    const match = /\b\d{1,2}[\/.\-]\d{1,2}[\/.\-]\d{2,4}\b/.exec(text);
    if (match) return match[0];
    const year = /\b(19\d{2}|20\d{2})\b/.exec(text);
    return year?.[0];
  }

  private extractLocation(text: string) {
    const patterns = [
      /(?:Lieu\s*(?:de\s*naissance)?|Lieu\s*de\s*d[eé]livrance|Place\s*of\s*birth|Birth\s*place|N[eé]e?\s*[àa])\s*[:\-]?\s*([A-Za-zÀ-ÿ\-\s]{3,})/i,
      /\bà\s+([A-Za-zÀ-ÿ\-\s]{3,})/i,
    ];
    for (const pattern of patterns) {
      const match = pattern.exec(text);
      if (match) return match[1].trim();
    }
    return undefined;
  }

  private extractIdNumber(text: string) {
    const match = /(?:N°|No|Num[eé]ro|Numero|ID|Passport\s*No|Document\s*No)\s*[:\-]?\s*([A-Z0-9\-]{5,})/i.exec(text);
    return match?.[1]?.trim();
  }

  private extractMrz(text: string) {
    const normalized = text
      .toUpperCase()
      .replace(/[^A-Z0-9<\n]/g, '')
      .replace(/\n+/g, '\n');
    const lines = normalized.split('\n').filter((line) => line.includes('P<'));
    if (!lines.length) return null;
    const line1 = lines[0];
    const line2 = lines.length > 1 ? lines[1] : '';
    const nameSection = line1.length > 5 ? line1.substring(5) : '';
    const nameParts = nameSection.split('<<');
    const surname = nameParts[0]?.replace(/</g, ' ').trim();
    const given = nameParts[1]?.replace(/</g, ' ').trim();
    const name = [surname, given].filter(Boolean).join(' ').replace(/\s+/g, ' ').trim();

    let birthDate: string | undefined;
    let documentNumber: string | undefined;
    if (line2.length >= 28) {
      documentNumber = line2.substring(0, 9).replace(/</g, '').trim();
      const rawBirth = line2.substring(13, 19);
      birthDate = this.formatMrzDate(rawBirth);
    }

    if (!name && !birthDate && !documentNumber) return null;
    return { name: name || undefined, birthDate, documentNumber };
  }

  private formatMrzDate(raw: string) {
    if (!/^\d{6}$/.test(raw)) return undefined;
    const yy = Number(raw.slice(0, 2));
    const mm = raw.slice(2, 4);
    const dd = raw.slice(4, 6);
    const currentYear = new Date().getFullYear() % 100;
    const century = yy <= currentYear ? 2000 : 1900;
    return `${dd}.${mm}.${century + yy}`;
  }

  private buildSnippet(text: string) {
    const cleaned = text.replace(/\s+/g, ' ').trim();
    if (cleaned.length <= 320) return cleaned;
    return `${cleaned.substring(0, 320)}…`;
  }
}
