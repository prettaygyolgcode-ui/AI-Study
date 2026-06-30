package com.aiclassroom.work;

import jakarta.validation.constraints.NotBlank;

public record CreateWorkRequest(@NotBlank String type, @NotBlank String title, @NotBlank String authorName) {
}
