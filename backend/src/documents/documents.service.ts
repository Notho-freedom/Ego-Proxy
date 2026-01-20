import { Injectable } from '@nestjs/common';
import type { Express } from 'express';
import { SupabaseService } from '../supabase/supabase.service';

@Injectable()
export class DocumentsService {
  constructor(private readonly supabase: SupabaseService) {}

  async createSignedUpload(fileName: string, contentType?: string) {
    const bucket = process.env.SUPABASE_STORAGE_BUCKET ?? 'documents';
    const path = `${Date.now()}-${fileName}`;
    const { data, error } = await this.supabase
      .getClient()
      .storage.from(bucket)
      .createSignedUploadUrl(path, { upsert: false });

    if (error) {
      throw error;
    }

    return {
      path,
      uploadUrl: data.signedUrl,
      token: data.token,
      contentType: contentType ?? 'application/octet-stream',
    };
  }

  async commitDocument(payload: {
    path: string;
    title: string;
    extracted?: Record<string, string>;
  }) {
    const { data, error } = await this.supabase
      .getClient()
      .from('documents')
      .insert({
        path: payload.path,
        title: payload.title,
        extracted: payload.extracted ?? {},
        status: 'pending',
      })
      .select('id, path, title, status')
      .single();

    if (error) {
      throw error;
    }

    return data;
  }

  async uploadAndCommit(
    file: Express.Multer.File,
    title: string,
    extracted?: Record<string, string>,
  ) {
    const bucket = process.env.SUPABASE_STORAGE_BUCKET ?? 'documents';
    const path = `${Date.now()}-${file.originalname}`;
    const { error: uploadError } = await this.supabase
      .getClient()
      .storage.from(bucket)
      .upload(path, file.buffer, {
        contentType: file.mimetype,
        upsert: false,
      });

    if (uploadError) {
      throw uploadError;
    }

    return this.commitDocument({ path, title, extracted });
  }
}
