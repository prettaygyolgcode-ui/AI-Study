package com.aiclassroom.file;

import com.aiclassroom.common.ApiResponse;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.UUID;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/v1/admin/files")
public class FileController {
    private final Path uploadDir;

    public FileController(@Value("${app.upload-dir}") String uploadDir) {
        this.uploadDir = Path.of(uploadDir);
    }

    @PostMapping("/upload")
    public ApiResponse<UploadedFileResponse> upload(@RequestParam("file") MultipartFile file) throws IOException {
        Files.createDirectories(uploadDir);
        var safeName = UUID.randomUUID() + "-" + file.getOriginalFilename();
        var target = uploadDir.resolve(safeName);
        file.transferTo(target);
        return ApiResponse.ok(new UploadedFileResponse(file.getOriginalFilename(), "/uploads/" + safeName, file.getSize()));
    }
}
