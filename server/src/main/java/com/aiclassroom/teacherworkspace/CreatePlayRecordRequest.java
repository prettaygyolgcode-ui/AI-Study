package com.aiclassroom.teacherworkspace;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import java.util.UUID;

public record CreatePlayRecordRequest(
    @NotNull UUID coursewareId,
    UUID teacherId,
    UUID classroomId,
    @Min(0) Integer playedSeconds,
    @Min(0) @Max(100) Integer progressPercent
) {
}
