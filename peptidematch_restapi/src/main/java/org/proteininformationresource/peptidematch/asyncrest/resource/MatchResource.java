package org.proteininformationresource.peptidematch.asyncrest.resource;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.net.URI;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Properties;
import java.util.UUID;
import java.util.concurrent.Executors;
import java.util.concurrent.ThreadPoolExecutor;


import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import javax.ws.rs.Consumes;
import javax.ws.rs.FormParam;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.GenericEntity;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.UriBuilder;
import javax.ws.rs.core.UriInfo;

import org.apache.log4j.Logger;
import org.codehaus.jackson.JsonParseException;
import org.codehaus.jackson.map.JsonMappingException;
import org.codehaus.jackson.map.ObjectMapper;
import org.proteininformationresource.peptidematch.asyncrest.model.Job;
import org.proteininformationresource.peptidematch.asyncrest.model.Log;
import org.proteininformationresource.peptidematch.asyncrest.model.Match;
import org.proteininformationresource.peptidematch.asyncrest.model.Query;
import org.proteininformationresource.peptidematch.asyncrest.model.Report;
import org.proteininformationresource.peptidematch.asyncrest.service.MatchService;

@Path("/")
//@Consumes(MediaType.APPLICATION_JSON)
//@Produces(MediaType.APPLICATION_JSON)
public class MatchResource {
	static Logger logger = Logger.getLogger(MatchResource.class);

	public MatchResource() {
		super();
		// TODO Auto-generated constructor stub
	}

	@POST
	@Consumes(MediaType.APPLICATION_FORM_URLENCODED)
	public Response postQuery(@Context HttpServletRequest request,
			@Context UriInfo uriInfo, 
			@FormParam("peps") String peps, 
			@FormParam("taxIds") String taxIds, 
			@FormParam("lEQi") String lEQi,
			@FormParam("spOnly") String spOnly) {
		logger.info("POST query received: " + peps + " " + taxIds + " " + lEQi + " "+ spOnly);
		List<String> queryPeptides = new ArrayList<String>();
		List<Integer> queryTaxonIds = new ArrayList<Integer>();
		String equiv = "N";
		String swissProtOnly = "N";
		
		if(peps != null && peps.length() > 0) {
			String[] pepList = peps.split("\n");
			for(int i = 0; i < pepList.length; i++) {
				String pep = pepList[i].trim();
				String[] commaSeparatedPeps = pep.split(",");
				for(int j = 0; j < commaSeparatedPeps.length; j++) {
					queryPeptides.add(commaSeparatedPeps[j].trim());
				}
			}
		}
		
		if(taxIds != null && taxIds.length() > 0) {
			String[] taxIdList = taxIds.split("\n");
			for(int i = 0; i < taxIdList.length; i++) {
				String tax = taxIdList[i].trim();
				String[] commaSeparatedTaxIds = tax.split(",");
				for(int j = 0; j < commaSeparatedTaxIds.length; j++) {
					queryTaxonIds.add(Integer.parseInt(commaSeparatedTaxIds[j].trim()));
				}
			}
		}
		
		if(lEQi != null && (lEQi.toUpperCase().equals("ON") || lEQi.toUpperCase().equals("Y"))) {
			equiv = "Y";
		}
		else {
			equiv = "N";
		}
		
		if(spOnly != null && (spOnly.toUpperCase().equals("ON") || spOnly.toUpperCase().equals("Y"))) {
			swissProtOnly = "Y";
		}
		else {
			swissProtOnly = "N";
		}
//		System.out.println("|"+peps+"| " + queryPeptides);
//		System.out.println("|"+taxIds+"| " + queryTaxonIds);
//		System.out.println("|"+lEQi+"| " + equiv );
//		System.out.println("|"+swissProtOnly+"| " + swissProtOnly );
		
		Query query = new Query(queryPeptides, queryTaxonIds, equiv, swissProtOnly);
		
//		System.out.println("|"+peps+"| " + query.getPeps());
//		System.out.println("|"+taxIds+"| " + query.getTaxIds());
//		System.out.println("|"+lEQi+"| " + query.getlEqi() );
//		System.out.println("|"+swissProtOnly+"| " + query.getSwissProtOnly() );
		Job job = createJob(request);
		URI jobUri = UriBuilder.fromUri(uriInfo.getBaseUri()).path("jobs")
				.path(job.getJobId()).build();
//		URI jobUri = UriBuilder.fromUri(uriInfo.getBaseUriBuilder().scheme("https").host("{hostname}").build()).path("jobs")
//				.path(job.getJobId()).build();
		System.out.println("baseUri: " + uriInfo.getBaseUri());
		System.out.println("baseUriBuilder: " + uriInfo.getBaseUriBuilder());
		System.out.println("jobUri: " + jobUri);
		Response response = Response.accepted().location(jobUri).build();
		System.out.println("response: "+ response.getLocation().toString());
		Properties prop = getProperties();

		ThreadPoolExecutor executor = (ThreadPoolExecutor) Executors
				.newCachedThreadPool();
		MatchService matchService = new MatchService(query, job, prop);
		executor.execute(matchService);
		executor.shutdown();
		return response;
	}

