import { Body, Controller, Logger, Post, UploadedFile, UseGuards, UseInterceptors } from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { DocumentsService } from './documents.service';
import { SupabaseAuthGuard } from '../common/supabase-auth.guard';

@Controller('documents')
@UseGuards(SupabaseAuthGuard)
export class DocumentsController {
  constructor(private readonly service: DocumentsService) {}
  private readonly logger = new Logger(DocumentsController.name);

  @Post('upload-url')
  async createUploadUrl(
    @Body() body: { fileName: string; contentType?: string },
  ) {
    this.logger.log(`createUploadUrl: ${body.fileName}`);
    return this.service.createSignedUpload(body.fileName, body.contentType);
  }

  @Post('commit')
  async commitDocument(
    @Body()
    body: {
      path: string;
      title: string;
      extracted?: Record<string, string>;
    },
  ) {
    this.logger.log(`commitDocument: ${body.title}`);
    return this.service.commitDocument(body);
  }

  @Post('upload')
  @UseInterceptors(FileInterceptor('file'))
  async uploadAndCommit(
    @UploadedFile() file: Express.Multer.File,
    @Body() body: { title: string; extracted?: string },
  ) {
    this.logger.log(`upload: ${file?.originalname ?? 'no-file'} · ${body.title}`);
    const extracted = body.extracted ? JSON.parse(body.extracted) : undefined;
    return this.service.uploadAndCommit(file, body.title, extracted);
  }
}
