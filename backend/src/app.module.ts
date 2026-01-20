import { Module } from '@nestjs/common';
import { HealthController } from './health/health.controller';
import { SupabaseModule } from './supabase/supabase.module';
import { DocumentsController } from './documents/documents.controller';
import { DocumentsService } from './documents/documents.service';
import { OcrController } from './ocr/ocr.controller';
import { OcrService } from './ocr/ocr.service';
import { AiModule } from './ai/ai.module';
import { AiService } from './ai/ai.service';

@Module({
  imports: [SupabaseModule, AiModule],
  controllers: [HealthController, DocumentsController, OcrController],
  providers: [DocumentsService, OcrService, AiService],
})
export class AppModule {}
