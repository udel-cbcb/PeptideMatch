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
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.TreeMap;

import org.apache.commons.lang.StringUtils;
import org.apache.solr.common.SolrDocument;
import org.apache.solr.common.SolrDocumentList;
import org.codehaus.jackson.JsonGenerationException;
import org.codehaus.jackson.map.JsonMappingException;
import org.codehaus.jackson.map.ObjectMapper;
import org.proteininformationresource.peptidematch.asyncrest.model.Job;
import org.proteininformationresource.peptidematch.asyncrest.model.Log;
import org.proteininformationresource.peptidematch.asyncrest.model.Match;
import org.proteininformationresource.peptidematch.asyncrest.model.Query;
import org.proteininformationresource.peptidematch.asyncrest.model.Report;

public class MatchService implements Runnable {
	/**
	 * The input query
	 */
	private Query query;

	/**
	 * The search job
	 */
	private Job job;

	/**
	 * The config.properties
	 */
	private Properties configuration;

	/**
	 * The match report
	 */
	private Report report;

	/**
	 * 
	 */
	public MatchService() {
		super();
	}

	/**
	 * The match list
	 */
	Map<String, Match> matchList;

	/**
	 * @param query
	 *            the input query
	 * @param job
	 *            the job
	 * @param configuration
	 *            the config.properties
	 */
	public MatchService(Query query, Job job, Properties configuration) {
		super();
		this.query = query;
		this.job = job;
		this.configuration = configuration;
	}

	/**
	 * @return the query
	 */
	public Query getQuery() {
		return query;
	}

	/**
	 * @param query
	 *            the query to set
	 */
	public void setQuery(Query query) {
		this.query = query;
	}

	/**
	 * @return the job
	 */
	public Job getJob() {
		return job;
	}

	/**
	 * @param job
	 *            the job to set
	 */
	public void setJob(Job job) {
		this.job = job;
	}

	/**
	 * @return the configuration
	 */
	public Properties getConfiguration() {
		return configuration;
	}

	/**
	 * @param configuration
	 *            the configuration to set
	 */
	public void setConfiguration(Properties configuration) {
		this.configuration = configuration;
	}

	/**
	 * @return the report
	 */
	public Report getReport() {
		return report;
	}

	/**
	 * @param report
	 *            the report to set
	 */
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
			

			List<String> queryPeptides = query.getPeps();
			job.setQueryPeptides(queryPeptides);
			System.out.println(job);
			writeToFile(logFile, mapper.writeValueAsString(job));
			String solrUrl = this.configuration.getProperty("solrurl");
			
			matchList = new LinkedHashMap<String, Match>();
			String taxonIds = "";
			if (query.getTaxIds() != null && query.getTaxIds().size() > 0) {
				for (Integer tax : query.getTaxIds()) {
					if (taxonIds == "") {
						taxonIds += tax;
					} else {
						taxonIds += ";" + tax;
					}
				}
			}
			job.setTaxonIds(taxonIds);
			job.setlEqi(query.getlEqi());
			job.setSwissProtOnly(query.getSwissProtOnly());
			writeToFile(logFile, mapper.writeValueAsString(job));
			
			PeptideMatchPhraseQuery peptideMatchQuery = new PeptideMatchPhraseQuery(solrUrl);
			job.setStatus("Searching ...");
			writeToFile(logFile, mapper.writeValueAsString(job));
			for (int i = 0; i < queryPeptides.size(); i++) {

				String queryPeptide = queryPeptides.get(i);
				Date start = new Date();
				addSearchTaskStartLog(i, queryPeptides.size(), queryPeptide, start, taxonIds, query.getlEqi(), query.getSwissProtOnly());
				doSearch(peptideMatchQuery, queryPeptide, taxonIds, query.getlEqi(), query.getSwissProtOnly());
				Date end = new Date();
				addSearchTaskEndLog(i, queryPeptides.size(), queryPeptide, start, end, taxonIds, query.getlEqi(), query.getSwissProtOnly());

			}
			System.out.println("matchList size: " + matchList.size());
			this.report = new Report(new ArrayList<Match>(matchList.values()));

			System.out.println(new Date() + " " + job.getJobId() + " preparing results ...");
			System.out.println("Report Match List Size: " + report.getMatchList().size());
			List<String> matchACs = new ArrayList<String>();
			LinkedHashMap<String, String> matchACMap = new LinkedHashMap<String, String>();
			// int count = 0;
			// for (Match match : report.getMatchList()) {
			// count++;
			// if (!matchACs.contains(match.getAc())) {
			// matchACs.add(match.getAc());
			// }
			// if(count % 10000 == 0) {
			// System.out.println(count + " proccessed");
			// }
			// }
			int count = 0;
			for (Match match : report.getMatchList()) {
				count++;
				matchACMap.put(match.getAc(), match.getAc());
				if (count % 1000000 == 0) {
					System.out.println(count + " proccessed");
				}
			}
			
			System.out.println("# Match ACs: " + matchACMap.keySet().size());
			// for (String ac : matchACs) {
			count = 0;
			
