import { CanActivate, ExecutionContext, Injectable, UnauthorizedException } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';

@Injectable()
export class SupabaseAuthGuard implements CanActivate {
  constructor(private readonly supabase: SupabaseService) {}

  async canActivate(context: ExecutionContext) {
    const request = context.switchToHttp().getRequest();
    const devKey = process.env.DEV_KEY ?? 'dev';
    const devHeader = request.headers['x-dev-key'] as string | undefined;
    if (devKey && devHeader && devHeader == devKey) {
      request.user = { id: 'dev' };
      return true;
    }
    const auth = request.headers['authorization'] as string | undefined;
    if (!auth || !auth.startsWith('Bearer ')) {
      throw new UnauthorizedException('Missing bearer token');
    }
    const token = auth.replace('Bearer ', '').trim();
    const { data, error } = await this.supabase.getClient().auth.getUser(token);
    if (error || !data.user) {
      throw new UnauthorizedException('Invalid token');
    }
    request.user = data.user;
    return true;
  }
}
