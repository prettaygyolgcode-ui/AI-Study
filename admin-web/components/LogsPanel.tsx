"use client";

import { useEffect, useState } from "react";
import { type AuditLogItem, getAuditLogs } from "../lib/api";

export function LogsPanel() {
  const [items, setItems] = useState<AuditLogItem[]>([]);
  const [keyword, setKeyword] = useState("");
  const [message, setMessage] = useState("正在加载日志...");

  function load() {
    getAuditLogs(keyword.trim() ? { keyword: keyword.trim() } : {})
      .then((data) => {
        setItems(data.items);
        setMessage(data.items.length ? "日志已加载。" : "暂无日志。");
      })
      .catch(() => setMessage("请先登录后再查看日志。"));
  }

  useEffect(load, []);

  return (
    <>
      <div className="card form-card">
        <label>
          关键词
          <input value={keyword} onChange={(event) => setKeyword(event.target.value)} />
        </label>
        <button className="button" onClick={load}>
          筛选日志
        </button>
      </div>
      <p>{message}</p>
      <table className="table">
        <thead>
          <tr>
            <th>时间</th>
            <th>动作</th>
            <th>对象</th>
            <th>元数据</th>
          </tr>
        </thead>
        <tbody>
          {items.map((item) => (
            <tr key={item.id}>
              <td>{new Intl.DateTimeFormat("zh-CN", { month: "2-digit", day: "2-digit", hour: "2-digit", minute: "2-digit" }).format(new Date(item.createdAt))}</td>
              <td>{item.action}</td>
              <td>{item.targetType}</td>
              <td>{item.metadata}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </>
  );
}
