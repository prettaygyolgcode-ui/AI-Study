"use client";

import { useEffect, useState } from "react";
import { login } from "../../lib/api";
import { hasValidAdminSession } from "../../lib/auth";

export default function LoginPage() {
  const [phone, setPhone] = useState("13800138000");
  const [code, setCode] = useState("123456");
  const [message, setMessage] = useState("本地 P0 环境验证码固定为 123456。");

  useEffect(() => {
    if (hasValidAdminSession()) {
      window.location.href = "/";
    }
  }, []);

  async function handleLogin() {
    try {
      const result = await login(phone, code);
      setMessage(`已登录：${result.displayName} / ${result.role}`);
      window.location.href = "/";
    } catch {
      setMessage("登录失败，请检查手机号和验证码。");
    }
  }

  return (
    <section>
      <h1>后台登录</h1>
      <div className="card">
        <label>
          手机号
          <input value={phone} onChange={(event) => setPhone(event.target.value)} />
        </label>
        <label>
          验证码
          <input value={code} onChange={(event) => setCode(event.target.value)} />
        </label>
        <button className="button" onClick={handleLogin}>登录后台</button>
        <p>{message}</p>
      </div>
    </section>
  );
}
