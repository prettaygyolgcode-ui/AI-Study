import { getAdminToken, saveAdminSession } from "./auth";

const API_BASE_URL = process.env.NEXT_PUBLIC_API_BASE_URL ?? "http://localhost:8080";

export type ApiResponse<T> = {
  code: string;
  message: string;
  data: T;
};

export type PageResponse<T> = {
  items: T[];
  page: number;
  pageSize: number;
  total: number;
};

export type Work = {
  id: string;
  type: string;
  title: string;
  authorName: string;
  status: string;
  published: boolean;
  recommended: boolean;
  likeCount: number;
  score: number;
};

export type AiFriend = {
  id: string;
  name: string;
  icon: string;
  description: string;
  rolePrompt: string;
  status: string;
};

export type CreationCard = {
  id: string;
  type: string;
  name: string;
  icon: string;
  promptTemplate: string;
  status: string;
};

export type UserAccount = {
  id: string;
  phone: string;
  displayName: string;
  role: string;
  status: string;
  createdAt: string;
  updatedAt: string;
};

export type Courseware = {
  id: string;
  title: string;
  ageBand: string;
  category: string;
  status: string;
  originalFileUrl: string | null;
  convertedAssetUrl: string | null;
  conversionStatus: string;
  durationMinutes: number;
  createdAt: string;
  updatedAt: string;
};

export type ClassroomSummary = {
  id: string;
  name: string;
  ageBand: string;
  status: string;
  studentCount: number;
};

export type CoursewarePlayRecord = {
  id: string;
  coursewareId: string;
  coursewareTitle: string;
  classroomId: string | null;
  classroomName: string;
  playedSeconds: number;
  progressPercent: number;
  startedAt: string;
};

export type TeacherWorkspace = {
  coursewares: Courseware[];
  classrooms: ClassroomSummary[];
  recentPlayRecords: CoursewarePlayRecord[];
};

export type ParentSettings = {
  id: string | null;
  parentPhone: string;
  computeBudgetLimit: number;
  dailyMinutesLimit: number;
  enabledAiFeatures: string;
  allowPublicPublishing: boolean;
  autoNarrationEnabled: boolean;
  voiceInputEnabled: boolean;
  updatedAt: string;
};

export type AuditLogItem = {
  id: string;
  action: string;
  targetType: string;
  targetId: string | null;
  metadata: string;
  createdAt: string;
};

function authHeader() {
  return getAdminToken();
}

async function getJson<T>(path: string): Promise<T> {
  const response = await fetch(`${API_BASE_URL}${path}`, {
    cache: "no-store",
    headers: {
      Authorization: `Bearer ${authHeader()}`
    }
  });

  if (!response.ok) {
    throw new Error(`Request failed: ${response.status}`);
  }

  const body = (await response.json()) as ApiResponse<T>;
  return body.data;
}

export async function getWorks() {
  return getJson<PageResponse<Work>>("/api/v1/admin/works");
}

export async function getAiFriends() {
  return getJson<PageResponse<AiFriend>>("/api/v1/admin/ai-friends");
}

export async function getCreationCards() {
  return getJson<PageResponse<CreationCard>>("/api/v1/admin/creation-cards");
}

export async function getAccounts(role: "BACKEND" | "TEACHER" | "PARENT") {
  return getJson<PageResponse<UserAccount>>(`/api/v1/admin/accounts?role=${role}`);
}

export async function getCoursewares(params: Record<string, string> = {}) {
  const query = new URLSearchParams(params);
  const suffix = query.toString() ? `?${query.toString()}` : "";
  return getJson<PageResponse<Courseware>>(`/api/v1/admin/coursewares${suffix}`);
}

export async function createCourseware(input: {
  title: string;
  ageBand: string;
  category: string;
  originalFileUrl?: string;
  durationMinutes?: number;
}) {
  return postJson<Courseware>("/api/v1/admin/coursewares", input);
}

