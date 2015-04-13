Orbit is a daemon which coordinates deployments. A deployment is a configuration, described in HCL (see _examples/). It maintains a linkage between deployments for a given service, a log of deployments and steps performed, and a plan for steps to execute.

A deployment consists of some variables assigned as arguments to the dpeloyment (ie, the version to deploy), some constants generated for convenience, and a deployment plan which allows interpolation of variables and constants. The deployment plan consists of a sequnce of steps which are executed by agents.

Agents are plugins that orbit runs. The exact structure is not fully understood, but it is likely that they will be docker images/containers which have some protocol for providing arguments (possibly just env vars, possibly arguments to CMD). As a commonly used agent is probably one which just invokes docker itself, we may need to mount the docker socket in and/or pass DOCKER_HOST for swarm type setups. To be figured out.

Deployments may run simultaneously. Steps performed by a deployment (or rewind) are recorded sequentially so that they may be unwound in identical order. 

If something goes wrong in a step, that deployment is unwound. Users may unwind any deployment that has not been superceded by another deployment. If a deployment is unwound, its "previous" is set to the previous of the one unwound, so repeated unwinds continue to move back in time, even though it is really a roll forward -- it simulates a rollback :-)

Consider also tracking a "next" so "redeploy" can be a one-click, and a whole chain of redeploys can be accomplished.

Isolation semantics around deploy streams is going to be fun!

# Activity Log

The activity log is append only. "Rollbacks" are determined by scanning backwards and constructing a new plan which executes the steps needed to undo the changes being rolled back.

Log structure might look something like:

```
{
service_id,
previous_deploy_id,
next_deploy_id,
deploy_id,
step_id,
previous_step_id,
next_step_id,
forward_action,
reverse_action,
applied_time
}
```

Where action is the agent invocation to do a fine grained part of the deploy, and rollback is the agent invocation to rewind the action once applied.

# Deployment #

A deployment consists of a series of actions, rollbacks, and a schedule upon which to apply them.

Does a deployment know about its logical predecessor? It is easier to make it not know, but might be useful if it does. An example of that usefulness is querying version from the previous deployment for unwind.

# Examples

## Mesos/Singularity|Marathon ##

## Capistrano ##

## Database ##

# Output #

[Color is nice](https://github.com/wsxiaoys/terminal/blob/master/color/color.go)!
