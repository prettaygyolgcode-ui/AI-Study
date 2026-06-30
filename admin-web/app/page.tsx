import { AdminDataPanel } from "../components/AdminDataPanel";

export default function DashboardPage() {
  return (
    <section>
      <h1>后台总览</h1>
      <p>当前覆盖 P0 核心闭环，并开始支撑 P1：课件、老师工作台、家长设置和数据日志。</p>
      <AdminDataPanel />
    </section>
  );
}
