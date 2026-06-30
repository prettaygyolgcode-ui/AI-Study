package com.aiclassroom.teacher;

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
@RequestMapping("/api/v1/admin/teachers")
public class TeacherController {
    private final JdbcTemplate jdbcTemplate;

    public TeacherController(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @GetMapping
    public ApiResponse<PageResponse<Teacher>> list() {
        var teachers = jdbcTemplate.query(
            "select id, name, phone, organization_id, authorized from teachers order by created_at desc",
            TeacherController::mapTeacher
        );
        return ApiResponse.ok(DatabasePage.of(teachers));
    }

    @PostMapping
    public ApiResponse<Teacher> create(@Valid @RequestBody CreateTeacherRequest request) {
        var userId = UUID.randomUUID();
        var teacherId = UUID.randomUUID();
        jdbcTemplate.update(
            """
            insert into users (id, phone, display_name, role, status, created_at, updated_at)
            values (?, ?, ?, 'TEACHER', 'ACTIVE', now(), now())
            on conflict (phone) do update set
              display_name = excluded.display_name,
              role = 'TEACHER',
              status = 'ACTIVE',
              updated_at = now()
            """,
            userId,
            request.phone(),
            request.name()
        );
        var actualUserId = jdbcTemplate.queryForObject(
            "select id from users where phone = ?",
            UUID.class,
            request.phone()
        );
        jdbcTemplate.update(
            """
            insert into teachers (id, user_id, organization_id, name, phone, authorized, created_at)
            values (?, ?, ?, ?, ?, false, now())
            """,
            teacherId,
            actualUserId,
            request.organizationId(),
            request.name(),
            request.phone()
        );
        var teacher = new Teacher(teacherId, request.name(), request.phone(), request.organizationId(), false);
        return ApiResponse.ok(teacher);
    }

    @PostMapping("/{id}/authorize")
    public ApiResponse<Teacher> authorize(@PathVariable UUID id) {
        jdbcTemplate.update(
            "update teachers set authorized = true, authorized_at = now() where id = ?",
            id
        );
        var teachers = jdbcTemplate.query(
            "select id, name, phone, organization_id, authorized from teachers where id = ?",
            TeacherController::mapTeacher,
            id
        );
        if (teachers.isEmpty()) {
            throw new IllegalArgumentException("老师不存在");
        }
        return ApiResponse.ok(teachers.get(0));
    }

    private static Teacher mapTeacher(ResultSet rs, int rowNum) throws SQLException {
        return new Teacher(
            rs.getObject("id", UUID.class),
            rs.getString("name"),
            rs.getString("phone"),
            rs.getObject("organization_id", UUID.class),
            rs.getBoolean("authorized")
        );
    }
}
