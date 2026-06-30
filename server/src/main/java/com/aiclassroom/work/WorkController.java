package com.aiclassroom.work;

import com.aiclassroom.common.ApiResponse;
import com.aiclassroom.common.DatabasePage;
import com.aiclassroom.common.PageResponse;
import jakarta.validation.Valid;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.UUID;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/admin/works")
public class WorkController {
    private final JdbcTemplate jdbcTemplate;

    public WorkController(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @GetMapping
    public ApiResponse<PageResponse<Work>> list() {
        var works = jdbcTemplate.query(
            """
            select id, type, title, author_name, status, publish_status, recommended, like_count, score
            from works
            order by updated_at desc, created_at desc
            """,
            WorkController::mapWork
        );
        return ApiResponse.ok(DatabasePage.of(works));
    }

    @PostMapping
    public ApiResponse<Work> create(@Valid @RequestBody CreateWorkRequest request) {
        var id = UUID.randomUUID();
        jdbcTemplate.update(
            """
            insert into works (id, type, title, author_name, status, publish_status, recommended, like_count, score, created_at, updated_at)
            values (?, ?, ?, ?, 'PENDING_REVIEW', 'PRIVATE', false, 0, 0, now(), now())
            """,
            id,
            request.type(),
            request.title(),
            request.authorName()
        );
        return ApiResponse.ok(findById(id));
    }

    @PostMapping("/{id}/approve")
    public ApiResponse<Work> approve(@PathVariable UUID id) {
        var work = update(id, "PUBLISHED", true, null);
        writeAudit("WORK_APPROVED", "work", id);
        return ApiResponse.ok(work);
    }

    @PostMapping("/{id}/reject")
    public ApiResponse<Work> reject(@PathVariable UUID id, @RequestBody(required = false) RejectWorkRequest request) {
        var work = update(id, "REJECTED", false, null);
        writeAudit("WORK_REJECTED", "work", id);
        return ApiResponse.ok(work);
    }

    @PostMapping("/{id}/recommend")
    public ApiResponse<Work> recommend(@PathVariable UUID id) {
        var work = update(id, null, null, true);
        writeAudit("WORK_RECOMMENDED", "work", id);
        return ApiResponse.ok(work);
    }

    @PostMapping("/{id}/offline")
    public ApiResponse<Work> offline(@PathVariable UUID id) {
        var work = update(id, "OFFLINE", false, false);
        writeAudit("WORK_OFFLINE", "work", id);
        return ApiResponse.ok(work);
    }

    private Work update(UUID id, String status, Boolean published, Boolean recommended) {
        var current = findById(id);
        var nextStatus = status == null ? current.status() : status;
        var nextPublishStatus = published == null
            ? (current.published() ? "PUBLIC" : "PRIVATE")
            : (published ? "PUBLIC" : "PRIVATE");
        var nextRecommended = recommended == null ? current.recommended() : recommended;

        jdbcTemplate.update(
            """
            update works
            set status = ?, publish_status = ?, recommended = ?, updated_at = now()
            where id = ?
            """,
            nextStatus,
            nextPublishStatus,
            nextRecommended,
            id
        );
        return findById(id);
    }

    private Work findById(UUID id) {
        var works = jdbcTemplate.query(
            """
            select id, type, title, author_name, status, publish_status, recommended, like_count, score
            from works
            where id = ?
            """,
            WorkController::mapWork,
            id
        );
        if (works.isEmpty()) {
            throw new IllegalArgumentException("作品不存在");
        }
        return works.get(0);
    }

    private void writeAudit(String action, String targetType, UUID targetId) {
        jdbcTemplate.update(
            """
            insert into audit_logs (id, actor_user_id, action, target_type, target_id, metadata, created_at)
            values (?, null, ?, ?, ?, '{}'::jsonb, now())
            """,
            UUID.randomUUID(),
            action,
            targetType,
            targetId
        );
    }

    private static Work mapWork(ResultSet rs, int rowNum) throws SQLException {
        return new Work(
            rs.getObject("id", UUID.class),
            rs.getString("type"),
            rs.getString("title"),
            rs.getString("author_name"),
            rs.getString("status"),
            "PUBLIC".equals(rs.getString("publish_status")),
            rs.getBoolean("recommended"),
            rs.getInt("like_count"),
            rs.getDouble("score")
        );
    }
}