	@GET
	@Path("/jobs/{jobId}")
	public Response getJobStatus(@PathParam("jobId") String jobId,
			@Context UriInfo uriInfo) {
		Properties prop = getProperties();
		//String cwd = prop.getProperty("workdir") + File.separator + jobId;
		String workDir = prop.getProperty("workdir");
		String cwd = workDir + File.separator + jobId.substring(2, 10);
		String logFile = cwd + File.separator + jobId+ File.separator+ "log.json";
		
		String reportFile = cwd + File.separator + jobId + File.separator + "report.txt";
		String reportJsonFile = cwd + File.separator + jobId + File.separator + "report.json";
		ObjectMapper mapper = new ObjectMapper();
		Job job = null;

		File f = new File(logFile);
		if (f.exists()) {
			try {
				job = mapper.readValue(new File(logFile), Job.class);
			} catch (JsonParseException e) {
				e.printStackTrace();
			} catch (JsonMappingException e) {
				e.printStackTrace();
			} catch (IOException e) {
				e.printStackTrace();
			}
			
			if (!job.getStatus().equals("Finished")) {
				System.out.println(new Date() + " running " + job.getJobId() + " " + job.getStatus());
				URI jobUri = UriBuilder.fromUri(uriInfo.getBaseUri()).path("jobs")
						.path(jobId).build();
				Response response = Response.seeOther(jobUri)//.link(jobUri, "job")
						.header("Retry-After", 30).build();
				return response;
			} else {
				//Report report = null;
				String result = "";
				f = new File(reportFile);
				if (f.exists()) {
					try {
						//report = mapper.readValue(new File(reportFile), Report.class);
						result = new String(Files.readAllBytes(Paths.get(reportFile)));
					} catch (JsonParseException e) {
						e.printStackTrace();
					} catch (JsonMappingException e) {
						e.printStackTrace();
					} catch (org.apache.catalina.connector.ClientAbortException ca) {
					    System.out.println("ClientAbortException caught");
					} catch (IOException e) {
						e.printStackTrace();
					}

					Response response = Response.ok(result).build();

					return response;
				}
				else {
					logger.error(reportFile + " does not exist");
					Response response = Response.status(404).build();
					return response;
				}
			}

		}
		else {
			logger.error(logFile + " does not exist");
			URI jobUri = UriBuilder.fromUri(uriInfo.getBaseUri()).path("jobs")
					.path(jobId).build();
			Response response = Response.seeOther(jobUri)//.link(jobUri, "job")
					.header("Retry-After", 30).build();
			return response;
		}
		
	}

