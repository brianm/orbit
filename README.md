# Orbit #

Division of responsibility in deployment tool is between the agent, the coordinator, and the activity log.

## Agent ##

The agent performs the fine grained deployment (or rollback) actions. This can be stopping an old docker container and starting a new one, using the Tomcat deployer, or stopping a service, updating an RPM, and starting the new service.

## Coordinator ##

The coordinator invokes agents to do things. It maintains a tree of actions which it serializes into a scheduled sequence of fine grained commands to agents. It records what it plans to do, where it is, and what it has done in the Log.

## Log ##

The log is a semi-transaction log of fine grained actions. It allows for rollback to a specific point in time, tag, etc. It is used by the coordinator to record actions and undos.

