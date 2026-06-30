package com.aiclassroom.auth;

import jakarta.validation.constraints.NotBlank;

public record LoginRequest(@NotBlank String phone, @NotBlank String code) {
}
