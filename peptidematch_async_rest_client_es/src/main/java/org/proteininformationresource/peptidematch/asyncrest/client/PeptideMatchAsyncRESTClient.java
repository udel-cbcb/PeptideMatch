package org.proteininformationresource.peptidematch.asyncrest.client;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.util.Date;

import javax.ws.rs.client.Client;
import javax.ws.rs.client.ClientBuilder;
import javax.ws.rs.client.Entity;
import javax.ws.rs.client.WebTarget;
import javax.ws.rs.core.Form;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;

public class PeptideMatchAsyncRESTClient {

    private static final String DEFAULT_SERVICE_URL = "https://research.bioinformatics.udel.edu/peptidematchwses/asyncrest/";
    private static final String DEFAULT_OUTPUT_FILE = "peptidematch_results.txt";
    private static final long POLL_INTERVAL_MS = 60000;

    private final String serviceUrl;
    private final Client client;

    public PeptideMatchAsyncRESTClient() {
        this(DEFAULT_SERVICE_URL);
    }

    public PeptideMatchAsyncRESTClient(String serviceUrl) {
        this.serviceUrl = serviceUrl;
        this.client = ClientBuilder.newClient();
    }

    public String submitJob(String peptides, String taxonIds, String leqi) {
        System.out.println(new Date() + " Submitting job to: " + serviceUrl);

        WebTarget target = client.target(serviceUrl);
        Form form = new Form();
        form.param("peps", peptides);
        if (taxonIds != null && !taxonIds.isEmpty()) {
            form.param("taxIds", taxonIds);
        }
        if (leqi != null) {
            form.param("lEQi", leqi);
        }

        Response response = target
            .request(MediaType.APPLICATION_FORM_URLENCODED)
            .post(Entity.entity(form, MediaType.APPLICATION_FORM_URLENCODED_TYPE));

        if (response.getStatus() != 202) {
            throw new RuntimeException("Failed : HTTP error code : " + response.getStatus());
        }

        String jobLink = response.getLocation().toString();
        System.out.println(new Date() + " Job created: " + jobLink);
        response.close();

        return jobLink;
    }

    public String waitForCompletion(String jobLink) throws InterruptedException {
        System.out.println(new Date() + " Waiting for job completion...");

        while (true) {
            Thread.sleep(POLL_INTERVAL_MS);

            Response response = client.target(jobLink)
                .request(MediaType.APPLICATION_JSON)
                .get();

            if (response.getLocation() == null) {
                String result = response.readEntity(String.class);
                response.close();
                System.out.println(new Date() + " Job completed");
                return result;
            }

            System.out.println(new Date() + " Job still running...");
            response.close();
        }
    }

    public String getParameters(String jobLink) {
        String paramLink = jobLink + "/parameters";
        Response response = client.target(paramLink)
            .request(MediaType.APPLICATION_JSON)
            .get();

        String params = response.readEntity(String.class);
        response.close();
        return params;
    }

    private static void writeToFile(String fileName, String content) {
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(fileName))) {
            writer.write(content);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public static void main(String[] args) {
        try {
            String serviceUrl = args.length > 0 ? args[0] : DEFAULT_SERVICE_URL;
            String peptides = args.length > 1 ? args[1] : "AAVEEGIVLGGGCALLR,STKKSVQY";
            String taxonIds = args.length > 2 ? args[2] : "9606,10090";
            String leqi = args.length > 3 ? args[3] : "on";
            String outputFile = args.length > 4 ? args[4] : DEFAULT_OUTPUT_FILE;

            PeptideMatchAsyncRESTClient client = new PeptideMatchAsyncRESTClient(serviceUrl);

            String jobLink = client.submitJob(peptides, taxonIds, leqi);

            String params = client.getParameters(jobLink);
            System.out.println("Parameters:\n" + params);

            String result = client.waitForCompletion(jobLink);

            System.out.println(new Date() + " Writing results to: " + outputFile);
            writeToFile(outputFile, result);
            System.out.println("Matches:\n" + result);

        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }
}
