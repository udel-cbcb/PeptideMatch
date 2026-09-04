package org.proteininformationresource.peptidematch.asyncrest.client;

import static org.junit.jupiter.api.Assertions.*;
import org.junit.jupiter.api.Test;

public class PeptideMatchAsyncRESTClientTest {

    @Test
    public void testDefaultConstructor() {
        PeptideMatchAsyncRESTClient client = new PeptideMatchAsyncRESTClient();
        assertNotNull(client);
    }

    @Test
    public void testParameterizedConstructor() {
        String serviceUrl = "http://localhost:8080/peptidematchwses/asyncrest/";
        PeptideMatchAsyncRESTClient client = new PeptideMatchAsyncRESTClient(serviceUrl);
        assertNotNull(client);
    }

    @Test
    public void testServiceUrlValidation() {
        String validUrl = "https://research.bioinformatics.udel.edu/peptidematchwses/asyncrest/";
        PeptideMatchAsyncRESTClient client = new PeptideMatchAsyncRESTClient(validUrl);
        assertNotNull(client);
    }

    @Test
    public void testLocalhostUrl() {
        String localhostUrl = "http://localhost:8080/peptidematchwses/asyncrest/";
        PeptideMatchAsyncRESTClient client = new PeptideMatchAsyncRESTClient(localhostUrl);
        assertNotNull(client);
    }
}
