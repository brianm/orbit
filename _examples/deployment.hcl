// variables provided as arguments to the deployment,
// there is no mechanism for assignment in this config
var "version" {
    description = "version to deploy"
}
var "env" {
    description = "staging or prod"
    allowed_values = ["staging", "prod"]
    default = "staging"    
}
var "previous" {
    description = "Previous version for unwind"
    default = "${previous.version}"
}

// constants for variable interpolation within this config,
// values determined after vars are known, so can use
// interpolation
const "deployer_image" = "waffle/deployer:1.7"
const "info" = "[waffle ${var.version} ${var.env}]"

// description of how to perform the deployment
deployment "waffle-${var.version}" {

    // ask the ops-bot if it is okay to proceed
    // abort the deploy and rewind if not acked in 1m
    // step will be NOOP on rewind
    // consider a veto="10m" option on the ack
    step notify {
        hipchat = "ops automation"
        forward = "release ${const.info} ?"
        reverse = "unwinding ${const.info}"
        ack {
            required = "1m"           
            from = ["ops-bot"]
        }
    }

    // docker agent pulls the specified image, places a generated
    // shell script in /var/tmp containing the prepare steps
    // and one of forward or reverse steps all anded together
    // then it runs that script in the container. Exit of 0
    // indicates success, anything else triggers rewind of this
    // deploy.
    step docker {
        image = "${const.deployer_image}"
        prepare = ["git pull", "git checkout waffle-${var.version}"]
        forward = ["goose up"]
        reverse = ["goose down"]
    }

    // deploy a canary instance (or instances) with
    // capistrano via a deployer docker image
    step docker {
        image = "${const.deployer_image}"
        prepare = ["git pull", "git checkout waffle-${var.version}"]
        forward = ["cap ${var.env}-canary deploy VERSION=${var.version}"]
        reverse = ["cap ${var.env}-canary deploy VERSION=${var.previous}"]
    }

    // notify hipchat channel and require an ack to proceed    
    step notify {    
        hipchat = "Waffle Dev"
        forward = "canary ${const.info} deployed, proceed?"
        reverse = "canary rolled back from ${const.info}"
        ack required = "1h"
    }
    
    // deploy the remaining instances with capistrano
    step docker {
        image = "${const.deployer_image}"
        prepare = ["git pull", "git checkout waffle-${var.version}"]
        forward = ["cap ${var.env} deploy VERSION=${var.version}"]
        reverse = ["cap ${var.env} deploy VERSION=${var.previous}"]
    }    
}
