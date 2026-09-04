package org.proteininformationresource.peptidematch.asyncrest.model;


import java.util.List;
import javax.xml.bind.annotation.XmlRootElement;
/**
 * This class represents a match job
 * 
 * @author chenc
 *
 */
@XmlRootElement
public class Job {
	
	/**
	 * The id of a match job
	 */
	private String jobId;
	
	/**
	 * The job start time
	 */
	private String startTime;
	
	/**
	 * The job end time
	 */
	private String endTime;
	
	/**
	 * The duration of task in seconds
	 */
	private long durationInSeconds;
		
	/**
	 * The status of a match job
	 */
	private String status;
	
	/**
	 * The job log
	 */
	private List<Log> jobLogs;

	/**
	 * 
	 */
	public Job() {
		super();
		
	}

	/**
	 * @param jobId
	 * @param startTime
	 * @param endTime
	 * @param duration
	 * @param status
	 * @param jobLogs
	 */
	public Job(String jobId, String startTime, String endTime, long durationInSeconds,
			String status, List<Log> jobLogs) {
		super();
		this.jobId = jobId;
		this.startTime = startTime;
		this.endTime = endTime;
		this.durationInSeconds = durationInSeconds;
		this.status = status;
		this.jobLogs = jobLogs;
	}

	/**
	 * @return the jobId
	 */
	public String getJobId() {
		return jobId;
	}

	/**
	 * @param jobId the jobId to set
	 */
	public void setJobId(String jobId) {
		this.jobId = jobId;
	}

	/**
	 * @return the startTime
	 */
	public String getStartTime() {
		return startTime;
	}

	/**
	 * @param startTime the startTime to set
	 */
	public void setStartTime(String startTime) {
		this.startTime = startTime;
	}

	/**
	 * @return the endTime
	 */
	public String getEndTime() {
		return endTime;
	}

	/**
	 * @param endTime the endTime to set
	 */
	public void setEndTime(String endTime) {
		this.endTime = endTime;
	}

	/**
	 * @return the duration
	 */
	public long getDurationInSeconds() {
		return durationInSeconds;
	}

	/**
	 * @param duration the duration to set
	 */
	public void setDurationInSeconds(long durationInSeconds) {
		this.durationInSeconds = durationInSeconds;
	}

	/**
	 * @return the status
	 */
	public String getStatus() {
		return status;
	}

	/**
	 * @param status the status to set
	 */
	public void setStatus(String status) {
		this.status = status;
	}

	/**
	 * @return the jobLogs
	 */
	public List<Log> getJobLogs() {
		return jobLogs;
	}

	/**
	 * @param jobLogs the jobLogs to set
	 */
	public void setJobLogs(List<Log> jobLogs) {
		this.jobLogs = jobLogs;
	}
	
	
}
