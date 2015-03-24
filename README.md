# Orbit

Division of responsibility in deployment tool is between the agent, the coordinator, and the activity log.

## Agent

The agent performs the fine grained deployment action. This can be stopping an old docker container and starting a new one, using the Tomcat deployer, or stopping a service, updating an RPM, and starting the new service.

## Coordinator

The coordinator invokes agents to perform actions on service instances. It handles deployment workflows, notifies IRC channels, and reports on the status of things. All action flows through the coordinator.

## Activity Log

The activity log keeps track of all the state involved in deployments. It maintains a traditional event log, as well as convenient denormalized views based on the event log.
