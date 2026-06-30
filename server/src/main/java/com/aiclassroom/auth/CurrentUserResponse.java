package com.aiclassroom.auth;

public record CurrentUserResponse(String userId, String phone, String role, String displayName) {
}
