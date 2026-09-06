package org.proteininformationresource.peptidematch.asyncrest.service;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.TreeMap;

import co.elastic.clients.elasticsearch._types.FieldValue;
import co.elastic.clients.elasticsearch.ElasticsearchClient;
import org.proteininformationresource.peptidematch.config.ESClientFactory;
import org.proteininformationresource.peptidematch.search.ESSearchService;
import org.proteininformationresource.peptidematch.asyncrest.model.Job;
import org.proteininformationresource.peptidematch.asyncrest.model.Log;
import org.proteininformationresource.peptidematch.asyncrest.model.Match;
import org.proteininformationresource.peptidematch.asyncrest.model.Query;
import org.proteininformationresource.peptidematch.asyncrest.model.Report;

import com.fasterxml.jackson.core.JsonGenerationException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.ObjectMapper;

public class MatchService implements Runnable {
	private Query query;
	private Job job;
	private Properties configuration;
	private static ESSearchService searchService;

	static {
		try {
			ElasticsearchClient client = ESClientFactory.createClient();
			searchService = new ESSearchService(client);
		} catch (Exception e) {
			throw new RuntimeException("Failed to initialize ES client", e);
		}
	}

	public MatchService() {
		super();
	}

	public MatchService(Query query, Job job, Properties configuration) {
		super();
		this.query = query;
		this.job = job;
		this.configuration = configuration;
	}

	public Query getQuery() {
		return query;
	}

	public void setQuery(Query query) {
		this.query = query;
	}

	public Job getJob() {
		return job;
	}

	public void setJob(Job job) {
		this.job = job;
	}

	public Properties getConfiguration() {
		return configuration;
	}

	public void setConfiguration(Properties configuration) {
		this.configuration = configuration;
	}

	@Override
	public void run() {
		try {
			String workDir = this.configuration.getProperty("workdir");
			String cwd = workDir + File.separator + job.getJobId().substring(2, 10) + File.separator + job.getJobId();
			new File(cwd).mkdirs();
			ObjectMapper mapper = new ObjectMapper();
			String logFile = cwd + File.separator + "log.json";
			writeToFile(logFile, mapper.writeValueAsString(job));

			List<String> queryPeptides = query.getPeps();
			job.setStatus("Searching ...");
			writeToFile(logFile, mapper.writeValueAsString(job));

			String taxonIds = "";
			if (query.getTaxIds() != null && query.getTaxIds().size() > 0) {
				for (Integer tax : query.getTaxIds()) {
					if (taxonIds.isEmpty()) {
						taxonIds += tax;
					} else {
						taxonIds += "," + tax;
					}
				}
			}

			String reportFile = cwd + File.separator + "report.txt";
			String reportJsonFile = cwd + File.separator + "report.json";
			java.util.TreeSet<String> uniqueACs = new java.util.TreeSet<>();
			boolean writeJson = "json".equals(query.getFormat());
			java.util.TreeMap<String, Map<String, Object>> jsonHits = writeJson ? new java.util.TreeMap<>() : null;

			for (int i = 0; i < queryPeptides.size(); i++) {
				String queryPeptide = queryPeptides.get(i);
				Date start = new Date();
				addSearchTaskStartLog(i, queryPeptides.size(), queryPeptide, start, taxonIds, query.getlEqi());
				doSearchStreaming(queryPeptide, taxonIds, query.getSwissprot(), query.getIsoform(), query.getlEqi(), uniqueACs, jsonHits);
				Date end = new Date();
				addSearchTaskEndLog(i, queryPeptides.size(), queryPeptide, start, end, taxonIds, query.getlEqi());
			}

			System.out.println(new Date() + " " + job.getJobId() + " writing " + uniqueACs.size() + " accessions to file ...");

			try (BufferedWriter writer = new BufferedWriter(new FileWriter(reportFile))) {
				boolean first = true;
				int count = 0;
				for (String ac : uniqueACs) {
					if (!first) {
						writer.write(',');
					}
					writer.write(ac);
					first = false;
					count++;
					if (count % 1000000 == 0) {
						writer.flush();
						System.out.println("  " + count + " written");
					}
				}
			}

			if (writeJson && jsonHits != null) {
				System.out.println(new Date() + " " + job.getJobId() + " writing JSON report ...");
				java.util.List<Map<String, Object>> jsonList = new java.util.ArrayList<>(jsonHits.values());
				writeToFile(reportJsonFile, mapper.writeValueAsString(jsonList));
				System.out.println(new Date() + " " + job.getJobId() + " writing JSON done");
			}

			System.out.println(new Date() + " " + job.getJobId() + " writing done");

			Date jobEnd = new Date();
			Date jobStart = new SimpleDateFormat("yyyy-MM-dd hh:mm:ss").parse(job.getStartTime());
			job.setEndTime(new SimpleDateFormat("yyyy-MM-dd hh:mm:ss").format(jobEnd));
			long diff = jobEnd.getTime() - jobStart.getTime();
			long diffSeconds = diff / 1000 % 60;
			job.setDurationInSeconds(diffSeconds);
			job.setStatus("Finished");
			writeToFile(logFile, mapper.writeValueAsString(job));

		} catch (JsonGenerationException e) {
			e.printStackTrace();
		} catch (JsonMappingException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		} catch (ParseException e) {
			e.printStackTrace();
		}
	}