	@GET
	@Path("/jobs/{jobId}/parameters")
	public Response getJobParameters(@PathParam("jobId") String jobId,
			@Context UriInfo uriInfo) {
		Properties prop = getProperties();
		//String cwd = prop.getProperty("workdir") + File.separator + jobId;
		String workDir = prop.getProperty("workdir");
		String cwd = workDir + File.separator + jobId.substring(2, 10);
		String logFile = cwd + File.separator + jobId+ File.separator+ "log.json";
		
		ObjectMapper mapper = new ObjectMapper();
		Job job = null;

		File f = new File(logFile);
		if (f.exists()) {
			try {
				job = mapper.readValue(new File(logFile), Job.class);
			} catch (JsonParseException e) {
				e.printStackTrace();
			} catch (JsonMappingException e) {
				e.printStackTrace();
			} catch (IOException e) {
				e.printStackTrace();
			}
			
			String parameters = "";
			parameters +="QueryPetides:"+ job.getQueryPeptides().toString().replace("[", "")
	                  .replace("]", "")
	                  .replace(" ", "")+"\n";
			parameters += "TaxonIds:"+ job.getTaxonIds().replace(";", ",")+"\n";
			parameters += "lEqi:"+ job.getlEqi()+"\n";
			parameters += "swissProtOnly:"+ job.getSwissProtOnly();
			
			Response response = Response.ok(parameters).build();

			return response;
			
		}
		else {
			logger.error(logFile + " does not exist");
			URI jobUri = UriBuilder.fromUri(uriInfo.getBaseUri()).path("jobs")
					.path(jobId).build();
			Response response = Response.seeOther(jobUri)//.link(jobUri, "job")
					.header("Retry-After", 30).build();
			return response;
		}
		
	}

	@GET
	@Path("/reports/{jobId}")
	public Response getReport(@PathParam("jobId") String jobId,
			@Context UriInfo uriInfo) {

		Properties prop = getProperties();
		String workDir = prop.getProperty("workdir");
		String cwd = workDir + File.separator + jobId.substring(2, 9);
		String reportFile = cwd + File.separator + jobId + File.separator + "report.json";
		ObjectMapper mapper = new ObjectMapper();
		Report report = null;
		File f = new File(reportFile);
		if (f.exists()) {
			try {
				report = mapper.readValue(new File(reportFile), Report.class);
			} catch (JsonParseException e) {
				e.printStackTrace();
			} catch (JsonMappingException e) {
				e.printStackTrace();
			} catch (IOException e) {
				e.printStackTrace();
			}

			GenericEntity<List<Match>> entity = new GenericEntity<List<Match>>(
					report.getMatchList()) {
			};
			Response response = Response.ok(entity).build();

			return response;
		}
		else {
			logger.error(reportFile + " does not exist");
			Response response = Response.status(404).build();
			return response;
		}
	}

	private Job createJob(HttpServletRequest request) {
		HttpSession session = request.getSession(true);
		//UUID uid = UUID.fromString("38400000-8cf0-11bd-b23e-10b96e4ef00d");  
		Date jobStart = new Date();
		String date = new SimpleDateFormat("yyyyMMdd").format(jobStart);
		Job job = new Job();
		//job.setJobId("PM" + date + session.getId());
		job.setJobId("PM" + date + UUID.randomUUID().toString().replaceAll("-", ""));
		job.setStartTime(new SimpleDateFormat("yyyy-MM-dd hh:mm:ss")
				.format(jobStart));
		job.setStatus("Started");
		job.setEndTime("");
		job.setJobLogs(new ArrayList<Log>());

		return job;
	}

	private Properties getProperties() {
		InputStream inputStream;
		Properties prop = null;
		try {
			prop = new Properties();
			String propFileName = "config.properties";

			inputStream = getClass().getClassLoader().getResourceAsStream(
					propFileName);

			if (inputStream != null) {
				prop.load(inputStream);

			} else {
				throw new FileNotFoundException("property file '"
						+ propFileName + "' not found in the classpath");
			}
			inputStream.close();
		} catch (Exception e) {
			e.printStackTrace();
		}
		return prop;
	}
}
