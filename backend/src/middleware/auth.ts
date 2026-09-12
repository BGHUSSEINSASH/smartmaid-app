import jwt from 'jsonwebtoken';
import { NextFunction, Request, Response } from 'express';
import { AppRole, parseUserFromToken, users, User } from '../store';

export interface AuthedRequest extends Request {
  user?: User;
}

function resolveTokenUser(token?: string): User | undefined {
  if (!token) return undefined;

  const secret = process.env.JWT_SECRET;
  if (secret) {
    try {
      const payload = jwt.verify(token, secret) as { sub?: string };
      return users.find((u) => u.id === payload.sub);
    } catch {
      return undefined;
    }
  }

  return parseUserFromToken(token);
}

export function requireAuth(
  req: AuthedRequest,
  res: Response,
  next: NextFunction,
): void {
  const authorization = req.header('authorization') ?? '';
  const token = authorization.startsWith('Bearer ')
    ? authorization.slice(7)
    : undefined;
  const user = resolveTokenUser(token);

  if (!user) {
    res.status(401).json({ message: 'Unauthorized' });
    return;
  }

  req.user = user;
  next();
}

export function requireRole(...roles: AppRole[]) {
  return (req: AuthedRequest, res: Response, next: NextFunction): void => {
    if (!req.user) {
      res.status(401).json({ message: 'Unauthorized' });
      return;
    }
    if (roles.length > 0 && !roles.includes(req.user.role)) {
      res.status(403).json({ message: 'Forbidden' });
      return;
    }
    next();
  };
}

const loginAttempts = new Map<string, number[]>();
const WINDOW_MS = 15 * 60 * 1000;
const MAX_ATTEMPTS = 20;

export function rateLimitLogin(
  req: Request,
  res: Response,
  next: NextFunction,
): void {
  const key = req.ip ?? 'unknown';
  const now = Date.now();
  const attempts = (loginAttempts.get(key) ?? []).filter(
    (t) => now - t < WINDOW_MS,
  );
  if (attempts.length >= MAX_ATTEMPTS) {
    res.status(429).json({ message: 'Too many attempts, try later' });
    return;
  }
  attempts.push(now);
  loginAttempts.set(key, attempts);
  next();
}
