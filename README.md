# Schema

	Workload:
		- Deployment
		- StatefulSet
		- DaemonSet
		- CronJob
	Permissions:
		- Role/ClusterRoles
		- Bindings
		- ServiceAccounts
	Hooks: 
		- Pods
		- Jobs
        - * (tests)
	Configuration:
		- ConfigMaps
		- Secrets
	Namespaces:
		- Namespaces
		- LimitRanges
	CRDs:
		- CRDs
	Raw:
		- Any
	Addons:
		- CRs
	CRs: 
		- CRs

# Workload

What one usually wants to configure in a deployment?
