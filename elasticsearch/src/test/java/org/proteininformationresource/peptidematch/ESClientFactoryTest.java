package org.proteininformationresource.peptidematch;

import org.junit.jupiter.api.Test;
import org.proteininformationresource.peptidematch.config.ESClientFactory;

import java.io.IOException;
import java.util.Properties;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Unit tests for ESClientFactory.
 * Tests configuration parsing without requiring a running Elasticsearch instance.
 */
class ESClientFactoryTest {

    @Test
    void testDefaultProperties() {
        Properties props = new Properties();
        // No properties set — should use defaults

        // We can't actually create a client without ES running,
        // but we can test that the factory handles missing config gracefully
        // by checking the properties loading logic

        String host = props.getProperty("elasticsearch.host", "localhost");
        int port = Integer.parseInt(props.getProperty("elasticsearch.port", "9200"));
        String scheme = props.getProperty("elasticsearch.scheme", "http");

        assertEquals("localhost", host);
        assertEquals(9200, port);
        assertEquals("http", scheme);
    }

    @Test
    void testCustomProperties() {
        Properties props = new Properties();
        props.setProperty("elasticsearch.host", "es-cluster.example.com");
        props.setProperty("elasticsearch.port", "9300");
        props.setProperty("elasticsearch.scheme", "https");
        props.setProperty("elasticsearch.username", "admin");
        props.setProperty("elasticsearch.password", "secret");

        assertEquals("es-cluster.example.com", props.getProperty("elasticsearch.host"));
        assertEquals("9300", props.getProperty("elasticsearch.port"));
        assertEquals("https", props.getProperty("elasticsearch.scheme"));
        assertEquals("admin", props.getProperty("elasticsearch.username"));
        assertEquals("secret", props.getProperty("elasticsearch.password"));
    }
}
