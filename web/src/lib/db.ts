import { sql } from '@vercel/postgres';

export async function checkDatabaseConnection() {
  try {
    const result = await sql`SELECT NOW()`;
    console.log('Database connected successfully:', result.rows[0]);
    return true;
  } catch (error) {
    console.error('Database connection failed:', error);
    return false;
  }
}

// Re-export the Vercel Postgres SQL client for ease of use
export { sql };
