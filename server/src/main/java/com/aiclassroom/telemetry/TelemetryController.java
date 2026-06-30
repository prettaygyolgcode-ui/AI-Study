package com.aiclassroom.telemetry;

import com.aiclassroom.common.ApiResponse;
import com.aiclassroom.common.DatabasePage;
import com.aiclassroom.common.PageResponse;
import jakarta.validation.Valid;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.UUID;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/admin/logs")
public class TelemetryController {
    private final JdbcTemplate jdbcTemplate;

    public TelemetryController(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @GetMapping
    public ApiResponse<PageResponse<AuditLogItem>> list(
        @RequestParam(required = false) String action,
        @RequestParam(required = false) String targetType,
        @RequestParam(required = false) String keyword
    ) {
        var sql = new StringBuilder(
            """
            select id, action, target_type, target_id, metadata::text, created_at
            from audit_logs
            where 1 = 1
            """
        );
        var args = new ArrayList<Object>();
        if (action != null && !action.isBlank()) {
            sql.append(" and action = ?");
            args.add(action);
        }
        if (targetType != null && !targetType.isBlank()) {
            sql.append(" and target_type = ?");
            args.add(targetType);
        }
        if (keyword != null && !keyword.isBlank()) {
            sql.append(" and (action ilike ? or target_type ilike ? or metadata::text ilike ?)");
            var pattern = "%" + keyword + "%";
            args.add(pattern);
            args.add(pattern);
            args.add(pattern);
        }
        sql.append(" order by created_at desc limit 100");
        var logs = jdbcTemplate.query(sql.toString(), TelemetryController::mapLog, args.toArray());
        return ApiResponse.ok(DatabasePage.of(logs));
    }

    @PostMapping
    public ApiResponse<AuditLogItem> create(@Valid @RequestBody CreateAuditLogRequest request) {
        var id = UUID.randomUUID();
        jdbcTemplate.update(
            """
            insert into audit_logs (id, actor_user_id, action, target_type, target_id, metadata, created_at)
            values (?, null, ?, ?, ?, ?::jsonb, now())
            """,
            id,
            request.action(),
            request.targetType(),
            request.targetId(),
            request.metadata() == null || request.metadata().isBlank() ? "{}" : request.metadata()
        );
        var logs = jdbcTemplate.query(
            "select id, action, target_type, target_id, metadata::text, created_at from audit_logs where id = ?",
            TelemetryController::mapLog,
            id
        );
        return ApiResponse.ok(logs.get(0));
    }

    private static AuditLogItem mapLog(ResultSet rs, int rowNum) throws SQLException {
        return new AuditLogItem(
            rs.getObject("id", UUID.class),
            rs.getString("action"),
            rs.getString("target_type"),
            rs.getObject("target_id", UUID.class),
            rs.getString("metadata"),
            rs.getObject("created_at", java.time.OffsetDateTime.class)
        );
    }
}
