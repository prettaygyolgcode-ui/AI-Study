"use client";

import { useEffect, useState } from "react";
import { getAiFriends, getCreationCards, type AiFriend, type CreationCard } from "../lib/api";

export function AiAssetsPanel() {
  const [friends, setFriends] = useState<AiFriend[]>([]);
  const [cards, setCards] = useState<CreationCard[]>([]);
  const [message, setMessage] = useState("正在加载 AI 卡片库...");

  useEffect(() => {
    Promise.all([getAiFriends(), getCreationCards()])
      .then(([friendPage, cardPage]) => {
        setFriends(friendPage.items);
        setCards(cardPage.items);
        setMessage("AI 卡片库已加载");
      })
      .catch(() => setMessage("请先登录后再管理 AI 卡片库。"));
  }, []);

  return (
    <>
      <p>{message}</p>
      <div className="grid">
        <div className="card">
          <h2>AI 朋友</h2>
          {friends.map((friend) => (
            <p key={friend.id}>
              <strong>{friend.name}</strong>：{friend.description}
            </p>
          ))}
        </div>
        <div className="card">
          <h2>创作卡片</h2>
          {cards.map((card) => (
            <p key={card.id}>
              <strong>{card.name}</strong>：{card.promptTemplate}
            </p>
          ))}
        </div>
      </div>
    </>
  );
}
