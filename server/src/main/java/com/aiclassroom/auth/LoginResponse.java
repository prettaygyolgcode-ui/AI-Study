package com.aiclassroom.auth;

public record LoginResponse(String token, String role, String displayName) {
}
