package com.aiclassroom.teacherworkspace;

import java.util.UUID;

public record ClassroomSummary(
    UUID id,
    String name,
    String ageBand,
    String status,
    int studentCount
) {
}
