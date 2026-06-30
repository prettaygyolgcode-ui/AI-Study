package com.aiclassroom.teacherworkspace;

import java.time.OffsetDateTime;
import java.util.UUID;

public record CoursewarePlayRecord(
    UUID id,
    UUID coursewareId,
    String coursewareTitle,
    UUID classroomId,
    String classroomName,
    int playedSeconds,
    int progressPercent,
    OffsetDateTime startedAt
) {
}
