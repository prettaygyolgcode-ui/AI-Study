import { WorksTable } from "../../components/WorksTable";

export default function WorksPage() {
  return (
    <section>
      <h1>作品审核</h1>
      <p>审核通过后，作品才会进入 App 广场。</p>
      <WorksTable />
    </section>
  );
}
