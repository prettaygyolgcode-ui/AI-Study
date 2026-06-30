package com.aiclassroom.account;

import com.aiclassroom.common.ApiResponse;
import com.aiclassroom.common.DatabasePage;
import com.aiclassroom.common.PageResponse;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/admin/accounts")
public class AccountController {
    private final JdbcTemplate jdbcTemplate;

    public AccountController(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @GetMapping
    public ApiResponse<PageResponse<UserAccount>> list(@RequestParam(required = false) String role) {
        List<UserAccount> accounts;
        if (role == null || role.isBlank()) {
            accounts = jdbcTemplate.query(
                "select id, phone, display_name, role, status, created_at, updated_at from users order by created_at desc",
                AccountController::mapAccount
            );
        } else if ("BACKEND".equalsIgnoreCase(role)) {
            accounts = jdbcTemplate.query(
                "select id, phone, display_name, role, status, created_at, updated_at from users where role in ('SUPER_ADMIN', 'OPS_ADMIN') order by created_at desc",
                AccountController::mapAccount
            );
        } else {
            accounts = jdbcTemplate.query(
                "select id, phone, display_name, role, status, created_at, updated_at from users where role = ? order by created_at desc",
                AccountController::mapAccount,
                role.toUpperCase()
            );
        }
        return ApiResponse.ok(DatabasePage.of(accounts));
    }

    private static UserAccount mapAccount(ResultSet rs, int rowNum) throws SQLException {
        return new UserAccount(
            rs.getObject("id", java.util.UUID.class),
            rs.getString("phone"),
            rs.getString("display_name"),
            rs.getString("role"),
            rs.getString("status"),
            rs.getObject("created_at", java.time.OffsetDateTime.class),
            rs.getObject("updated_at", java.time.OffsetDateTime.class)
        );
    }
}
