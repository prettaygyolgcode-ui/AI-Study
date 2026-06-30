import "./globals.css";
import type { ReactNode } from "react";
import { AdminShell } from "../components/AdminShell";

export const metadata = {
  title: "AI课堂后台",
  description: "AI 学习与创作平台后台管理系统"
};

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="zh-CN">
      <body>
        <AdminShell>{children}</AdminShell>
      </body>
    </html>
  );
}
