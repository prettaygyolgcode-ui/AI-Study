package com.aiclassroom.teacherworkspace;

import java.util.UUID;

public record StudentBinding(
    UUID studentId,
    UUID classroomId,
    String parentPhone,
    String nickname,
    String bindStatus
) {
}
