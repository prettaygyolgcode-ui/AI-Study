"use client";

import { useEffect, useState } from "react";
import {
  type ClassroomSummary,
  type Courseware,
  type CoursewarePlayRecord,
  bindStudent,
  createClassroom,
  createPlayRecord,
  getTeacherWorkspace
} from "../lib/api";

export function TeacherWorkspacePanel() {
  const [coursewares, setCoursewares] = useState<Courseware[]>([]);
  const [classrooms, setClassrooms] = useState<ClassroomSummary[]>([]);
  const [records, setRecords] = useState<CoursewarePlayRecord[]>([]);
  const [message, setMessage] = useState("正在加载老师工作台...");
  const [classroomName, setClassroomName] = useState("");
  const [ageBand, setAgeBand] = useState("6-8");
  const [parentPhone, setParentPhone] = useState("");
  const [studentName, setStudentName] = useState("");

  function load() {
    getTeacherWorkspace()
      .then((data) => {
        setCoursewares(data.coursewares);
        setClassrooms(data.classrooms);
        setRecords(data.recentPlayRecords);
        setMessage("老师工作台已加载。");
      })
      .catch(() => setMessage("请先登录后再查看老师工作台。"));
  }

  useEffect(load, []);

  async function addClassroom() {
    if (!classroomName.trim()) {
      setMessage("请填写班级名称。");
      return;
    }
    await createClassroom({ name: classroomName.trim(), ageBand });
    setClassroomName("");
    load();
  }

  async function addStudent(classroomId: string) {
    if (!parentPhone.trim() || !studentName.trim()) {
      setMessage("请填写家长手机号和学生昵称。");
      return;
    }
    await bindStudent(classroomId, { parentPhone: parentPhone.trim(), nickname: studentName.trim(), ageBand });
    setParentPhone("");
    setStudentName("");
    load();
  }

  async function recordPlay(coursewareId: string) {
    await createPlayRecord({
      coursewareId,
      classroomId: classrooms[0]?.id,
      playedSeconds: 900,
      progressPercent: 50
    });
    load();
  }

  return (
    <>
      <p>{message}</p>
      <div className="grid">
        <div className="card">
          <h2>我的课程</h2>
          {coursewares.length === 0 ? <p>暂无已上架课件。</p> : null}
          {coursewares.map((item) => (
            <div className="list-item" key={item.id}>
              <strong>{item.title}</strong>
              <span>
                {item.ageBand} / {item.category}
              </span>
              <button className="button" onClick={() => recordPlay(item.id)}>
                记录播放
              </button>
            </div>
          ))}
        </div>
        <div className="card">
          <h2>班级管理</h2>
          <label>
            班级名称
            <input value={classroomName} onChange={(event) => setClassroomName(event.target.value)} />
          </label>
          <label>
            年龄段
            <select value={ageBand} onChange={(event) => setAgeBand(event.target.value)}>
              {["2-3", "4-5", "6-8", "9-12"].map((item) => (
                <option key={item}>{item}</option>
              ))}
            </select>
          </label>
          <button className="button" onClick={addClassroom}>
            创建班级
          </button>
          <hr />
          <label>
            家长手机号
            <input value={parentPhone} onChange={(event) => setParentPhone(event.target.value)} />
          </label>
          <label>
            学生昵称
            <input value={studentName} onChange={(event) => setStudentName(event.target.value)} />
          </label>
          {classrooms.map((item) => (
            <div className="list-item" key={item.id}>
              <strong>{item.name}</strong>
              <span>
                {item.ageBand} / {item.studentCount} 人
              </span>
              <button className="button secondary" onClick={() => addStudent(item.id)}>
                绑定到此班
              </button>
            </div>
          ))}
        </div>
      </div>
      <div className="card section-card">
        <h2>播放记录</h2>
        <table className="table">
          <thead>
            <tr>
              <th>课件</th>
              <th>班级</th>
              <th>进度</th>
              <th>时长</th>
            </tr>
          </thead>
          <tbody>
            {records.map((item) => (
              <tr key={item.id}>
                <td>{item.coursewareTitle}</td>
                <td>{item.classroomName || "未指定"}</td>
                <td>{item.progressPercent}%</td>
                <td>{Math.round(item.playedSeconds / 60)} 分钟</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </>
  );
}
