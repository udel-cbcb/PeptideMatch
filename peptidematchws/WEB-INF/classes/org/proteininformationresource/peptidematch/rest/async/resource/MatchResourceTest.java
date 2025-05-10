package org.proteininformationresource.peptidematch.rest.async.resource;

import static org.junit.Assert.*;

import java.io.BufferedReader;
import java.io.ByteArrayOutputStream;
import java.io.InputStreamReader;
import java.io.PrintStream;
import java.net.URI;
import java.util.ArrayList;
import java.util.List;

import javax.ws.rs.client.Client;
import javax.ws.rs.client.ClientBuilder;
import javax.ws.rs.client.Entity;
import javax.ws.rs.core.GenericEntity;
import javax.ws.rs.core.Link;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;

import org.codehaus.jackson.map.ObjectMapper;
import org.glassfish.jersey.uri.UriComponent;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.proteininformationresource.peptidematch.asyncrest.model.Match;
import org.proteininformationresource.peptidematch.asyncrest.model.Peptide;
import org.proteininformationresource.peptidematch.asyncrest.model.Query;

public class MatchResourceTest {
	
//	private final ByteArrayOutputStream outContent = new ByteArrayOutputStream();
//	private final ByteArrayOutputStream errContent = new ByteArrayOutputStream();
//
//	@Before
//	public void setUpStreams() {
//	    System.setOut(new PrintStream(outContent));
//	    System.setErr(new PrintStream(errContent));
//	}
//
//	@After
//	public void cleanUpStreams() {
//	    System.setOut(null);
//	    System.setErr(null);
//	}
	
	@Test
	public void testReceiveQuery() throws Exception {
		Client client = ClientBuilder.newClient();
		ObjectMapper mapper = new ObjectMapper();
		List<String> peptideList = new ArrayList<String>();
		peptideList.add("ZXYYYYZ");
//		peptideList.add("GGGCALLR");
//		peptideList.add("SVQYDDVPEYK");
		Query input = new Query();
		input.setPeps(peptideList);
		input.setlEqi("Y");
		// input.setlEqi(true);
		System.out.println("Input Query: " + mapper.writeValueAsString(input));
		String asyncRESTService = "http://localhost:8080/peptidematchws/asyncrest/";
		Response response = client.target(asyncRESTService).request()
				.accept(MediaType.APPLICATION_JSON)
				.post(Entity.entity(input, MediaType.APPLICATION_JSON));
		System.out.println("POST: " + asyncRESTService + " " + response.readEntity(String.class));
		

		URI jobUri = null;
		URI reportUri = null;
		//if (response.getStatus() == 202) {
			Link jobLink = response.getLink("job");
			if (jobLink != null) {
				jobUri = jobLink.getUri();
				response = client.target(jobLink)
						.request(MediaType.APPLICATION_JSON).get();
				String result = response.readEntity(String.class);
				System.out.println("JOB: " + response.getStatus() + " " + jobLink + " | " + result);
				
				while(result == null || result.length() == 0) {
					Thread.sleep(1000);
					response = client.target(jobLink)
							.request(MediaType.APPLICATION_JSON).get();
					System.out.println(response.getStatus());
					result = response.readEntity(String.class);
				}
				System.out.println(" ??? " + result);
				//Thread.sleep(5000);
				/*
				int i = 1;
				Link reportLink = response.getLink("report");
				while (reportLink == null) {
					//System.out.println(response);
					String retry = response.getHeaderString("Retry-After");
					if (retry != null) {
						int wait = Integer.parseInt(retry);
						Thread.sleep(wait*1000);
					}
					response = client.target(jobLink)
							.request(MediaType.APPLICATION_JSON).get();
					reportLink = response.getLink("report");
					System.out.println("REPORT " + i + ": " + reportLink + " " + response.readEntity(String.class));
					i++;
				}
				System.out.println("REPORT " + i + ": " + reportLink + " " + response.readEntity(String.class));
				reportUri = reportLink.getUri();
				response = client.target(reportLink)
						.request(MediaType.APPLICATION_JSON).get();
				System.out.println(response.readEntity(String.class));*/
			}
		//}
		
	}
}
