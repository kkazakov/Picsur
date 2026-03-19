import { z } from 'zod';
import { ShortCodeRegex } from '../util/common-regex.js';

export const EImageSchema = z.object({
  id: z.string().regex(ShortCodeRegex),
  user_id: z.string().uuid(),
  created: z.preprocess((data: any) => new Date(data), z.date()),
  file_name: z.string(),
  expires_at: z.preprocess((data: any) => new Date(data), z.date()).nullable(),
});
export type EImage = z.infer<typeof EImageSchema>;
