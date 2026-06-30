import { AccountsPanel } from "../../components/AccountsPanel";

export default function AccountsPage() {
  return (
    <section>
      <h1>账号管理</h1>
      <p>后台账号、老师账号和家长账号均来自真实登录或创建记录。</p>
      <AccountsPanel />
    </section>
  );
}
