package org.proteininformationresource.peptidematch.asyncrest;

import org.junit.jupiter.api.*;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Integration tests for the PeptideMatch web service.
 * Tests HTTP API endpoints against running server instances.
 *
 * Configuration via system properties:
 *   -Dws.host=localhost      (default: localhost)
 *   -Dws.port=9090           (default: 9090)
 *
 * Run with:
 *   mvn test -Dtest=MatchServiceIntegrationTest -Dws.port=9090
 *   mvn test -Dtest=MatchServiceIntegrationTest -Dws.port=9091
 */
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
class MatchServiceIntegrationTest {

    private static String baseUrl;

    @BeforeAll
    static void setUp() {
        String host = System.getProperty("ws.host", "localhost");
        String port = System.getProperty("ws.port", "9090");
        baseUrl = "http://" + host + ":" + port + "/peptidematchwses";
        System.out.println("Testing web service at: " + baseUrl);
    }

    @Test
    @Order(1)
    void testServiceAvailable() throws Exception {
        HttpURLConnection conn = (HttpURLConnection) new URL(baseUrl + "/").openConnection();
        conn.setRequestMethod("GET");
        int responseCode = conn.getResponseCode();
        assertEquals(200, responseCode, "Web service should be available");
        conn.disconnect();
    }

    @Test
    @Order(2)
    void testSubmitQuery() throws Exception {
        String postData = "peps=VWLRRCT";
        HttpURLConnection conn = (HttpURLConnection) new URL(baseUrl + "/asyncrest/").openConnection();
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
        conn.setDoOutput(true);

        try (OutputStream os = conn.getOutputStream()) {
            os.write(postData.getBytes(StandardCharsets.UTF_8));
        }

        int responseCode = conn.getResponseCode();
        assertEquals(202, responseCode, "Should return 202 Accepted");

        String location = conn.getHeaderField("Location");
        assertNotNull(location, "Location header should contain job URL");
        assertTrue(location.contains("/jobs/PM"), "Location should contain job ID");

        conn.disconnect();
    }

    @Test
    @Order(3)
    void testQueryWithIndexParam() throws Exception {
        // Test with explicit index parameter
        String postData = "peps=VWLRRCT&index=peptidematch_current";
        HttpURLConnection conn = (HttpURLConnection) new URL(baseUrl + "/asyncrest/").openConnection();
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
        conn.setDoOutput(true);

        try (OutputStream os = conn.getOutputStream()) {
            os.write(postData.getBytes(StandardCharsets.UTF_8));
        }

        int responseCode = conn.getResponseCode();
        assertEquals(202, responseCode, "Should return 202 Accepted with index param");

        String location = conn.getHeaderField("Location");
        assertNotNull(location, "Location header should contain job URL");

        conn.disconnect();
    }

    @Test
    @Order(4)
    void testQueryCompletes() throws Exception {
        // Submit query and wait for completion
        String postData = "peps=VWLRRCT";
        HttpURLConnection conn = (HttpURLConnection) new URL(baseUrl + "/asyncrest/").openConnection();
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
        conn.setDoOutput(true);

        try (OutputStream os = conn.getOutputStream()) {
            os.write(postData.getBytes(StandardCharsets.UTF_8));
        }

        String location = conn.getHeaderField("Location");
        conn.disconnect();

        // Extract job ID from location
        String jobId = location.substring(location.lastIndexOf("/") + 1);
        System.out.println("Job ID: " + jobId);

        // Poll for completion (max 120 seconds)
        String result = null;
        for (int i = 0; i < 24; i++) {
            Thread.sleep(5000);

            HttpURLConnection statusConn = (HttpURLConnection) new URL(baseUrl + "/asyncrest/jobs/" + jobId).openConnection();
            statusConn.setRequestMethod("GET");
            statusConn.setInstanceFollowRedirects(false);

            int status = statusConn.getResponseCode();
            if (status == 200) {
                // Job completed
                BufferedReader reader = new BufferedReader(new InputStreamReader(statusConn.getInputStream()));
                result = reader.readLine();
                reader.close();
                System.out.println("Result length: " + (result != null ? result.length() : 0) + " chars");
                break;
            } else if (status == 303) {
                // Still running
                System.out.println("Poll " + (i + 1) + "/24: still running...");
            }
            statusConn.disconnect();
        }

        assertNotNull(result, "Job should complete within 120 seconds");
        assertFalse(result.isEmpty(), "Result should not be empty");
        assertTrue(result.contains(","), "Result should contain comma-separated accessions");
    }

    @Test
    @Order(5)
    void testJsonOutput() throws Exception {
        String postData = "peps=VWLRRCT&format=json";
        HttpURLConnection conn = (HttpURLConnection) new URL(baseUrl + "/asyncrest/").openConnection();
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
        conn.setDoOutput(true);

        try (OutputStream os = conn.getOutputStream()) {
            os.write(postData.getBytes(StandardCharsets.UTF_8));
        }

        String location = conn.getHeaderField("Location");
        conn.disconnect();

        String jobId = location.substring(location.lastIndexOf("/") + 1);

        // Poll for completion
        String result = null;
        for (int i = 0; i < 24; i++) {
            Thread.sleep(5000);

            HttpURLConnection statusConn = (HttpURLConnection) new URL(baseUrl + "/asyncrest/jobs/" + jobId + "/json").openConnection();
            statusConn.setRequestMethod("GET");
            statusConn.setInstanceFollowRedirects(false);

            int status = statusConn.getResponseCode();
            if (status == 200) {
                BufferedReader reader = new BufferedReader(new InputStreamReader(statusConn.getInputStream()));
                StringBuilder sb = new StringBuilder();
                String line;
                while ((line = reader.readLine()) != null) {
                    sb.append(line);
                }
                reader.close();
                result = sb.toString();
                break;
            }
            statusConn.disconnect();
        }

        assertNotNull(result, "JSON job should complete");
        assertTrue(result.startsWith("["), "JSON result should start with array");
        assertTrue(result.contains("\"ac\""), "JSON should contain ac field");
    }
}
