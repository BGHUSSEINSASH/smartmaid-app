import { Router } from 'express';
import { requireAuth, AuthedRequest } from '../middleware/auth';
import { notifications } from '../store';

const router = Router();

router.get('/', requireAuth, (req: AuthedRequest, res) => {
  const list = notifications
    .filter((n) => !n.userId || n.userId === req.user!.id)
    .sort((a, b) => b.createdAt.localeCompare(a.createdAt));
  res.json({ notifications: list, unread: list.filter((n) => !n.read).length });
});

router.post('/:id/read', requireAuth, (req: AuthedRequest, res) => {
  const n = notifications.find(
    (x) => x.id === req.params.id && (!x.userId || x.userId === req.user!.id),
  );
  if (!n) {
    res.status(404).json({ message: 'Not found' });
    return;
  }
  n.read = true;
  res.json(n);
});

router.post('/read-all', requireAuth, (req: AuthedRequest, res) => {
  for (const n of notifications) {
    if (!n.userId || n.userId === req.user!.id) n.read = true;
  }
  res.json({ message: 'All marked read' });
});

export default router;
