package com.aiclassroom.appapi;

import com.aiclassroom.common.ApiResponse;
import com.aiclassroom.aiasset.AiAssetController;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/app")
public class AppBootstrapController {
    private final JdbcTemplate jdbcTemplate;

    public AppBootstrapController(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @GetMapping("/bootstrap")
    public ApiResponse<AppBootstrapResponse> bootstrap() {
        // /api/v1/app/bootstrap
        var parentControl = new AppBootstrapResponse.ParentControl(100, 60, true, true, true);
        var aiFriends = jdbcTemplate.query(
            "select id, name, icon_url, description, role_prompt, status from ai_friends where status = 'ACTIVE' order by sort_order asc, name asc",
            AiAssetController::mapAiFriend
        );
        var creationCards = jdbcTemplate.query(
            "select id, type, name, icon_url, prompt_template, status from creation_cards where status = 'ACTIVE' order by sort_order asc, name asc",
            AiAssetController::mapCreationCard
        );
        var response = new AppBootstrapResponse(
            "AI课堂",
            "小小创作者",
            aiFriends,
            creationCards,
            parentControl
        );
        return ApiResponse.ok(response);
    }
}
