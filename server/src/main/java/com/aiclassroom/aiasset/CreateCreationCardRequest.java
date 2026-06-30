package com.aiclassroom.aiasset;

import jakarta.validation.constraints.NotBlank;

public record CreateCreationCardRequest(
    @NotBlank String type,
    @NotBlank String name,
    @NotBlank String icon,
    @NotBlank String promptTemplate,
    String status
) {
}
