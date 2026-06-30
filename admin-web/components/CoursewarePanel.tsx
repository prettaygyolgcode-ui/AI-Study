"use client";

import { useEffect, useState } from "react";
import {
  type Courseware,
  convertCourseware,
  createCourseware,
  getCoursewares,
  offlineCourseware,
  publishCourseware
} from "../lib/api";

const ageBands = ["2-3", "4-5", "6-8", "9-12"];
const categories = ["故事表达", "科学探索", "艺术创作", "AI 创作"];

export function CoursewarePanel() {
  const [items, setItems] = useState<Courseware[]>([]);
  const [message, setMessage] = useState("正在加载课件...");
  const [form, setForm] = useState({
    title: "",
    ageBand: "6-8",
    category: "故事表达",
    originalFileUrl: "",
    durationMinutes: "30"
  });

  function load() {
    getCoursewares()
      .then((data) => {
        setItems(data.items);
        setMessage(data.items.length ? "课件列表已加载" : "暂无课件，请先创建。");
      })
      .catch(() => setMessage("请先登录后再查看课件。"));
  }

  useEffect(load, []);

  async function submit() {
    if (!form.title.trim()) {
      setMessage("请填写课件名称。");
      return;
    }
    await createCourseware({
      title: form.title.trim(),
      ageBand: form.ageBand,
      category: form.category,
      originalFileUrl: form.originalFileUrl.trim(),
      durationMinutes: Number(form.durationMinutes) || 0
    });
    setForm({ ...form, title: "", originalFileUrl: "" });
    load();
  }

  async function act(action: () => Promise<Courseware>) {
    await action();
    load();
  }

  return (
    <>
      <div className="card form-card">
        <h2>新增课件</h2>
        <div className="form-grid">
          <label>
            课件名称
            <input value={form.title} onChange={(event) => setForm({ ...form, title: event.target.value })} />
          </label>
          <label>
            年龄段
            <select value={form.ageBand} onChange={(event) => setForm({ ...form, ageBand: event.target.value })}>
              {ageBands.map((item) => (
                <option key={item}>{item}</option>
              ))}
            </select>
          </label>
          <label>
            分类
            <select value={form.category} onChange={(event) => setForm({ ...form, category: event.target.value })}>
              {categories.map((item) => (
                <option key={item}>{item}</option>
              ))}
            </select>
          </label>
          <label>
            原文件地址
            <input
              placeholder="/uploads/demo.pptx"
              value={form.originalFileUrl}
              onChange={(event) => setForm({ ...form, originalFileUrl: event.target.value })}
            />
          </label>
          <label>
            时长分钟
            <input
              value={form.durationMinutes}
              onChange={(event) => setForm({ ...form, durationMinutes: event.target.value })}
            />
          </label>
        </div>
        <button className="button" onClick={submit}>
          创建课件
        </button>
      </div>
      <p>{message}</p>
      <table className="table">
        <thead>
          <tr>
            <th>名称</th>
            <th>年龄段</th>
            <th>分类</th>
            <th>状态</th>
            <th>转换</th>
            <th>操作</th>
          </tr>
        </thead>
        <tbody>
          {items.map((item) => (
            <tr key={item.id}>
              <td>{item.title}</td>
              <td>{item.ageBand}</td>
              <td>{item.category}</td>
              <td>{item.status}</td>
              <td>{item.conversionStatus}</td>
              <td>
                <button className="button" onClick={() => act(() => convertCourseware(item.id))}>
                  生成资源
                </button>{" "}
                <button className="button secondary" onClick={() => act(() => publishCourseware(item.id))}>
                  上架
                </button>{" "}
                <button className="button danger" onClick={() => act(() => offlineCourseware(item.id))}>
                  下架
                </button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </>
  );
}
