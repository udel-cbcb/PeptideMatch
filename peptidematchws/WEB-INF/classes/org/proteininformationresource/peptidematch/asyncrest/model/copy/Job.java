package org.proteininformationresource.peptidematch.asyncrest.model.copy;

import java.util.Date;
import java.util.List;

import javax.ws.rs.core.Link;
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
	private Date startTime;
	
	/**
	 * The job end time
	 */
	private Date endTime;
	
	/**
	 * The duration of task in seconds
	 */
	private long duration;
		
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
	public Job(String jobId, Date startTime, Date endTime, long duration,
			String status, List<Log> jobLogs) {
		super();
		this.jobId = jobId;
		this.startTime = startTime;
		this.endTime = endTime;
		this.duration = duration;
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
	public Date getStartTime() {
		return startTime;
	}

	/**
	 * @param startTime the startTime to set
	 */
	public void setStartTime(Date startTime) {
		this.startTime = startTime;
	}

	/**
	 * @return the endTime
	 */
	public Date getEndTime() {
		return endTime;
	}

	/**
	 * @param endTime the endTime to set
	 */
	public void setEndTime(Date endTime) {
		this.endTime = endTime;
	}

	/**
	 * @return the duration
	 */
	public long getDuration() {
		return duration;
	}

	/**
	 * @param duration the duration to set
	 */
	public void setDuration(long duration) {
		this.duration = duration;
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
