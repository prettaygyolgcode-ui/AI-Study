package com.aiclassroom.teacherworkspace;

import com.aiclassroom.courseware.Courseware;
import java.util.List;

public record TeacherWorkspaceResponse(
    List<Courseware> coursewares,
    List<ClassroomSummary> classrooms,
    List<CoursewarePlayRecord> recentPlayRecords
) {
}
