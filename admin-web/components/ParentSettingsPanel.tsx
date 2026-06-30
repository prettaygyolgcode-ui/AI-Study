"use client";

import { useState } from "react";
import { type ParentSettings, getParentSettings, updateParentSettings } from "../lib/api";

export function ParentSettingsPanel() {
  const [phone, setPhone] = useState("13800138000");
  const [settings, setSettings] = useState<ParentSettings | null>(null);
  const [message, setMessage] = useState("输入家长手机号后查询或保存设置。");

  async function load() {
    const data = await getParentSettings(phone.trim());
    setSettings(data);
    setMessage("家长设置已加载。");
  }

  async function save() {
    if (!settings) {
      await load();
      return;
    }
    const data = await updateParentSettings(settings);
    setSettings(data);
    setMessage("家长设置已保存。");
  }

  function patch(update: Partial<ParentSettings>) {
    setSettings((current) => (current ? { ...current, ...update } : current));
  }

  return (
    <div className="card form-card">
      <label>
        家长手机号
        <input value={phone} onChange={(event) => setPhone(event.target.value)} />
      </label>
      <button className="button" onClick={load}>
        查询设置
      </button>
      <p>{message}</p>
      {settings ? (
        <>
          <div className="form-grid">
            <label>
              算力额度
              <input
                value={settings.computeBudgetLimit}
                onChange={(event) => patch({ computeBudgetLimit: Number(event.target.value) || 0 })}
              />
            </label>
            <label>
              每日时长
              <input
                value={settings.dailyMinutesLimit}
                onChange={(event) => patch({ dailyMinutesLimit: Number(event.target.value) || 0 })}
              />
            </label>
            <label>
              AI 功能 JSON
              <input
                value={settings.enabledAiFeatures}
                onChange={(event) => patch({ enabledAiFeatures: event.target.value })}
              />
            </label>
          </div>
          <div className="toggle-row">
            <label>
              <input
                checked={settings.allowPublicPublishing}
                onChange={(event) => patch({ allowPublicPublishing: event.target.checked })}
                type="checkbox"
              />
              允许公开发布
            </label>
            <label>
              <input
                checked={settings.autoNarrationEnabled}
                onChange={(event) => patch({ autoNarrationEnabled: event.target.checked })}
                type="checkbox"
              />
              自动朗读
            </label>
            <label>
              <input
                checked={settings.voiceInputEnabled}
                onChange={(event) => patch({ voiceInputEnabled: event.target.checked })}
                type="checkbox"
              />
              语音输入
            </label>
          </div>
          <button className="button" onClick={save}>
            保存设置
          </button>
        </>
      ) : null}
    </div>
  );
}
