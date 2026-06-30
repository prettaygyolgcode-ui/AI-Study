package com.aiclassroom.teacher;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.util.UUID;

public record CreateTeacherRequest(@NotBlank String name, @NotBlank String phone, @NotNull UUID organizationId) {
}
