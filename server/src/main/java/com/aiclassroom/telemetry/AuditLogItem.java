package com.aiclassroom.telemetry;

import java.time.OffsetDateTime;
import java.util.UUID;

public record AuditLogItem(
    UUID id,
    String action,
    String targetType,
    UUID targetId,
    String metadata,
    OffsetDateTime createdAt
) {
}
