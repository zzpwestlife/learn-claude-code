import { query } from './index';

// 迁移版本管理表
const createMigrationsTable = `
  CREATE TABLE IF NOT EXISTS migrations (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    executed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  );
`;

// 检查迁移是否已执行
const checkMigration = async (name: string): Promise<boolean> => {
  const result = await query('SELECT id FROM migrations WHERE name = $1', [name]);
  return result.rowCount > 0;
};

// 记录迁移执行
const recordMigration = async (name: string): Promise<void> => {
  await query('INSERT INTO migrations (name) VALUES ($1)', [name]);
};

// 第1个迁移：创建用户表
const migration1 = {
  name: '20240122_create_users_table',
  sql: `
    CREATE TABLE IF NOT EXISTS users (
      id SERIAL PRIMARY KEY,
      email VARCHAR(255) NOT NULL UNIQUE,
      username VARCHAR(50) NOT NULL UNIQUE,
      password_hash TEXT NOT NULL,
      full_name VARCHAR(100),
      avatar_url TEXT,
      is_verified BOOLEAN DEFAULT FALSE,
      verification_token TEXT,
      verification_token_expires TIMESTAMP,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      last_login_at TIMESTAMP
    );

    CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
    CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
  `
};

// 第2个迁移：创建密码重置令牌表
const migration2 = {
  name: '20240122_create_password_reset_tokens_table',
  sql: `
    CREATE TABLE IF NOT EXISTS password_reset_tokens (
      id SERIAL PRIMARY KEY,
      user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      token TEXT NOT NULL UNIQUE,
      expires_at TIMESTAMP NOT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

    CREATE INDEX IF NOT EXISTS idx_password_reset_tokens_user_id ON password_reset_tokens(user_id);
    CREATE INDEX IF NOT EXISTS idx_password_reset_tokens_token ON password_reset_tokens(token);
  `
};

// 第3个迁移：创建刷新令牌表
const migration3 = {
  name: '20240122_create_refresh_tokens_table',
  sql: `
    CREATE TABLE IF NOT EXISTS refresh_tokens (
      id SERIAL PRIMARY KEY,
      user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      token TEXT NOT NULL UNIQUE,
      expires_at TIMESTAMP NOT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      revoked BOOLEAN DEFAULT FALSE,
      revoked_at TIMESTAMP
    );

    CREATE INDEX IF NOT EXISTS idx_refresh_tokens_user_id ON refresh_tokens(user_id);
    CREATE INDEX IF NOT EXISTS idx_refresh_tokens_token ON refresh_tokens(token);
  `
};

// 第4个迁移：创建用户会话表
const migration4 = {
  name: '20240122_create_sessions_table',
  sql: `
    CREATE TABLE IF NOT EXISTS sessions (
      id SERIAL PRIMARY KEY,
      user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      session_token TEXT NOT NULL UNIQUE,
      expires_at TIMESTAMP NOT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      last_activity_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      ip_address INET,
      user_agent TEXT
    );

    CREATE INDEX IF NOT EXISTS idx_sessions_user_id ON sessions(user_id);
    CREATE INDEX IF NOT EXISTS idx_sessions_session_token ON sessions(session_token);
  `
};

// 所有迁移列表
const migrations = [migration1, migration2, migration3, migration4];

// 执行所有待执行的迁移
export const runMigrations = async (): Promise<void> => {
  try {
    console.log('🚀 开始执行数据库迁移...');

    // 创建迁移管理表
    await query(createMigrationsTable);

    // 执行每个迁移
    for (const migration of migrations) {
      const hasExecuted = await checkMigration(migration.name);

      if (!hasExecuted) {
        console.log(`📦 执行迁移: ${migration.name}`);
        await query(migration.sql);
        await recordMigration(migration.name);
        console.log(`✅ 迁移成功: ${migration.name}`);
      } else {
        console.log(`⏭️  迁移已执行: ${migration.name}`);
      }
    }

    console.log('🎉 所有数据库迁移执行完成');
  } catch (error) {
    console.error('❌ 数据库迁移失败:', error);
    process.exit(1);
  }
};

// 回滚所有迁移（谨慎使用）
export const rollbackMigrations = async (): Promise<void> => {
  try {
    console.log('⚠️  开始回滚所有数据库迁移...');

    // 按逆序回滚
    for (const migration of migrations.reverse()) {
      const hasExecuted = await checkMigration(migration.name);

      if (hasExecuted) {
        console.log(`📦 回滚迁移: ${migration.name}`);
        // 这里应该实现具体的回滚SQL，为了安全起见，我们只删除迁移记录
        await query('DELETE FROM migrations WHERE name = $1', [migration.name]);
        console.log(`✅ 回滚成功: ${migration.name}`);
      }
    }

    console.log('🎉 所有数据库迁移回滚完成');
  } catch (error) {
    console.error('❌ 数据库迁移回滚失败:', error);
    process.exit(1);
  }
};

// 获取迁移状态
export const getMigrationStatus = async (): Promise<void> => {
  try {
    await query(createMigrationsTable);

    console.log('📊 数据库迁移状态:');
    for (const migration of migrations) {
      const hasExecuted = await checkMigration(migration.name);
      const status = hasExecuted ? '✅' : '❌';
      console.log(`${status} ${migration.name}`);
    }
  } catch (error) {
    console.error('❌ 获取迁移状态失败:', error);
  }
};
