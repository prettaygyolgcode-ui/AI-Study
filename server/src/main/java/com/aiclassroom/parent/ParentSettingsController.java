package com.aiclassroom.parent;

import com.aiclassroom.common.ApiResponse;
import jakarta.validation.Valid;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Map;
import java.util.UUID;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/admin/parent-settings")
public class ParentSettingsController {
    private final JdbcTemplate jdbcTemplate;

    public ParentSettingsController(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @GetMapping
    public ApiResponse<ParentSettingsDto> get(@RequestParam String parentPhone) {
        return ApiResponse.ok(findOrDefault(parentPhone));
    }

    @PutMapping
    public ApiResponse<ParentSettingsDto> upsert(@Valid @RequestBody UpsertParentSettingsRequest request) {
        var parentUserId = ensureParentUser(request.parentPhone());
        var existing = jdbcTemplate.query(
            """
            select ps.id, u.phone as parent_phone, ps.compute_budget_limit, ps.daily_minutes_limit,
                   ps.enabled_ai_features::text, ps.allow_public_publishing, ps.auto_narration_enabled,
                   ps.voice_input_enabled, ps.updated_at
            from parent_settings ps
            join users u on u.id = ps.parent_user_id
            where u.phone = ?
            limit 1
            """,
            ParentSettingsController::mapSettings,
            request.parentPhone()
        );

        var id = existing.isEmpty() ? UUID.randomUUID() : existing.get(0).id();
        jdbcTemplate.update(
            """
            insert into parent_settings
              (id, parent_user_id, student_id, compute_budget_limit, daily_minutes_limit,
               enabled_ai_features, allow_public_publishing, auto_narration_enabled, voice_input_enabled, updated_at)
            values (?, ?, null, ?, ?, ?::jsonb, ?, ?, ?, now())
            on conflict (id) do update set
              compute_budget_limit = excluded.compute_budget_limit,
              daily_minutes_limit = excluded.daily_minutes_limit,
              enabled_ai_features = excluded.enabled_ai_features,
              allow_public_publishing = excluded.allow_public_publishing,
              auto_narration_enabled = excluded.auto_narration_enabled,
              voice_input_enabled = excluded.voice_input_enabled,
              updated_at = now()
            """,
            id,
            parentUserId,
            request.computeBudgetLimit() == null ? 100 : request.computeBudgetLimit(),
            request.dailyMinutesLimit() == null ? 60 : request.dailyMinutesLimit(),
            request.enabledAiFeatures() == null || request.enabledAiFeatures().isBlank()
                ? "[\"story\",\"image\",\"music\",\"video\"]"
                : request.enabledAiFeatures(),
            request.allowPublicPublishing() == null || request.allowPublicPublishing(),
            request.autoNarrationEnabled() == null || request.autoNarrationEnabled(),
            request.voiceInputEnabled() == null || request.voiceInputEnabled()
        );
        writeAudit("PARENT_SETTINGS_UPDATED", "parent_settings", id);
        return ApiResponse.ok(findOrDefault(request.parentPhone()));
    }

    private ParentSettingsDto findOrDefault(String parentPhone) {
        ensureParentUser(parentPhone);
        var settings = jdbcTemplate.query(
            """
            select ps.id, u.phone as parent_phone, ps.compute_budget_limit, ps.daily_minutes_limit,
                   ps.enabled_ai_features::text, ps.allow_public_publishing, ps.auto_narration_enabled,
                   ps.voice_input_enabled, ps.updated_at
            from parent_settings ps
            join users u on u.id = ps.parent_user_id
            where u.phone = ?
            limit 1
            """,
            ParentSettingsController::mapSettings,
            parentPhone
        );
        if (!settings.isEmpty()) {
            return settings.get(0);
        }
        return new ParentSettingsDto(
            null,
            parentPhone,
            100,
            60,
            "[\"story\",\"image\",\"music\",\"video\"]",
            true,
            true,
            true,
            java.time.OffsetDateTime.now()
        );
    }

    private UUID ensureParentUser(String parentPhone) {
        jdbcTemplate.update(
            """
            insert into users (id, phone, display_name, role, status, created_at, updated_at)
            values (?, ?, '家长用户', 'PARENT', 'ACTIVE', now(), now())
            on conflict (phone) do update set role = 'PARENT', status = 'ACTIVE', updated_at = now()
            """,
            UUID.randomUUID(),
            parentPhone
        );
        return jdbcTemplate.queryForObject("select id from users where phone = ?", UUID.class, parentPhone);
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

    private static ParentSettingsDto mapSettings(ResultSet rs, int rowNum) throws SQLException {
        return new ParentSettingsDto(
            rs.getObject("id", UUID.class),
            rs.getString("parent_phone"),
            rs.getInt("compute_budget_limit"),
            rs.getInt("daily_minutes_limit"),
            rs.getString("enabled_ai_features"),
            rs.getBoolean("allow_public_publishing"),
            rs.getBoolean("auto_narration_enabled"),
            rs.getBoolean("voice_input_enabled"),
            rs.getObject("updated_at", java.time.OffsetDateTime.class)
        );
    }
}
