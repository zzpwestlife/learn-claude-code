import dotenv from 'dotenv';
import { z } from 'zod';

// Load environment variables
dotenv.config();

// Environment variables schema validation
const configSchema = z.object({
  // Server configuration
  PORT: z.coerce.number().default(3000),
  NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),

  // Database configuration
  DB_HOST: z.string().default('localhost'),
  DB_PORT: z.coerce.number().default(5432),
  DB_NAME: z.string().default('user_auth_system'),
  DB_USER: z.string().default('postgres'),
  DB_PASSWORD: z.string().default('password'),

  // JWT configuration
  JWT_SECRET: z.string().min(32, 'JWT secret must be at least 32 characters'),
  JWT_ACCESS_EXPIRES_IN: z.coerce.number().default(3600),
  JWT_REFRESH_EXPIRES_IN: z.coerce.number().default(604800),

  // Password hashing configuration (Argon2)
  ARGON2_MEMORY: z.coerce.number().default(19456),
  ARGON2_TIME: z.coerce.number().default(2),
  ARGON2_PARALLELISM: z.coerce.number().default(1),

  // CORS configuration
  CORS_ORIGIN: z.string().default('http://localhost:3001'),

  // Rate limiting configuration
  RATE_LIMIT_WINDOW_MS: z.coerce.number().default(900000),
  RATE_LIMIT_MAX: z.coerce.number().default(100),

  // Email configuration
  EMAIL_SERVICE: z.string().optional(),
  EMAIL_USER: z.string().optional(),
  EMAIL_PASSWORD: z.string().optional(),
});

// Validate environment variables
const config = configSchema.parse(process.env);

export default config;
