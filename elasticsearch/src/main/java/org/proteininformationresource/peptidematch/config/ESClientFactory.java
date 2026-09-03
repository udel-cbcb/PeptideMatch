package org.proteininformationresource.peptidematch.config;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

import co.elastic.clients.elasticsearch.ElasticsearchClient;
import co.elastic.clients.json.jackson.JacksonJsonpMapper;
import co.elastic.clients.transport.ElasticsearchTransport;
import co.elastic.clients.transport.rest_client.RestClientTransport;
import org.apache.http.HttpHost;
import org.apache.http.auth.AuthScope;
import org.apache.http.auth.UsernamePasswordCredentials;
import org.apache.http.impl.client.BasicCredentialsProvider;
import org.elasticsearch.client.RestClient;

/**
 * Factory for creating Elasticsearch clients.
 *
 * Configuration is loaded from elasticsearch.properties on the classpath.
 * Falls back to defaults (localhost:9200, no auth) if no config file is found.
 */
public class ESClientFactory {

    private static final String DEFAULT_HOST = "localhost";
    private static final int DEFAULT_PORT = 9200;
    private static final String DEFAULT_SCHEME = "http";

    /**
     * Create an Elasticsearch client from classpath configuration.
     */
    public static ElasticsearchClient createClient() throws IOException {
        Properties props = loadProperties();
        return createClient(props);
    }

    /**
     * Create an Elasticsearch client with explicit parameters.
     */
    public static ElasticsearchClient createClient(String host, int port, String scheme) throws IOException {
        RestClient restClient = RestClient.builder(
                new HttpHost(host, port, scheme)
        ).build();

        ElasticsearchTransport transport = new RestClientTransport(
                restClient, new JacksonJsonpMapper()
        );

        return new ElasticsearchClient(transport);
    }

    /**
     * Create an Elasticsearch client from properties.
     */
    public static ElasticsearchClient createClient(Properties props) throws IOException {
        String host = props.getProperty("elasticsearch.host", DEFAULT_HOST);
        int port = Integer.parseInt(props.getProperty("elasticsearch.port", String.valueOf(DEFAULT_PORT)));
        String scheme = props.getProperty("elasticsearch.scheme", DEFAULT_SCHEME);
        String username = props.getProperty("elasticsearch.username", "");
        String password = props.getProperty("elasticsearch.password", "");

        org.elasticsearch.client.RestClientBuilder restBuilder = RestClient.builder(new HttpHost(host, port, scheme));

        if (!username.isEmpty() && !password.isEmpty()) {
            BasicCredentialsProvider credsProv = new BasicCredentialsProvider();
            credsProv.setCredentials(AuthScope.ANY,
                    new UsernamePasswordCredentials(username, password));
            restBuilder.setHttpClientConfigCallback(b -> b.setDefaultCredentialsProvider(credsProv));
        }

        RestClient restClient = restBuilder.build();
        ElasticsearchTransport transport = new RestClientTransport(
                restClient, new JacksonJsonpMapper()
        );

        return new ElasticsearchClient(transport);
    }

    private static Properties loadProperties() {
        Properties props = new Properties();
        try (InputStream is = ESClientFactory.class.getClassLoader()
                .getResourceAsStream("elasticsearch.properties")) {
            if (is != null) {
                props.load(is);
            }
        } catch (IOException e) {
            // Use defaults
        }
        return props;
    }
}
