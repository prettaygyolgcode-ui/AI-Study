package com.aiclassroom.work;

import java.util.UUID;

public record Work(
    UUID id,
    String type,
    String title,
    String authorName,
    String status,
    boolean published,
    boolean recommended,
    int likeCount,
    double score
) {
}
