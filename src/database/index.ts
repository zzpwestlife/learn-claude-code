import { Pool, PoolConfig } from 'pg';
import config from '../config';

// Create database connection pool
const pool = new Pool({
  host: config.DB_HOST,
  port: config.DB_PORT,
  database: config.DB_NAME,
  user: config.DB_USER,
  password: config.DB_PASSWORD,
  max: 20, // 连接池最大连接数
  idleTimeoutMillis: 30000, // 连接空闲超时时间
  connectionTimeoutMillis: 2000, // 连接超时时间
});

// Test database connection
const testConnection = async (): Promise<void> => {
  try {
    const client = await pool.connect();
    console.log('✓ Database connection successful');
    client.release();
  } catch (error) {
    console.error('❌ Database connection failed:', error);
    process.exit(1);
  }
};

// 执行SQL查询
const query = async (text: string, params?: any[]): Promise<any> => {
  const start = Date.now();
  const result = await pool.query(text, params);
  const duration = Date.now() - start;

  console.log('📊 Database query executed:', {
    text: text.slice(0, 50) + (text.length > 50 ? '...' : ''),
    duration: `${duration}ms`,
    rows: result.rowCount
  });

  return result;
};

// 执行事务
const transaction = async (callback: (client: any) => Promise<any>): Promise<any> => {
  const client = await pool.connect();

  try {
    await client.query('BEGIN');
    const result = await callback(client);
    await client.query('COMMIT');
    return result;
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
};

// 关闭连接池
const closePool = async (): Promise<void> => {
  await pool.end();
  console.log('🔌 Database connection pool closed');
};

export { pool, testConnection, query, transaction, closePool };
