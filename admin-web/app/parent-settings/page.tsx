import { ParentSettingsPanel } from "../../components/ParentSettingsPanel";

export default function ParentSettingsPage() {
  return (
    <section>
      <h1>家长设置</h1>
      <p>按家长手机号配置算力、时长、AI 功能和公开发布权限。</p>
      <ParentSettingsPanel />
    </section>
  );
}
