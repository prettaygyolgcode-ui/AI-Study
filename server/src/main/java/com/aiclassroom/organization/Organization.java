package com.aiclassroom.organization;

import java.util.UUID;

public record Organization(UUID id, String name, String cooperationStatus, int classroomCount, int teacherCount) {
}
