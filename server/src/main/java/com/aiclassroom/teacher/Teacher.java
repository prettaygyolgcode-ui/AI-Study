package com.aiclassroom.teacher;

import java.util.UUID;

public record Teacher(UUID id, String name, String phone, UUID organizationId, boolean authorized) {
}
