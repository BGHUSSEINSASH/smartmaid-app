import { Router } from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { z } from 'zod';
import {
  users,
  createUser,
  updateUserPassword,
  passwordResetCodes,
  type AppRole,
} from '../store';
import { rateLimitLogin } from '../middleware/auth';

const router = Router();

function issueToken(user: { id: string; role: string }): string {
  const secret = process.env.JWT_SECRET;
  return secret
    ? jwt.sign({ sub: user.id, role: user.role }, secret, { expiresIn: '7d' })
    : `demo-token-${user.id}`;
}

const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(6),
});

router.post('/login', rateLimitLogin, async (req, res) => {
  const parsed = loginSchema.safeParse(req.body);

  if (!parsed.success) {
    res
      .status(400)
      .json({ message: 'Invalid payload', errors: parsed.error.flatten() });
    return;
  }

  const user = users.find(
    (candidate) =>
      candidate.email.toLowerCase() === parsed.data.email.toLowerCase(),
  );

  if (!user || !user.passwordHash) {
    res.status(401).json({ message: 'Invalid credentials' });
    return;
  }

  const ok = await bcrypt.compare(parsed.data.password, user.passwordHash);
  if (!ok) {
    res.status(401).json({ message: 'Invalid credentials' });
    return;
  }

  const secret = process.env.JWT_SECRET;
  const token = secret
    ? jwt.sign({ sub: user.id, role: user.role }, secret, {
        expiresIn: '7d',
      })
    : `demo-token-${user.id}`;

  res.json({
    token,
    user: {
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
    },
  });
});

const registerSchema = z.object({
  name: z.string().min(2),
  email: z.string().email(),
  password: z.string().min(8),
  role: z.enum(['customer', 'worker', 'company']).optional(),
});

router.post('/register', async (req, res) => {
  const parsed = registerSchema.safeParse(req.body);
  if (!parsed.success) {
    res
      .status(400)
      .json({ message: 'Invalid payload', errors: parsed.error.flatten() });
    return;
  }

  const exists = users.find(
    (u) => u.email.toLowerCase() === parsed.data.email.toLowerCase(),
  );
  if (exists) {
    res.status(409).json({ message: 'Email already registered' });
    return;
  }

  const user = await createUser({
    name: parsed.data.name,
    email: parsed.data.email,
    password: parsed.data.password,
    role: (parsed.data.role ?? 'customer') as AppRole,
  });

  res.status(201).json({
    token: issueToken(user),
    user: {
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
    },
  });
});

const forgotSchema = z.object({ email: z.string().email() });

router.post('/forgot-password', (req, res) => {
  const parsed = forgotSchema.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ message: 'Invalid payload' });
    return;
  }
  const user = users.find(
    (u) => u.email.toLowerCase() === parsed.data.email.toLowerCase(),
  );
  // لا نكشف إن كان البريد موجوداً (حماية من التعداد).
  if (user) {
    const code = String(Math.floor(1000 + Math.random() * 9000));
    passwordResetCodes.set(user.email.toLowerCase(), code);
    // في الإنتاج يُرسل عبر البريد. هنا نعيده في وضع التطوير فقط.
    const devCode = process.env.NODE_ENV === 'production' ? undefined : code;
    res.json({ message: 'Reset code sent', devCode });
    return;
  }
  res.json({ message: 'Reset code sent' });
});

const resetSchema = z.object({
  email: z.string().email(),
  code: z.string().min(4),
  newPassword: z.string().min(8),
});

router.post('/reset-password', async (req, res) => {
  const parsed = resetSchema.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ message: 'Invalid payload' });
    return;
  }
  const key = parsed.data.email.toLowerCase();
  const expected = passwordResetCodes.get(key);
  if (!expected || expected !== parsed.data.code) {
    res.status(400).json({ message: 'Invalid or expired code' });
    return;
  }
  const user = users.find((u) => u.email.toLowerCase() === key);
  if (!user) {
    res.status(404).json({ message: 'User not found' });
    return;
  }
  await updateUserPassword(user, parsed.data.newPassword);
  passwordResetCodes.delete(key);
  res.json({ message: 'Password updated' });
});

export default router;
