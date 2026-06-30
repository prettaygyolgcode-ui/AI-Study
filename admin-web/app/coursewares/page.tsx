import { CoursewarePanel } from "../../components/CoursewarePanel";

export default function CoursewaresPage() {
  return (
    <section>
      <h1>课件管理</h1>
      <p>上传课件信息，配置年龄段和课程分类，并生成课堂可播放资源。</p>
      <CoursewarePanel />
    </section>
  );
}
