package com.aiclassroom.courseware;

import jakarta.validation.constraints.NotBlank;

public record CreateCoursewareRequest(
    @NotBlank String title,
    @NotBlank String ageBand,
    @NotBlank String category,
    String originalFileUrl,
    Integer durationMinutes
) {
}
