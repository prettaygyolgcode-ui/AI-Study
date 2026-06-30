package com.aiclassroom.organization;

import jakarta.validation.constraints.NotBlank;

public record CreateOrganizationRequest(@NotBlank String name, String cooperationStatus) {
}
