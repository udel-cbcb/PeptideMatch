package org.proteininformationresource.peptidematch.asyncrest.client;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import javax.ws.rs.core.MediaType;

import org.apache.commons.httpclient.params.HttpClientParams;
import org.codehaus.jackson.JsonParseException;
import org.codehaus.jackson.map.JsonMappingException;
import org.codehaus.jackson.map.ObjectMapper;
import org.codehaus.jackson.type.TypeReference;
import org.proteininformationresource.peptidematch.asyncrest.model.Match;
import org.proteininformationresource.peptidematch.asyncrest.model.Query;

import com.sun.jersey.api.client.Client;
import com.sun.jersey.api.client.ClientResponse;
import com.sun.jersey.api.client.WebResource;
import com.sun.jersey.api.representation.Form;
import com.sun.jersey.client.apache.ApacheHttpClient;
import com.sun.jersey.client.apache.config.ApacheHttpClientConfig;
import com.sun.jersey.client.apache.config.DefaultApacheHttpClientConfig;

public class PeptideMatchAsyncRESTClient {
	public static void main(String[] args) {
		try {

			Client client = Client.create();
			client.setFollowRedirects(false);
			
			//System.setProperty("javax.net.debug", "all");
			//System.setProperty("https.protocols", "SSLv3,TLSv1,TLSv1.1,TLSv1.2");
			
			//System.setProperty("javax.net.ssl.trustStore","/Library/Java/JavaVirtualMachines/jdk1.8.0_45.jdk/Contents/Home/jre/lib/security/cacerts");
			// ApacheHttpClientConfig config = new
			// DefaultApacheHttpClientConfig();
			// config.getProperties().put(ApacheHttpClientConfig.PROPERTY_HANDLE_COOKIES,
			// true);
			// ApacheHttpClient client = ApacheHttpClient.create( config );
			// client.setFollowRedirects(false);
			// client.getClientHandler().getHttpClient().getParams().setBooleanParameter(
			// HttpClientParams.ALLOW_CIRCULAR_REDIRECTS, true );

			//ssh -N -p 22 histidine -L 8080/localhost/8181
			WebResource webResource = client
			// .resource("http://localhost:8080/peptidematchws/asyncrest/");
			//.resource("https://peptidesearch.uniprot.org/asyncrest/");
			//.resource("http://ibm-cloud1.proteininformationresource.org/peptidematchws/asyncrest/");
			.resource("https://research.bioinformatics.udel.edu/peptidematchws/asyncrest/");
			//.resource("http://peptidesearch.uniprot.org:8181/peptidematchws_dev/");
			//		.resource("http://ec2-18-208-33-184.compute-1.amazonaws.com/asyncrest/");
			
			// String input =
			// "{\"singer\":\"Metallica\",\"title\":\"Fade To Black\"}";

			Form form = new Form();
			//form.add("peps", "STKKSVQY,AAVEEGIVLGGGCALLR,DPLGVFHDALNNVKPNIEVR,DQQPASFDPNTK,DQSTLQYTTVINQR");
			//form.add("peps", "EPPF");
			//form.add("peps", "INFD");
			//form.add("peps", "AAA");
			//form.add("peps", "AAVEEGIVLGGGCALLR");
			form.add("peps", "AAVEEGIVLGGGCALLR,STKKSVQY");
			//form.add("peps", "CCCCCC");
			//form.add("taxIds", "9606");
			form.add("taxIds", "9606,10090");
			form.add("lEQi", "on");
			form.add("spOnly", "on");
			ClientResponse response = webResource.type(MediaType.APPLICATION_FORM_URLENCODED_TYPE).post(ClientResponse.class, form);
			System.out.println(new Date() + " 1 " + webResource);

			// System.out.println("??????");

			if (response.getStatus() != 202) {
				throw new RuntimeException("Failed : HTTP error code : " + response.getStatus());
			}

			// System.out.println("Output from Server .... \n");
			// String output = response.getEntity(String.class);
			// System.out.println(output);
			// Thread.sleep(30000);
			String result = "";
			System.out.println(response.getLocation());
			String jobLink = response.getLocation().toString().replace("/peptidematchws/", "/peptidematchws/");
			//String jobLink = response.getLocation().toString();
			System.out.println(new Date() + " 2 " + jobLink);
			Thread.sleep(60000);
			
			String paramLink = jobLink+"/parameters";
			webResource = client.resource(paramLink);
			System.out.println(new Date() + " param " + webResource);
			response = webResource.get(ClientResponse.class);
			String params = response.getEntity(String.class);
			System.out.println("Parameters:\n"+params);
			
			if (jobLink != null) {

				webResource = client.resource(jobLink);
				System.out.println(new Date() + " 3 " + webResource);
				response = webResource.get(ClientResponse.class);
				

				while (response.getLocation() != null) {

					Thread.sleep(60000);
					webResource = client.resource(jobLink);
					System.out.println(new Date() + " 4 " + webResource);
					// System.out.println(webResource);
					response = webResource.get(ClientResponse.class);

				}
				webResource = client.resource(jobLink);
				System.out.println(new Date() + " 5 " + webResource);

				response = webResource.get(ClientResponse.class);
				result = response.getEntity(String.class);
			}
			System.out.println(new Date() + " Writing results ...");
			writeToFile("/Users/chenc/Documents/2016/Work/PeptideMatch/asyncrest/test.txt", result);
			System.out.println("Matches: \n" + result);
			System.out.println(new Date() + " Writing results ... done");
			

			response.close();

		} catch (InterruptedException e) {
			e.printStackTrace();

		}

	}

	private static void writeToFile(String fileName, String content) {
		BufferedWriter writer = null;
		try {
			writer = new BufferedWriter(new FileWriter(fileName));
			writer.write(content);

		} catch (IOException e) {
		} finally {
			try {
				if (writer != null)
					writer.close();
			} catch (IOException e) {
			}
		}

	}
}

/*
 * public static void main(String[] args) { Client client =
 * ClientBuilder.newClient(); ObjectMapper mapper = new ObjectMapper();
 * List<String> peptideList = new ArrayList<String>();
 * peptideList.add("STKKSVQY"); peptideList.add("SVQYDDVPEYK"); Query input =
 * new Query(); input.setPeps(peptideList); input.setlEqi("Y");
 * 
 * 
 * 
 * 
 * //String asyncRESTService =
 * "http://localhost:8080/peptidematchws/asyncrest/"; String asyncRESTService =
 * "http://research.bioinformatics.udel.edu/peptidematchws/asyncrest";
 * 
 * Response response = client.target(asyncRESTService).request()
 * .accept(MediaType.APPLICATION_JSON) .post(Entity.entity(input,
 * MediaType.APPLICATION_JSON)); System.out.println("POST: " + asyncRESTService
 * + "\n" + input);
 * 
 * String jobLink = response.getLocation().toString(); if (jobLink != null) {
 * response = client.target(jobLink) .request(MediaType.APPLICATION_JSON).get();
 * String result = response.readEntity(String.class);
 * 
 * while (result == null || result.length() == 0) { try { Thread.sleep(30000); }
 * catch (InterruptedException e) { e.printStackTrace(); } response =
 * client.target(jobLink) .request(MediaType.APPLICATION_JSON).get(); result =
 * response.readEntity(String.class); }
 * 
 * try { List<Match> matchList = mapper.readValue(result, new
 * TypeReference<List<Match>>() {}); System.out.println("Report: \n" +
 * matchList); } catch (JsonParseException e) { e.printStackTrace(); } catch
 * (JsonMappingException e) { e.printStackTrace(); } catch (IOException e) {
 * e.printStackTrace(); } } }
 */

