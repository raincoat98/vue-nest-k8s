import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ConfigService } from '@nestjs/config';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  const configService = app.get(ConfigService);

  const corsOrigins: string[] = (
    configService.get<string>('CORS_ORIGIN') || ''
  ).split(',');

  app.enableCors({
    origin: corsOrigins,
    credentials: true,
  });

  // 전역 API prefix 설정
  app.setGlobalPrefix('api');

  await app.listen(process.env.PORT ?? 3000);
}
bootstrap();
