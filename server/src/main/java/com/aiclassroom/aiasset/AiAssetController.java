package com.aiclassroom.aiasset;

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
@RequestMapping("/api/v1/admin")
public class AiAssetController {
    private final JdbcTemplate jdbcTemplate;

    public AiAssetController(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @GetMapping("/ai-friends")
    public ApiResponse<PageResponse<AiFriend>> listAiFriends() {
        var friends = jdbcTemplate.query(
            "select id, name, icon_url, description, role_prompt, status from ai_friends order by sort_order asc, name asc",
            AiAssetController::mapAiFriend
        );
        return ApiResponse.ok(DatabasePage.of(friends));
    }

    @PostMapping("/ai-friends")
    public ApiResponse<AiFriend> createAiFriend(@Valid @RequestBody CreateAiFriendRequest request) {
        var id = UUID.randomUUID();
        var status = request.status() == null ? "ACTIVE" : request.status();
        jdbcTemplate.update(
            """
            insert into ai_friends (id, name, icon_url, description, role_prompt, status, sort_order)
            values (?, ?, ?, ?, ?, ?, 0)
            """,
            id,
            request.name(),
            request.icon(),
            request.description(),
            request.rolePrompt(),
            status
        );
        var friend = new AiFriend(
            id,
            request.name(),
            request.icon(),
            request.description(),
            request.rolePrompt(),
            status
        );
        return ApiResponse.ok(friend);
    }

    @GetMapping("/creation-cards")
    public ApiResponse<PageResponse<CreationCard>> listCreationCards() {
        var cards = jdbcTemplate.query(
            "select id, type, name, icon_url, prompt_template, status from creation_cards order by sort_order asc, name asc",
            AiAssetController::mapCreationCard
        );
        return ApiResponse.ok(DatabasePage.of(cards));
    }

    @PostMapping("/creation-cards")
    public ApiResponse<CreationCard> createCreationCard(@Valid @RequestBody CreateCreationCardRequest request) {
        var id = UUID.randomUUID();
        var status = request.status() == null ? "ACTIVE" : request.status();
        jdbcTemplate.update(
            """
            insert into creation_cards (id, type, name, icon_url, prompt_template, status, sort_order)
            values (?, ?, ?, ?, ?, ?, 0)
            """,
            id,
            request.type(),
            request.name(),
            request.icon(),
            request.promptTemplate(),
            status
        );
        var card = new CreationCard(
            id,
            request.type(),
            request.name(),
            request.icon(),
            request.promptTemplate(),
            status
        );
        return ApiResponse.ok(card);
    }

    public static AiFriend mapAiFriend(ResultSet rs, int rowNum) throws SQLException {
        return new AiFriend(
            rs.getObject("id", UUID.class),
            rs.getString("name"),
            rs.getString("icon_url"),
            rs.getString("description"),
            rs.getString("role_prompt"),
            rs.getString("status")
        );
    }

    public static CreationCard mapCreationCard(ResultSet rs, int rowNum) throws SQLException {
        return new CreationCard(
            rs.getObject("id", UUID.class),
            rs.getString("type"),
            rs.getString("name"),
            rs.getString("icon_url"),
            rs.getString("prompt_template"),
            rs.getString("status")
        );
    }
}
