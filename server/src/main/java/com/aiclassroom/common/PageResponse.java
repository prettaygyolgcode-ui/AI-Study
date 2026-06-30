package com.aiclassroom.common;

import java.util.List;

public record PageResponse<T>(List<T> items, int page, int pageSize, long total) {
    public static <T> PageResponse<T> of(List<T> items) {
        return new PageResponse<>(items, 1, items.size(), items.size());
    }
}
