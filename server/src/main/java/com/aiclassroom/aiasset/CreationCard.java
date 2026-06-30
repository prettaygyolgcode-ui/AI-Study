package com.aiclassroom.aiasset;

import java.util.UUID;

public record CreationCard(UUID id, String type, String name, String icon, String promptTemplate, String status) {
}
