"use client";

import { useEffect, useState } from "react";
import { getAccounts, type UserAccount } from "../lib/api";

type AccountTab = {
  key: "BACKEND" | "TEACHER" | "PARENT";
  title: string;
};

const tabs: AccountTab[] = [
  { key: "BACKEND", title: "后台账号" },
  { key: "TEACHER", title: "老师账号" },
  { key: "PARENT", title: "家长账号" }
];

export function AccountsPanel() {
  const [activeTab, setActiveTab] = useState<AccountTab["key"]>("BACKEND");
  const [accounts, setAccounts] = useState<UserAccount[]>([]);
  const [message, setMessage] = useState("正在加载账号...");

  useEffect(() => {
    setMessage("正在加载账号...");
    getAccounts(activeTab)
      .then((page) => {
        setAccounts(page.items);
        setMessage(page.items.length === 0 ? "当前分类还没有账号。" : "账号已加载");
      })
      .catch(() => {
        setAccounts([]);
        setMessage("账号加载失败，请重新登录。");
      });
  }, [activeTab]);

  return (
    <>
      <div className="tabs">
        {tabs.map((tab) => (
          <button
            className={activeTab === tab.key ? "tab active" : "tab"}
            key={tab.key}
            onClick={() => setActiveTab(tab.key)}
          >
            {tab.title}
          </button>
        ))}
      </div>

      <p>{message}</p>

      <table className="table">
        <thead>
          <tr>
            <th>手机号</th>
            <th>名称</th>
            <th>角色</th>
            <th>状态</th>
            <th>更新时间</th>
          </tr>
        </thead>
        <tbody>
          {accounts.map((account) => (
            <tr key={account.id}>
              <td>{account.phone}</td>
              <td>{account.displayName}</td>
              <td>{account.role}</td>
              <td>{account.status}</td>
              <td>{formatTime(account.updatedAt)}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </>
  );
}

function formatTime(value: string) {
  return new Intl.DateTimeFormat("zh-CN", {
    month: "2-digit",
    day: "2-digit",
    hour: "2-digit",
    minute: "2-digit"
  }).format(new Date(value));
}
