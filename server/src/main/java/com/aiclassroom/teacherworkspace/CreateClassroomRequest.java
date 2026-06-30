package com.aiclassroom.teacherworkspace;

import jakarta.validation.constraints.NotBlank;
import java.util.UUID;

public record CreateClassroomRequest(
    UUID organizationId,
    UUID teacherId,
    @NotBlank String name,
    @NotBlank String ageBand
) {
}
