package com.aiclassroom.courseware;

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
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/admin/coursewares")
public class CoursewareController {
    private final JdbcTemplate jdbcTemplate;

    public CoursewareController(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @GetMapping
    public ApiResponse<PageResponse<Courseware>> list(
        @RequestParam(required = false) String ageBand,
        @RequestParam(required = false) String category,
        @RequestParam(required = false) String status,
        @RequestParam(required = false) String keyword
    ) {
        var sql = new StringBuilder(
            """
            select id, title, age_band, category, status, original_file_url, converted_asset_url,
                   conversion_status, duration_minutes, created_at, updated_at
            from coursewares
            where 1 = 1
            """
        );
        var args = new ArrayList<Object>();
        if (ageBand != null && !ageBand.isBlank()) {
            sql.append(" and age_band = ?");
            args.add(ageBand);
        }
        if (category != null && !category.isBlank()) {
            sql.append(" and category = ?");
            args.add(category);
        }
        if (status != null && !status.isBlank()) {
            sql.append(" and status = ?");
            args.add(status);
        }
        if (keyword != null && !keyword.isBlank()) {
            sql.append(" and title ilike ?");
            args.add("%" + keyword + "%");
        }
        sql.append(" order by updated_at desc, created_at desc");

        var coursewares = jdbcTemplate.query(sql.toString(), CoursewareController::mapCourseware, args.toArray());
        return ApiResponse.ok(DatabasePage.of(coursewares));
    }

    @PostMapping
    public ApiResponse<Courseware> create(@Valid @RequestBody CreateCoursewareRequest request) {
        var id = UUID.randomUUID();
        jdbcTemplate.update(
            """
            insert into coursewares
              (id, title, age_band, category, status, original_file_url, converted_asset_url,
               conversion_status, duration_minutes, created_at, updated_at)
            values (?, ?, ?, ?, 'DRAFT', ?, null, 'PENDING', ?, now(), now())
            """,
            id,
            request.title(),
            request.ageBand(),
            request.category(),
            request.originalFileUrl(),
            request.durationMinutes() == null ? 0 : request.durationMinutes()
        );
        writeAudit("COURSEWARE_CREATED", "courseware", id);
        return ApiResponse.ok(findById(id));
    }

    @PostMapping("/{id}/convert")
    public ApiResponse<Courseware> convert(@PathVariable UUID id) {
        jdbcTemplate.update(
            """
            update coursewares
            set conversion_status = 'COMPLETED',
                converted_asset_url = concat('/coursewares/', id::text, '/play.pdf'),
                updated_at = now()
            where id = ?
            """,
            id
        );
        writeAudit("COURSEWARE_CONVERTED", "courseware", id);
        return ApiResponse.ok(findById(id));
    }

    @PostMapping("/{id}/publish")
    public ApiResponse<Courseware> publish(@PathVariable UUID id) {
        jdbcTemplate.update("update coursewares set status = 'PUBLISHED', updated_at = now() where id = ?", id);
        writeAudit("COURSEWARE_PUBLISHED", "courseware", id);
        return ApiResponse.ok(findById(id));
    }

    @PostMapping("/{id}/offline")
    public ApiResponse<Courseware> offline(@PathVariable UUID id) {
        jdbcTemplate.update("update coursewares set status = 'OFFLINE', updated_at = now() where id = ?", id);
        writeAudit("COURSEWARE_OFFLINE", "courseware", id);
        return ApiResponse.ok(findById(id));
    }

    private Courseware findById(UUID id) {
        var coursewares = jdbcTemplate.query(
            """
            select id, title, age_band, category, status, original_file_url, converted_asset_url,
                   conversion_status, duration_minutes, created_at, updated_at
            from coursewares
            where id = ?
            """,
            CoursewareController::mapCourseware,
            id
        );
        if (coursewares.isEmpty()) {
            throw new IllegalArgumentException("课件不存在");
        }
        return coursewares.get(0);
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

    public static Courseware mapCourseware(ResultSet rs, int rowNum) throws SQLException {
        return new Courseware(
            rs.getObject("id", UUID.class),
            rs.getString("title"),
            rs.getString("age_band"),
            rs.getString("category"),
            rs.getString("status"),
            rs.getString("original_file_url"),
            rs.getString("converted_asset_url"),
            rs.getString("conversion_status"),
            rs.getInt("duration_minutes"),
            rs.getObject("created_at", java.time.OffsetDateTime.class),
            rs.getObject("updated_at", java.time.OffsetDateTime.class)
        );
    }
}
