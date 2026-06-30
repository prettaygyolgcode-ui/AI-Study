package com.aiclassroom.account;

import java.time.OffsetDateTime;
import java.util.UUID;

public record UserAccount(
    UUID id,
    String phone,
    String displayName,
    String role,
    String status,
    OffsetDateTime createdAt,
    OffsetDateTime updatedAt
) {
}
