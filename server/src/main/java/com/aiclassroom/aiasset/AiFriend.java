package com.aiclassroom.aiasset;

import java.util.UUID;

public record AiFriend(UUID id, String name, String icon, String description, String rolePrompt, String status) {
}
