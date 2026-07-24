import { neon } from '@neondatabase/serverless';

export async function checkDatabaseConnection() {
  try {
    const dbUrl = process.env.POSTGRES_URL || process.env.DATABASE_URL;
    if (!dbUrl) {
      console.log('Database URL not configured (Hobby/Free Tier mode)');
      return false;
    }
    const sql = neon(dbUrl);
    const result = await sql`SELECT NOW()`;
    console.log('Database connected successfully:', result[0]);
    return true;
  } catch (error) {
    console.error('Database connection failed:', error);
    return false;
  }
}

export function getSqlClient() {
  const dbUrl = process.env.POSTGRES_URL || process.env.DATABASE_URL;
  if (!dbUrl) return null;
  return neon(dbUrl);
}
