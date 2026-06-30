package com.aiclassroom.aiasset;

import jakarta.validation.constraints.NotBlank;

public record CreateAiFriendRequest(
    @NotBlank String name,
    @NotBlank String icon,
    @NotBlank String description,
    @NotBlank String rolePrompt,
    String status
) {
}
