package com.aiclassroom.parent;

import java.time.OffsetDateTime;
import java.util.UUID;

public record ParentSettingsDto(
    UUID id,
    String parentPhone,
    int computeBudgetLimit,
    int dailyMinutesLimit,
    String enabledAiFeatures,
    boolean allowPublicPublishing,
    boolean autoNarrationEnabled,
    boolean voiceInputEnabled,
    OffsetDateTime updatedAt
) {
}
