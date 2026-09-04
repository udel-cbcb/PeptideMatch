package org.proteininformationresource.peptidematch.asyncrest.model;

import static org.junit.jupiter.api.Assertions.*;
import org.junit.jupiter.api.Test;
import java.util.Arrays;
import java.util.List;

public class JobTest {

    @Test
    public void testDefaultConstructor() {
        Job job = new Job();
        assertNotNull(job);
    }

    @Test
    public void testParameterizedConstructor() {
        String jobId = "PM20260903abc123";
        String startTime = "2026-09-03 10:00:00";
        String endTime = "2026-09-03 10:05:00";
        long duration = 300;
        String status = "Finished";
        List<Log> logs = Arrays.asList(new Log());

        Job job = new Job(jobId, startTime, endTime, duration, status, logs);

        assertEquals(jobId, job.getJobId());
        assertEquals(startTime, job.getStartTime());
        assertEquals(endTime, job.getEndTime());
        assertEquals(duration, job.getDurationInSeconds());
        assertEquals(status, job.getStatus());
        assertEquals(logs, job.getJobLogs());
    }

    @Test
    public void testSettersAndGetters() {
        Job job = new Job();

        job.setJobId("PM123");
        assertEquals("PM123", job.getJobId());

        job.setStartTime("2026-09-03 10:00:00");
        assertEquals("2026-09-03 10:00:00", job.getStartTime());

        job.setEndTime("2026-09-03 10:05:00");
        assertEquals("2026-09-03 10:05:00", job.getEndTime());

        job.setDurationInSeconds(300);
        assertEquals(300, job.getDurationInSeconds());

        job.setStatus("Searching ...");
        assertEquals("Searching ...", job.getStatus());

        List<Log> logs = Arrays.asList(new Log());
        job.setJobLogs(logs);
        assertEquals(logs, job.getJobLogs());
    }

    @Test
    public void testStatusTransitions() {
        Job job = new Job();
        job.setStatus("Started");
        assertEquals("Started", job.getStatus());

        job.setStatus("Searching ...");
        assertEquals("Searching ...", job.getStatus());

        job.setStatus("Finished");
        assertEquals("Finished", job.getStatus());
    }
}