	private void addSearchTaskEndLog(int index, int total, String queryPeptide, Date start, Date end, String taxonIds, String lEQi) {
		Log log = new Log();
		log.setTaskName((index + 1) + "/" + total);
		log.setTaxonIds(taxonIds);
		log.setlEQi(lEQi);
		log.setPeptideSearched(queryPeptide);
		log.setStartTime(new SimpleDateFormat("yyyy-MM-dd hh:mm:ss").format(start));
		log.setEndTime(new SimpleDateFormat("yyyy-MM-dd hh:mm:ss").format(end));
		long diff = end.getTime() - start.getTime();
		log.setDurationInMilliseconds(diff);

		if (job.getJobLogs() != null) {
			int logIndex = job.getJobLogs().size() - 1;
			job.getJobLogs().set(logIndex, log);
		} else {
			List<Log> logs = new ArrayList<Log>();
			job.setJobLogs(logs);
		}
	}

	private void addSearchTaskStartLog(int index, int total, String queryPeptide, Date start, String taxonIds, String lEQi) {
		Log log = new Log();
		log.setTaskName((index + 1) + "/" + total);
		log.setPeptideSearched(queryPeptide);
		log.setTaxonIds(taxonIds);
		log.setlEQi(lEQi);
		log.setStartTime(new SimpleDateFormat("yyyy-MM-dd hh:mm:ss").format(start));
		if (job.getJobLogs() != null) {
			job.getJobLogs().add(log);
		} else {
			List<Log> logs = new ArrayList<Log>();
			job.setJobLogs(logs);
		}
	}

	private void doSearchStreaming(String queryPeptide, String queryTaxonId, String swissprot, String isoform, String lEqi,
			java.util.TreeSet<String> uniqueACs, java.util.TreeMap<String, Map<String, Object>> jsonHits) throws IOException {
		System.out.println("Query peptide: " + queryPeptide + " sp=" + swissprot + " iso=" + isoform + " leqi=" + lEqi);

		int batchSize = 10000;
		long totalFound = 0;
		long fetched = 0;
		List<FieldValue> searchAfterValues = null;

		while (true) {
			ESSearchService.SearchResult searchResult;
			if (searchAfterValues == null) {
				searchResult = searchService.searchByPeptide(
					queryPeptide, queryTaxonId, swissprot, isoform, lEqi,
					0, batchSize, "ac_asc");
			} else {
				searchResult = searchService.searchAfter(
					queryPeptide, queryTaxonId, swissprot, isoform, lEqi,
					searchAfterValues, batchSize, "ac_asc");
			}

			totalFound = searchResult.totalFound();
			List<Map<String, Object>> hits = searchResult.hits();

			if (hits.isEmpty()) {
				break;
			}

			for (Map<String, Object> hit : hits) {
				String ac = (String) hit.get("ac");
				uniqueACs.add(ac);
				if (jsonHits != null) {
					jsonHits.put(ac, hit);
				}
			}

			fetched += hits.size();
			searchAfterValues = searchResult.sortValues();
			System.out.println("  " + queryPeptide + ": " + fetched + "/" + totalFound + " fetched");

			if (fetched >= totalFound || hits.size() < batchSize) {
				break;
			}
		}

		System.out.println("  " + queryPeptide + ": total " + totalFound + " matches");
	}

	private void writeToFile(String fileName, String content) {
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
