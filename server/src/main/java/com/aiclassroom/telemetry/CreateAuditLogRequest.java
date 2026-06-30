package com.aiclassroom.telemetry;

import jakarta.validation.constraints.NotBlank;
import java.util.UUID;

public record CreateAuditLogRequest(
    @NotBlank String action,
    @NotBlank String targetType,
    UUID targetId,
    String metadata
) {
}
