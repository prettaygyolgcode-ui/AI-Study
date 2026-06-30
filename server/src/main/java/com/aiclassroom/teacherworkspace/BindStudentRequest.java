package com.aiclassroom.teacherworkspace;

import jakarta.validation.constraints.NotBlank;

public record BindStudentRequest(
    @NotBlank String parentPhone,
    @NotBlank String nickname,
    String ageBand
) {
}
