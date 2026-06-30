package com.aiclassroom.organization;

import com.aiclassroom.common.ApiResponse;
import com.aiclassroom.common.DatabasePage;
import com.aiclassroom.common.PageResponse;
import jakarta.validation.Valid;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.UUID;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/admin/organizations")
public class OrganizationController {
    private final JdbcTemplate jdbcTemplate;

    public OrganizationController(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @GetMapping
    public ApiResponse<PageResponse<Organization>> list() {
        var organizations = jdbcTemplate.query(
            "select id, name, cooperation_status, classroom_count, teacher_count from organizations order by created_at desc",
            OrganizationController::mapOrganization
        );
        return ApiResponse.ok(DatabasePage.of(organizations));
    }

    @PostMapping
    public ApiResponse<Organization> create(@Valid @RequestBody CreateOrganizationRequest request) {
        var id = UUID.randomUUID();
        var status = request.cooperationStatus() == null ? "ACTIVE" : request.cooperationStatus();
        jdbcTemplate.update(
            """
            insert into organizations (id, name, cooperation_status, classroom_count, teacher_count, created_at, updated_at)
            values (?, ?, ?, 0, 0, now(), now())
            """,
            id,
            request.name(),
            status
        );
        var organization = new Organization(
            id,
            request.name(),
            status,
            0,
            0
        );
        return ApiResponse.ok(organization);
    }

    private static Organization mapOrganization(ResultSet rs, int rowNum) throws SQLException {
        return new Organization(
            rs.getObject("id", UUID.class),
            rs.getString("name"),
            rs.getString("cooperation_status"),
            rs.getInt("classroom_count"),
            rs.getInt("teacher_count")
        );
    }
}
