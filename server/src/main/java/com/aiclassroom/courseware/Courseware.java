package com.aiclassroom.courseware;

import java.time.OffsetDateTime;
import java.util.UUID;

public record Courseware(
    UUID id,
    String title,
    String ageBand,
    String category,
    String status,
    String originalFileUrl,
    String convertedAssetUrl,
    String conversionStatus,
    int durationMinutes,
    OffsetDateTime createdAt,
    OffsetDateTime updatedAt
) {
}
