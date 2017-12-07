public class MnStages extends ApplicationDomain {
	
	public enum Status {QUEUED, PROCESSING, COMPLETED, FAILED, INVALID, IGNORED, ABORTED}
	
	public static final Map<Status, String> STATUSES = new Map<Status, String> {
		Status.QUEUED => 'Queued',
		Status.PROCESSING => 'Processing',
		Status.COMPLETED => 'Completed',
		Status.FAILED => 'Failed',
		Status.INVALID => 'Invalid',
		Status.IGNORED => 'Ignored',
		Status.ABORTED => 'Aborted'
	};
	
}