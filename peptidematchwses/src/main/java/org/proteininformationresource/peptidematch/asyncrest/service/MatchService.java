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
	private Report report;
	private static ESSearchService searchService;

	static {
		try {
			ElasticsearchClient client = ESClientFactory.createClient();
			searchService = new ESSearchService(client);
		} catch (Exception e) {
			throw new RuntimeException("Failed to initialize ES client", e);
		}
	}

	Map<String, Match> matchList;

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

	public Report getReport() {
		return report;
	}

	public void setReport(Report report) {
		this.report = report;
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
			matchList = new TreeMap<String, Match>();

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

			for (int i = 0; i < queryPeptides.size(); i++) {
				String queryPeptide = queryPeptides.get(i);
				Date start = new Date();
				addSearchTaskStartLog(i, queryPeptides.size(), queryPeptide, start, taxonIds, query.getlEqi());
				doSearch(queryPeptide, taxonIds, query.getlEqi());
				Date end = new Date();
				addSearchTaskEndLog(i, queryPeptides.size(), queryPeptide, start, end, taxonIds, query.getlEqi());
			}

			System.out.println("matchList size: " + matchList.size());
			this.report = new Report(new ArrayList<Match>(matchList.values()));

			System.out.println(new Date() + " " + job.getJobId() + " preparing results ...");
			List<String> matchACs = new ArrayList<String>();
			TreeMap<String, String> matchACMap = new TreeMap<String, String>();

			int count = 0;
			for (Match match : report.getMatchList()) {
				count++;
				matchACMap.put(match.getAc(), match.getAc());
				if (count % 1000000 == 0) {
					System.out.println(count + " processed");
				}
			}

			System.out.println("# Match ACs: " + matchACMap.keySet().size());
			String resultStr = org.apache.commons.lang3.StringUtils.join(matchACMap.keySet(), ',');

			System.out.println(new Date() + " " + job.getJobId() + " preparing results ... done");

			String reportFile = cwd + File.separator + "report.txt";
			writeToFile(reportFile, resultStr);

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

	private void doSearch(String queryPeptide, String queryTaxonId, String lEqi) throws IOException {
		System.out.println("Query peptide: " + queryPeptide);

		int numberPerPage = Integer.parseInt(this.configuration.getProperty("numberperpage"));

		ESSearchService.SearchResult searchResult = searchService.searchByPeptide(
			queryPeptide, queryTaxonId, "", "", lEqi,
			0, 10000, "ac_asc");

		int numberFound = (int) searchResult.totalFound();

		if (numberFound > 0) {
			for (Map<String, Object> hit : searchResult.hits()) {
				String uniprotAC = (String) hit.get("ac");
				Match matchedProtein = matchList.get(uniprotAC);
				if (matchedProtein == null) {
					List<String> peptideList = new ArrayList<String>();
					peptideList.add(queryPeptide);
					matchedProtein = new Match(uniprotAC, peptideList);
					matchList.put(uniprotAC, matchedProtein);
				} else {
					if (!matchedProtein.getMatchPeps().contains(queryPeptide)) {
						matchedProtein.getMatchPeps().add(queryPeptide);
					}
				}
			}
		}
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
