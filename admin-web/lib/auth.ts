"use client";

const TOKEN_KEY = "ai-classroom-admin-token";
const EXPIRES_AT_KEY = "ai-classroom-admin-expires-at";
const ONE_DAY_MS = 24 * 60 * 60 * 1000;

export function getAdminToken() {
  if (typeof window === "undefined") {
    return "";
  }

  const token = window.localStorage.getItem(TOKEN_KEY) ?? "";
  const expiresAt = Number(window.localStorage.getItem(EXPIRES_AT_KEY) ?? "0");
  if (!token || Date.now() >= expiresAt) {
    clearAdminSession();
    return "";
  }

  return token;
}

export function saveAdminSession(token: string) {
  window.localStorage.setItem(TOKEN_KEY, token);
  window.localStorage.setItem(EXPIRES_AT_KEY, String(Date.now() + ONE_DAY_MS));
}

export function clearAdminSession() {
  if (typeof window === "undefined") {
    return;
  }

  window.localStorage.removeItem(TOKEN_KEY);
  window.localStorage.removeItem(EXPIRES_AT_KEY);
}

export function hasValidAdminSession() {
  return getAdminToken().length > 0;
}
