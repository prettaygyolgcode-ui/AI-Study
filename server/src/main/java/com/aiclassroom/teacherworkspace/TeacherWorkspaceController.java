package com.aiclassroom.teacherworkspace;

import com.aiclassroom.common.ApiResponse;
import com.aiclassroom.common.DatabasePage;
import com.aiclassroom.common.PageResponse;
import com.aiclassroom.courseware.CoursewareController;
import jakarta.validation.Valid;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.UUID;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class TeacherWorkspaceController {
    private final JdbcTemplate jdbcTemplate;

    public TeacherWorkspaceController(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @GetMapping("/api/v1/teacher/workspace")
    public ApiResponse<TeacherWorkspaceResponse> workspace() {
        var coursewares = jdbcTemplate.query(
            """
            select id, title, age_band, category, status, original_file_url, converted_asset_url,
                   conversion_status, duration_minutes, created_at, updated_at
            from coursewares
            where status = 'PUBLISHED'
            order by age_band asc, category asc, updated_at desc
            """,
            CoursewareController::mapCourseware
        );
        return ApiResponse.ok(new TeacherWorkspaceResponse(coursewares, listClassrooms().items(), recentPlayRecords().items()));
    }

    @GetMapping("/api/v1/admin/classrooms")
    public ApiResponse<PageResponse<ClassroomSummary>> classrooms() {
        return ApiResponse.ok(listClassrooms());
    }

    @PostMapping("/api/v1/admin/classrooms")
    public ApiResponse<ClassroomSummary> createClassroom(@Valid @RequestBody CreateClassroomRequest request) {
        var id = UUID.randomUUID();
        jdbcTemplate.update(
            """
            insert into classrooms (id, organization_id, teacher_id, name, age_band, status, created_at)
            values (?, ?, ?, ?, ?, 'ACTIVE', now())
            """,
            id,
            request.organizationId(),
            request.teacherId(),
            request.name(),
            request.ageBand()
        );
        writeAudit("CLASSROOM_CREATED", "classroom", id);
        return ApiResponse.ok(findClassroom(id));
    }

    @PostMapping("/api/v1/admin/classrooms/{id}/students")
    public ApiResponse<StudentBinding> bindStudent(@PathVariable UUID id, @Valid @RequestBody BindStudentRequest request) {
        var parentUserId = UUID.randomUUID();
        jdbcTemplate.update(
            """
            insert into users (id, phone, display_name, role, status, created_at, updated_at)
            values (?, ?, '家长用户', 'PARENT', 'ACTIVE', now(), now())
            on conflict (phone) do update set role = 'PARENT', status = 'ACTIVE', updated_at = now()
            """,
            parentUserId,
            request.parentPhone()
        );
        var actualParentUserId = jdbcTemplate.queryForObject("select id from users where phone = ?", UUID.class, request.parentPhone());
        var studentId = UUID.randomUUID();
        jdbcTemplate.update(
            """
            insert into students (id, parent_user_id, nickname, age_band, created_at)
            values (?, ?, ?, ?, now())
            """,
            studentId,
            actualParentUserId,
            request.nickname(),
            request.ageBand()
        );
        jdbcTemplate.update(
            """
            insert into classroom_students (classroom_id, student_id, parent_phone, bind_status)
            values (?, ?, ?, 'ACTIVE')
            """,
            id,
            studentId,
            request.parentPhone()
        );
        writeAudit("STUDENT_BOUND", "classroom", id);
        return ApiResponse.ok(new StudentBinding(studentId, id, request.parentPhone(), request.nickname(), "ACTIVE"));
    }

    @GetMapping("/api/v1/admin/courseware-play-records")
    public ApiResponse<PageResponse<CoursewarePlayRecord>> playRecords() {
        return ApiResponse.ok(recentPlayRecords());
    }

    @PostMapping("/api/v1/admin/courseware-play-records")
    public ApiResponse<CoursewarePlayRecord> createPlayRecord(@Valid @RequestBody CreatePlayRecordRequest request) {
        var id = UUID.randomUUID();
        jdbcTemplate.update(
            """
            insert into courseware_play_records
              (id, courseware_id, teacher_id, classroom_id, played_seconds, progress_percent, started_at, ended_at)
            values (?, ?, ?, ?, ?, ?, now(), now())
            """,
            id,
            request.coursewareId(),
            request.teacherId(),
            request.classroomId(),
            request.playedSeconds() == null ? 0 : request.playedSeconds(),
            request.progressPercent() == null ? 0 : request.progressPercent()
        );
        writeAudit("COURSEWARE_PLAYED", "courseware", request.coursewareId());
        return ApiResponse.ok(findPlayRecord(id));
    }

    private PageResponse<ClassroomSummary> listClassrooms() {
        var classrooms = jdbcTemplate.query(
            """
            select c.id, c.name, c.age_band, c.status, count(cs.student_id)::int as student_count
            from classrooms c
            left join classroom_students cs on cs.classroom_id = c.id and cs.bind_status = 'ACTIVE'
            group by c.id, c.name, c.age_band, c.status, c.created_at
            order by c.created_at desc
            """,
            TeacherWorkspaceController::mapClassroom
        );
        return DatabasePage.of(classrooms);
    }

    private PageResponse<CoursewarePlayRecord> recentPlayRecords() {
        var records = jdbcTemplate.query(
            """
            select r.id, r.courseware_id, coalesce(cw.title, '') as courseware_title,
                   r.classroom_id, coalesce(cl.name, '') as classroom_name,
                   r.played_seconds, r.progress_percent, r.started_at
            from courseware_play_records r
            left join coursewares cw on cw.id = r.courseware_id
            left join classrooms cl on cl.id = r.classroom_id
            order by r.started_at desc
            limit 50
            """,
            TeacherWorkspaceController::mapPlayRecord
        );
        return DatabasePage.of(records);
    }

    private ClassroomSummary findClassroom(UUID id) {
        var classrooms = jdbcTemplate.query(
            """
            select c.id, c.name, c.age_band, c.status, count(cs.student_id)::int as student_count
            from classrooms c
            left join classroom_students cs on cs.classroom_id = c.id and cs.bind_status = 'ACTIVE'
            where c.id = ?
            group by c.id, c.name, c.age_band, c.status, c.created_at
            """,
            TeacherWorkspaceController::mapClassroom,
            id
        );
        if (classrooms.isEmpty()) {
            throw new IllegalArgumentException("班级不存在");
        }
        return classrooms.get(0);
    }

    private CoursewarePlayRecord findPlayRecord(UUID id) {
        var records = jdbcTemplate.query(
            """
            select r.id, r.courseware_id, coalesce(cw.title, '') as courseware_title,
                   r.classroom_id, coalesce(cl.name, '') as classroom_name,
                   r.played_seconds, r.progress_percent, r.started_at
            from courseware_play_records r
            left join coursewares cw on cw.id = r.courseware_id
            left join classrooms cl on cl.id = r.classroom_id
            where r.id = ?
            """,
            TeacherWorkspaceController::mapPlayRecord,
            id
        );
        if (records.isEmpty()) {
            throw new IllegalArgumentException("播放记录不存在");
        }
        return records.get(0);
    }

    private void writeAudit(String action, String targetType, UUID targetId) {
        jdbcTemplate.update(
            """
            insert into audit_logs (id, actor_user_id, action, target_type, target_id, metadata, created_at)
            values (?, null, ?, ?, ?, '{}'::jsonb, now())
            """,
            UUID.randomUUID(),
            action,
            targetType,
            targetId
        );
    }

    private static ClassroomSummary mapClassroom(ResultSet rs, int rowNum) throws SQLException {
        return new ClassroomSummary(
            rs.getObject("id", UUID.class),
            rs.getString("name"),
            rs.getString("age_band"),
            rs.getString("status"),
            rs.getInt("student_count")
        );
    }

    private static CoursewarePlayRecord mapPlayRecord(ResultSet rs, int rowNum) throws SQLException {
        return new CoursewarePlayRecord(
            rs.getObject("id", UUID.class),
            rs.getObject("courseware_id", UUID.class),
            rs.getString("courseware_title"),
            rs.getObject("classroom_id", UUID.class),
            rs.getString("classroom_name"),
            rs.getInt("played_seconds"),
            rs.getInt("progress_percent"),
            rs.getObject("started_at", java.time.OffsetDateTime.class)
        );
    }
}
