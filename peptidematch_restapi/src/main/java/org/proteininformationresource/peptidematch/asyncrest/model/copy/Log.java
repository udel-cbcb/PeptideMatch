package org.proteininformationresource.peptidematch.asyncrest.model.copy;

import java.util.Date;

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
	private Date startTime;
	
	/**
	 * The task end time
	 */
	private Date endTime;
	
	/**
	 * The duration of task in seconds
	 */
	private long duration;
	
	/**
	 * Description of the task
	 */
	private String description;

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
	 * @param duration the task duration in seconds
	 * @param description the description of task
	 */
	public Log(String taskName, Date startTime, Date endTime, long duration,
			String description) {
		super();
		this.taskName = taskName;
		this.startTime = startTime;
		this.endTime = endTime;
		this.duration = duration;
		this.description = description;
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
	public Date getStartTime() {
		return startTime;
	}

	/**
	 * @param startTime the task start time to set
	 */
	public void setStartTime(Date startTime) {
		this.startTime = startTime;
	}

	/**
	 * @return the endTime the task end time
	 */
	public Date getEndTime() {
		return endTime;
	}

	/**
	 * @param endTime the task end time to set
	 */
	public void setEndTime(Date endTime) {
		this.endTime = endTime;
	}

	/**
	 * @return the duration the duration of task
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
	 * @return the description the description of task
	 */
	public String getDescription() {
		return description;
	}

	/**
	 * @param description the description of taask to set
	 */
	public void setDescription(String description) {
		this.description = description;
	}

	
}
