enum ServiceControllerStatus {
	Stopped = 1
	StartPending = 2
	StopPending = 3
	Running = 4
	ContinuePending = 5
	PausePending = 6
	Paused = 7
}

enum ServiceStartupType {
	Automatic = 2
	AutomaticDelayedStart = 10
	Disabled = 4
	InvalidValue = -1
	Manual = 3
}