			String resultStr = StringUtils.join(matchACMap.keySet(), ',');
//			StringBuffer result = new StringBuffer();
//			for (String ac : matchACMap.keySet()) {
//				count++;
//				if (result.toString().equals("")) {
//					result.append(ac);
//				} else {
//					result.append("," + ac);
//				}
//				if (count % 100000 == 0) {
//					System.out.println(count + " appended");
//				}
//			}
			System.out.println(new Date() + " " + job.getJobId() + " preparing results ... done");

			// String reportJsonFile = cwd + File.separator + "report.json";
			String reportFile = cwd + File.separator + "report.txt";
			// writeToFile(reportJsonFile, mapper.writeValueAsString(report));
			writeToFile(reportFile, resultStr);
			Date jobEnd = new Date();
			Date jobStart = new SimpleDateFormat("yyyy-MM-dd hh:mm:ss").parse(job.getStartTime());
			job.setEndTime(new SimpleDateFormat("yyyy-MM-dd hh:mm:ss").format(jobEnd));
			// System.out.println(jobEnd.getTime() + " : "+ jobStart.getTime());
			long diff = jobEnd.getTime() - jobStart.getTime();
			long diffSeconds = diff / 1000 % 60;
			job.setDurationInSeconds(diffSeconds);
			job.setStatus("Finished");
			writeToFile(logFile, mapper.writeValueAsString(job));
		

		} catch (JsonGenerationException e) {
			e.printStackTrace();
		} catch (JsonMappingException e) {
			e.printStackTrace();
		} catch (org.apache.catalina.connector.ClientAbortException ca) {
		    System.out.println("ClientAbortException caught");
		} catch (IOException e) {
			e.printStackTrace();
		} catch (ParseException e) {
			e.printStackTrace();
		}

	}

	private void addSearchTaskEndLog(int index, int total, String queryPeptide, Date start, Date end, String taxonIds, String lEQi, String swissProtOnly) {
		Log log = new Log();
		log.setTaskName((index + 1) + "/" + total);
		log.setTaxonIds(taxonIds);
		log.setlEQi(lEQi);
		log.setSwissProtOnly(swissProtOnly);
		log.setPeptideSearched(queryPeptide);
		log.setStartTime(new SimpleDateFormat("yyyy-MM-dd hh:mm:ss").format(start));
		log.setEndTime(new SimpleDateFormat("yyyy-MM-dd hh:mm:ss").format(end));
		long diff = end.getTime() - start.getTime();
		// long diffSeconds = diff / 1000 % 60;
		log.setDurationInMilliseconds(diff);

		if (job.getJobLogs() != null) {
			int logIndex = job.getJobLogs().size() - 1;
			job.getJobLogs().set(logIndex, log);
		} else {
			List<Log> logs = new ArrayList<Log>();
			job.setJobLogs(logs);
		}

	}

	private void addSearchTaskStartLog(int index, int total, String queryPeptide, Date start, String taxonIds, String lEQi, String swissProtOnly) {
		Log log = new Log();
		log.setTaskName((index + 1) + "/" + total);
		log.setPeptideSearched(queryPeptide);
		log.setTaxonIds(taxonIds);
		log.setlEQi(lEQi);
		log.setSwissProtOnly(swissProtOnly);
		log.setStartTime(new SimpleDateFormat("yyyy-MM-dd hh:mm:ss").format(start));
		if (job.getJobLogs() != null) {
			job.getJobLogs().add(log);
		} else {
			List<Log> logs = new ArrayList<Log>();
			job.setJobLogs(logs);
		}

	}

	private void doSearch(PeptideMatchPhraseQuery peptideMatchQuery, String queryPeptide, String queryTaxonId, String lEqi, String swissProtOnly) {
		System.out.println("Query peptide: " + queryPeptide);
		System.out.println("SwissProtOnly: " + swissProtOnly);
		SolrDocumentList docs = new SolrDocumentList();
		peptideMatchQuery.queryByPeptide(queryPeptide, 0, 1, lEqi, swissProtOnly, "ac_asc");
		int numberFound = peptideMatchQuery.getResult();
		int numberPerPage = Integer.parseInt(this.configuration.getProperty("numberperpage"));
		// System.out.println(this.configuration.getProperty("numberperpage") +
		// " | " +numberPerPage);
		if (numberFound > 0) {
			for (int i = 0; i < numberFound; i += numberPerPage) {
				peptideMatchQuery.queryByPeptideWithOrganism(queryPeptide, queryTaxonId, i, numberPerPage, lEqi, swissProtOnly, "");
				// peptideMatchQuery.queryByPeptideWithOrganism(queryPeptide,
				// queryTaxonId, 0, numberFound, "N",
				// lEqi, "ac_asc");
				docs = peptideMatchQuery.getCurrentDocs();
				Iterator<SolrDocument> docItr = docs.iterator();
				while (docItr.hasNext()) {
					SolrDocument doc = docItr.next();
					String uniprotAC = (String) doc.getFieldValue("ac");
					// String unirefACs =
					// (String)doc.getFieldValue("unirefACs");
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