export async function convertCourseware(id: string) {
  return postJson<Courseware>(`/api/v1/admin/coursewares/${id}/convert`);
}

export async function publishCourseware(id: string) {
  return postJson<Courseware>(`/api/v1/admin/coursewares/${id}/publish`);
}

export async function offlineCourseware(id: string) {
  return postJson<Courseware>(`/api/v1/admin/coursewares/${id}/offline`);
}

export async function getTeacherWorkspace() {
  return getJson<TeacherWorkspace>("/api/v1/teacher/workspace");
}

export async function getClassrooms() {
  return getJson<PageResponse<ClassroomSummary>>("/api/v1/admin/classrooms");
}

export async function createClassroom(input: { name: string; ageBand: string; organizationId?: string; teacherId?: string }) {
  return postJson<ClassroomSummary>("/api/v1/admin/classrooms", input);
}

export async function bindStudent(classroomId: string, input: { parentPhone: string; nickname: string; ageBand?: string }) {
  return postJson<{ studentId: string; classroomId: string; parentPhone: string; nickname: string; bindStatus: string }>(
    `/api/v1/admin/classrooms/${classroomId}/students`,
    input
  );
}

export async function createPlayRecord(input: {
  coursewareId: string;
  classroomId?: string;
  playedSeconds?: number;
  progressPercent?: number;
}) {
  return postJson<CoursewarePlayRecord>("/api/v1/admin/courseware-play-records", input);
}

export async function getParentSettings(parentPhone: string) {
  return getJson<ParentSettings>(`/api/v1/admin/parent-settings?parentPhone=${encodeURIComponent(parentPhone)}`);
}

export async function updateParentSettings(input: {
  parentPhone: string;
  computeBudgetLimit: number;
  dailyMinutesLimit: number;
  enabledAiFeatures: string;
  allowPublicPublishing: boolean;
  autoNarrationEnabled: boolean;
  voiceInputEnabled: boolean;
}) {
  return putJson<ParentSettings>("/api/v1/admin/parent-settings", input);
}

export async function getAuditLogs(params: Record<string, string> = {}) {
  const query = new URLSearchParams(params);
  const suffix = query.toString() ? `?${query.toString()}` : "";
  return getJson<PageResponse<AuditLogItem>>(`/api/v1/admin/logs${suffix}`);
}

export async function login(phone: string, code: string) {
  const response = await fetch(`${API_BASE_URL}/api/v1/auth/admin/sms/login`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json"
    },
    body: JSON.stringify({ phone, code })
  });

  if (!response.ok) {
    throw new Error("登录失败");
  }

  const body = (await response.json()) as ApiResponse<{ token: string; role: string; displayName: string }>;
  saveAdminSession(body.data.token);
  return body.data;
}

export async function approveWork(id: string) {
  return postJson<Work>(`/api/v1/admin/works/${id}/approve`);
}

export async function rejectWork(id: string) {
  return postJson<Work>(`/api/v1/admin/works/${id}/reject`);
}

async function postJson<T>(path: string, payload?: unknown): Promise<T> {
  const response = await fetch(`${API_BASE_URL}${path}`, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${authHeader()}`,
      "Content-Type": "application/json"
    },
    body: payload === undefined ? undefined : JSON.stringify(payload)
  });

  if (!response.ok) {
    throw new Error(`Request failed: ${response.status}`);
  }

  const responseBody = (await response.json()) as ApiResponse<T>;
  return responseBody.data;
}

async function putJson<T>(path: string, body: unknown): Promise<T> {
  const response = await fetch(`${API_BASE_URL}${path}`, {
    method: "PUT",
    headers: {
      Authorization: `Bearer ${authHeader()}`,
      "Content-Type": "application/json"
    },
    body: JSON.stringify(body)
  });

  if (!response.ok) {
    throw new Error(`Request failed: ${response.status}`);
  }

  const responseBody = (await response.json()) as ApiResponse<T>;
  return responseBody.data;
}
