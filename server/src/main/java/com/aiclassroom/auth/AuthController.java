package com.aiclassroom.auth;

import com.aiclassroom.common.ApiResponse;
import com.aiclassroom.security.JwtService;
import jakarta.validation.Valid;
import java.util.Map;
import java.util.UUID;
import org.springframework.security.core.Authentication;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/auth")
public class AuthController {
    private final JwtService jwtService;
    private final JdbcTemplate jdbcTemplate;

    public AuthController(JwtService jwtService, JdbcTemplate jdbcTemplate) {
        this.jwtService = jwtService;
        this.jdbcTemplate = jdbcTemplate;
    }

    @PostMapping("/sms/send")
    public ApiResponse<Map<String, String>> sendCode(@RequestBody Map<String, String> body) {
        return ApiResponse.ok(Map.of("message", "验证码已发送，P0 本地环境固定为 123456"));
    }

    @PostMapping("/sms/login")
    public ApiResponse<LoginResponse> login(@Valid @RequestBody LoginRequest request) {
        // POST /api/v1/auth/sms/login
        validateLocalCode(request.code());

        var displayName = "家长用户";
        upsertUser(request.phone(), displayName, "PARENT");
        writeAudit("PARENT_LOGIN", "user", request.phone());
        var token = jwtService.createToken(request.phone(), "PARENT");
        return ApiResponse.ok(new LoginResponse(token, "PARENT", displayName));
    }

    @PostMapping("/admin/sms/login")
    public ApiResponse<LoginResponse> adminLogin(@Valid @RequestBody LoginRequest request) {
        // POST /api/v1/auth/admin/sms/login
        validateLocalCode(request.code());

        var role = request.phone().endsWith("9999") ? "SUPER_ADMIN" : "OPS_ADMIN";
        var displayName = role.equals("SUPER_ADMIN") ? "超级管理员" : "后台管理员";
        upsertUser(request.phone(), displayName, role);
        writeAudit("ADMIN_LOGIN", "user", request.phone());
        var token = jwtService.createToken(request.phone(), role);
        return ApiResponse.ok(new LoginResponse(token, role, displayName));
    }

    private void validateLocalCode(String code) {
        if (!"123456".equals(code)) {
            throw new IllegalArgumentException("验证码错误");
        }
    }

    @PostMapping("/logout")
    public ApiResponse<Map<String, String>> logout() {
        return ApiResponse.ok(Map.of("message", "已退出"));
    }

    @GetMapping("/me")
    public ApiResponse<CurrentUserResponse> me(Authentication authentication) {
        var account = jdbcTemplate.query(
            "select id, display_name, role from users where phone = ? limit 1",
            (rs, rowNum) -> new CurrentUserResponse(
                rs.getObject("id", UUID.class).toString(),
                authentication.getName(),
                rs.getString("role"),
                rs.getString("display_name")
            ),
            authentication.getName()
        );

        if (!account.isEmpty()) {
            return ApiResponse.ok(account.get(0));
        }

        return ApiResponse.ok(new CurrentUserResponse("unknown", authentication.getName(), "UNKNOWN", "未知账号"));
    }

    private void upsertUser(String phone, String displayName, String role) {
        jdbcTemplate.update(
            """
            insert into users (id, phone, display_name, role, status, created_at, updated_at)
            values (?, ?, ?, ?, 'ACTIVE', now(), now())
            on conflict (phone) do update set
              display_name = excluded.display_name,
              role = excluded.role,
              status = 'ACTIVE',
              updated_at = now()
            """,
            UUID.randomUUID(),
            phone,
            displayName,
            role
        );
    }

    private void writeAudit(String action, String targetType, String phone) {
        jdbcTemplate.update(
            """
            insert into audit_logs (id, actor_user_id, action, target_type, target_id, metadata, created_at)
            values (?, null, ?, ?, null, jsonb_build_object('phone', ?), now())
            """,
            UUID.randomUUID(),
            action,
            targetType,
            phone
        );
    }
}
