import { Router } from 'express';
import { requireAuth } from '../middleware/auth';

const router = Router();

interface AuditEntry {
  id: string;
  action: string;
  description: string;
  userId?: string;
  timestamp: Date;
}

const auditLog: AuditEntry[] = [];

export function logAudit(action: string, description: string, userId?: string) {
  auditLog.unshift({
    id: `al_${Date.now()}_${Math.random().toString(36).slice(2, 6)}`,
    action,
    description,
    userId,
    timestamp: new Date(),
  });
  if (auditLog.length > 500) auditLog.length = 500;
}

router.get('/', requireAuth, (req: any, res) => {
  const { page = '1', limit = '50' } = req.query;
  const start = (Number(page) - 1) * Number(limit);
  const sliced = auditLog.slice(start, start + Number(limit));
  res.json({ entries: sliced, total: auditLog.length });
});

router.get('/action/:action', requireAuth, (req: any, res) => {
  const filtered = auditLog.filter((e) => e.action === req.params.action);
  res.json({ entries: filtered, total: filtered.length });
});

export default router;
