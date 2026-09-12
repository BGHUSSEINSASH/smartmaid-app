import bcrypt from 'bcryptjs';

export type AppRole = 'customer' | 'worker' | 'admin' | 'company';

export interface User {
  id: string;
  name: string;
  email: string;
  password: string;
  passwordHash?: string;
  role: AppRole;
}

export interface Worker {
  id: string;
  name: string;
  image: string;
  rating: number;
  experienceYears: number;
  hourlyRate: number;
}

export interface Booking {
  id: string;
  userId: string;
  workerId: string;
  contractType: 'hourly' | 'daily' | 'monthly';
  hours: number;
  notes?: string;
  total: number;
  status: 'pending' | 'accepted' | 'rejected' | 'completed';
  paymentStatus: 'pending' | 'processing' | 'succeeded' | 'failed';
  paymentIntentId?: string;
  createdAt: string;
}

async function hashSeedPasswords(): Promise<void> {
  for (const u of users) {
    if (!u.passwordHash) {
      u.passwordHash = await bcrypt.hash(u.password, 10);
    }
  }
}

export const users: User[] = [
  {
    id: 'u_customer_1',
    name: 'Demo User',
    email: 'user@example.com',
    password: 'Passw0rd!',
    role: 'customer',
  },
  {
    id: 'u_worker_1',
    name: 'Demo Worker',
    email: 'worker@example.com',
    password: 'Passw0rd!',
    role: 'worker',
  },
  {
    id: 'u_admin_1',
    name: 'Demo Admin',
    email: 'admin@example.com',
    password: 'Passw0rd!',
    role: 'admin',
  },
  {
    id: 'u_company_1',
    name: 'Ideal Cleaning Co.',
    email: 'company@example.com',
    password: 'Passw0rd!',
    role: 'company',
  },
];

export const workers: Worker[] = [
  {
    id: 'w1',
    name: 'Maria',
    image: 'https://i.pravatar.cc/160?img=47',
    rating: 4.9,
    experienceYears: 7,
    hourlyRate: 32,
  },
  {
    id: 'w2',
    name: 'Anna',
    image: 'https://i.pravatar.cc/160?img=32',
    rating: 4.8,
    experienceYears: 6,
    hourlyRate: 29,
  },
  {
    id: 'w3',
    name: 'Nour',
    image: 'https://i.pravatar.cc/160?img=15',
    rating: 4.7,
    experienceYears: 5,
    hourlyRate: 27,
  },
];

export const bookings: Booking[] = [];

export interface WalletTransaction {
  id: string;
  userId: string;
  title: string;
  amount: number;
  type: 'topup' | 'payment' | 'withdrawal' | 'earning' | 'refund';
  createdAt: string;
}

export const walletTransactions: WalletTransaction[] = [];

export interface LoyaltyRecord {
  points: number;
  history: { title: string; points: number; at: string }[];
}

export const loyaltyByUser = new Map<string, LoyaltyRecord>([
  ['u_customer_1', { points: 1250, history: [] }],
]);

export interface Coupon {
  code: string;
  title: string;
  discountPercent: number;
  minTotal: number;
}

export const coupons: Coupon[] = [
  { code: 'SMART50', title: 'خصم النصف', discountPercent: 50, minTotal: 50 },
  { code: 'SAVE15', title: 'وفّر 15%', discountPercent: 15, minTotal: 30 },
  { code: 'MONTHLY10', title: 'باقة الشهر', discountPercent: 10, minTotal: 200 },
];

export interface Review {
  id: string;
  workerId: string;
  userId: string;
  rating: number;
  comment: string;
  createdAt: string;
}

export const reviews: Review[] = [
  {
    id: 'r1',
    workerId: 'w1',
    userId: 'u_customer_1',
    rating: 5,
    comment: 'ممتازة جداً! المنزل نظيف بشكل رائع.',
    createdAt: new Date().toISOString(),
  },
];

export interface Address {
  id: string;
  userId: string;
  label: string;
  city: string;
  details: string;
  isDefault: boolean;
}

export const addresses: Address[] = [];

export interface AppNotification {
  id: string;
  userId?: string;
  title: string;
  body: string;
  icon: string;
  read: boolean;
  createdAt: string;
}

export const notifications: AppNotification[] = [];

export function makeToken(user: User): string {
  return `demo-token-${user.id}`;
}

/// رموز إعادة تعيين كلمة المرور المؤقتة (بريد -> رمز).
export const passwordResetCodes = new Map<string, string>();

/// ينشئ مستخدماً جديداً ويخزّن كلمة المرور مجزّأة.
export async function createUser(input: {
  name: string;
  email: string;
  password: string;
  role: AppRole;
}): Promise<User> {
  const user: User = {
    id: `u_${input.role}_${Date.now()}`,
    name: input.name,
    email: input.email,
    password: input.password,
    passwordHash: await bcrypt.hash(input.password, 10),
    role: input.role,
  };
  users.push(user);
  return user;
}

/// يحدّث كلمة مرور مستخدم موجود.
export async function updateUserPassword(
  user: User,
  newPassword: string,
): Promise<void> {
  user.password = newPassword;
  user.passwordHash = await bcrypt.hash(newPassword, 10);
}

export function parseUserFromToken(token?: string): User | undefined {
  if (!token || !token.startsWith('demo-token-')) {
    return undefined;
  }

  const userId = token.replace('demo-token-', '');
  return users.find((user) => user.id === userId);
}

void hashSeedPasswords();

