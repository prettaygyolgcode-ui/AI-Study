package com.aiclassroom.common;

import java.util.List;

public final class DatabasePage {
    private DatabasePage() {
    }

    public static <T> PageResponse<T> of(List<T> items) {
        return PageResponse.of(items);
    }
}
