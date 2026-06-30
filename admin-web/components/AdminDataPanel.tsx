"use client";

import { useEffect, useState } from "react";
import { getAiFriends, getCreationCards, getWorks, type AiFriend, type CreationCard, type Work } from "../lib/api";

export function AdminDataPanel() {
  const [works, setWorks] = useState<Work[]>([]);
  const [friends, setFriends] = useState<AiFriend[]>([]);
  const [cards, setCards] = useState<CreationCard[]>([]);
  const [message, setMessage] = useState("正在加载后台数据...");

  useEffect(() => {
    Promise.all([getWorks(), getAiFriends(), getCreationCards()])
      .then(([workPage, friendPage, cardPage]) => {
        setWorks(workPage.items);
        setFriends(friendPage.items);
        setCards(cardPage.items);
        setMessage("后台数据已加载");
      })
      .catch(() => {
        setMessage("请先进入登录页，使用手机号和验证码 123456 登录。");
      });
  }, []);

  return (
    <>
      <p>{message}</p>
      <div className="grid">
        <div className="card">
          <h2>待审核作品</h2>
          <strong>{works.filter((item) => item.status === "PENDING_REVIEW").length}</strong>
        </div>
        <div className="card">
          <h2>AI 朋友</h2>
          <strong>{friends.length}</strong>
        </div>
        <div className="card">
          <h2>创作卡片</h2>
          <strong>{cards.length}</strong>
        </div>
      </div>
    </>
  );
}
