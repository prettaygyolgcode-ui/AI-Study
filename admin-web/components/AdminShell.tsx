"use client";

import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { type ReactNode, useEffect, useState } from "react";
import { hasValidAdminSession } from "../lib/auth";

const navItems = [
  { href: "/", label: "总览" },
  { href: "/accounts", label: "账号管理" },
  { href: "/coursewares", label: "课件管理" },
  { href: "/teacher-workspace", label: "老师工作台" },
  { href: "/works", label: "作品审核" },
  { href: "/ai-assets", label: "AI 卡片库" },
  { href: "/parent-settings", label: "家长设置" },
  { href: "/logs", label: "数据日志" }
];

export function AdminShell({ children }: { children: ReactNode }) {
  const pathname = usePathname();
  const router = useRouter();
  const [isReady, setIsReady] = useState(false);
  const isLoginPage = pathname === "/login";

  useEffect(() => {
    if (isLoginPage) {
      setIsReady(true);
      return;
    }

    if (!hasValidAdminSession()) {
      router.replace("/login");
      return;
    }

    setIsReady(true);
  }, [isLoginPage, router]);

  if (isLoginPage) {
    return <main className="login-main">{children}</main>;
  }

  if (!isReady) {
    return <main className="login-main">正在检查登录状态...</main>;
  }

  return (
    <div className="shell">
      <aside className="sidebar">
        <div className="brand">AI课堂后台</div>
        <nav className="nav">
          {navItems.map((item) => {
            const isActive = item.href === "/" ? pathname === "/" : pathname.startsWith(item.href);

            return (
              <Link
                aria-current={isActive ? "page" : undefined}
                className={isActive ? "active" : undefined}
                href={item.href}
                key={item.href}
              >
                {item.label}
              </Link>
            );
          })}
        </nav>
      </aside>
      <main className="main">{children}</main>
    </div>
  );
}
