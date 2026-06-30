package com.aiclassroom.parent;

import jakarta.validation.constraints.NotBlank;

public record UpsertParentSettingsRequest(
    @NotBlank String parentPhone,
    Integer computeBudgetLimit,
    Integer dailyMinutesLimit,
    String enabledAiFeatures,
    Boolean allowPublicPublishing,
    Boolean autoNarrationEnabled,
    Boolean voiceInputEnabled
) {
}
