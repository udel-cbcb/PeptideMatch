package org.proteininformationresource.peptidematch.asyncrest.model;

/**
 * This class represents a matching task log
 * 
 * @author chenc
 *
 */
public class Log {
	/**
	 * The task name
	 */
	private String taskName;
	
	/**
	 * The task start time
	 */
	private String startTime;
	
	/**
	 * The task end time
	 */
	private String endTime;
	
	/**
	 * The duration of task in seconds
	 */
	private long durationInMilliseconds;
	
	/**
	 * The peptide searched
	 */
	private String peptideSearched;

	/**
	 * A list of taxonIds searched against
	 */
	private String taxonIds;
	
	/**
	 * Flag indicates whether Treat Isoleucine and Leucine as equivalent.
	 */
	private String lEQi;
	
	/**
	 * 
	 */
	public Log() {
		super();
	}

	/**
	 * @param taskName the task name
	 * @param startTime the task start time
	 * @param endTime the task end time
	 * @param duration the task duration in milliseconds
	 * @param peptideSearched the peptide searched
	 */
	public Log(String taskName, String startTime, String endTime, long durationInMilliseconds,
			String peptideSearched, String taxonIds, String lEQi) {
		super();
		this.taskName = taskName;
		this.startTime = startTime;
		this.endTime = endTime;
		this.durationInMilliseconds = durationInMilliseconds;
		this.peptideSearched = peptideSearched;
		this.taxonIds = taxonIds;
		this.lEQi = lEQi;
	}

	/**
	 * @return the task the task name
	 */
	public String getTaskName() {
		return taskName;
	}

	/**
	 * @param task the task name to set
	 */
	public void setTaskName(String taskName) {
		this.taskName = taskName;
	}

	/**
	 * @return the startTime the task start time
	 */
	public String getStartTime() {
		return startTime;
	}

	/**
	 * @param startTime the task start time to set
	 */
	public void setStartTime(String startTime) {
		this.startTime = startTime;
	}

	/**
	 * @return the endTime the task end time
	 */
	public String getEndTime() {
		return endTime;
	}

	/**
	 * @param endTime the task end time to set
	 */
	public void setEndTime(String endTime) {
		this.endTime = endTime;
	}

	/**
	 * @return the duration the duration of task
	 */
	public long getDurationInMilliseconds() {
		return durationInMilliseconds;
	}

	/**
	 * @param duration the duration to set
	 */
	public void setDurationInMilliseconds(long durationInMilliseconds) {
		this.durationInMilliseconds = durationInMilliseconds;
	}

	/**
	 * @return the peptideSearched
	 */
	public String getPeptideSearched() {
		return peptideSearched;
	}

	/**
	 * @param peptideSearched the peptideSearched to set
	 */
	public void setPeptideSearched(String peptideSearched) {
		this.peptideSearched = peptideSearched;
	}

	/**
	 * @return the taxonIds
	 */
	public String getTaxonIds() {
		return taxonIds;
	}

	/**
	 * @param taxonIds the taxonIds to set
	 */
	public void setTaxonIds(String taxonIds) {
		this.taxonIds = taxonIds;
	}

	/**
	 * @return the lEQi
	 */
	public String getlEQi() {
		return lEQi;
	}

	/**
	 * @param lEQi the lEQi to set
	 */
	public void setlEQi(String lEQi) {
		this.lEQi = lEQi;
	}

	
	
}
