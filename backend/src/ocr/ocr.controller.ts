import { Body, Controller, Logger, Post, UseGuards } from '@nestjs/common';
import { SupabaseAuthGuard } from '../common/supabase-auth.guard';
import { OcrService } from './ocr.service';

@Controller('ocr')
@UseGuards(SupabaseAuthGuard)
export class OcrController {
  constructor(private readonly service: OcrService) {}
  private readonly logger = new Logger(OcrController.name);

  @Post('text')
  async extractFromText(
    @Body() body: { fileName: string; text: string },
  ) {
    this.logger.log(`ocr: ${body.fileName} · ${body.text.length} chars`);
    return this.service.extractFromText(body.fileName, body.text);
  }
}
