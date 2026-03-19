import { generateRandomString } from './random.js';

const BASE62_CHARS =
  'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';

export function generateShortCode(length: number = 6): string {
  let result = '';
  for (let i = 0; i < length; i++) {
    const randomIndex = Math.floor(Math.random() * BASE62_CHARS.length);
    result += BASE62_CHARS[randomIndex];
  }
  return result;
}

export async function generateUniqueShortCode(
  length: number,
  checkExists: (code: string) => Promise<boolean>,
  maxRetries: number = 10,
): Promise<string> {
  for (let i = 0; i < maxRetries; i++) {
    const code = generateShortCode(length);
    const exists = await checkExists(code);
    if (!exists) return code;
  }
  throw new Error(
    `Failed to generate unique short code after ${maxRetries} attempts`,
  );
}
