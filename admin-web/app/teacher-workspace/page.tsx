import { TeacherWorkspacePanel } from "../../components/TeacherWorkspacePanel";

export default function TeacherWorkspacePage() {
  return (
    <section>
      <h1>老师工作台</h1>
      <p>查看可用课件、管理班级、绑定学生，并记录课堂播放进度。</p>
      <TeacherWorkspacePanel />
    </section>
  );
}
