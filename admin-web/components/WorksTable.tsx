"use client";

import { useEffect, useState } from "react";
import { approveWork, getWorks, rejectWork, type Work } from "../lib/api";

export function WorksTable() {
  const [works, setWorks] = useState<Work[]>([]);
  const [message, setMessage] = useState("正在加载作品...");

  function reload() {
    getWorks()
      .then((page) => {
        setWorks(page.items);
        setMessage("作品列表已加载");
      })
      .catch(() => setMessage("请先登录后再审核作品。"));
  }

  useEffect(() => {
    reload();
  }, []);

  async function handleApprove(id: string) {
    await approveWork(id);
    reload();
  }

  async function handleReject(id: string) {
    await rejectWork(id);
    reload();
  }

  return (
    <>
      <p>{message}</p>
      <table className="table">
        <thead>
          <tr>
            <th>标题</th>
            <th>类型</th>
            <th>作者</th>
            <th>状态</th>
            <th>操作</th>
          </tr>
        </thead>
        <tbody>
          {works.map((work) => (
            <tr key={work.id}>
              <td>{work.title}</td>
              <td>{work.type}</td>
              <td>{work.authorName}</td>
              <td>{work.status}</td>
              <td>
                <button className="button" onClick={() => handleApprove(work.id)}>通过</button>{" "}
                <button className="button danger" onClick={() => handleReject(work.id)}>驳回</button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </>
  );
}
