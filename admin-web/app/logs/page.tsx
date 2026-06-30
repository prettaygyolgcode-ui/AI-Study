import { LogsPanel } from "../../components/LogsPanel";

export default function LogsPage() {
  return (
    <section>
      <h1>数据日志</h1>
      <p>查看登录、课件、作品、家长设置和课堂播放等真实操作记录。</p>
      <LogsPanel />
    </section>
  );
}
