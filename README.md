#mist

Cloud automation for PINCHme

## Purpose

At PINCHme we believe that computers are better at doing repetitive tasks than humans are. So we want to automate as
much as possible

## Environment

These sections describe how the environment is set up.

### Infrastructure

Our platform of choice is Elastic Beanstalk. To setup an environment one needs to use the [CLI](http://aws.amazon.com/code/6752709412171743) tool
so please have a look at how that works.

We have setup our environment following a pattern called Blue/Green [deployment](http://martinfowler.com/bliki/BlueGreenDeployment.html).
Once the deployment is successful we switch the DNS using Route 53.

### Architecture

Please take a look at the spec folder.

## Usage

### Prerequisites

The deployment tool requires some love before you use it.

#### Environment Variables

For the deployment tool to work you will need to add some keys to your environment.

> export AWS_APP_ACCESS_KEY_ID=VALUE

> export AWS_APP_SECRET_KEY=VALUE

> export AWS_DNS_ACCESS_KEY_ID=VALUE

> export AWS_DNS_SECRET_KEY=VALUE

> export NEWRELIC_API_KEY=NEWRELIC_API_KEY

> export GITHUB_ACCESS_TOKEN=GITHUB_ACCESS_TOKEN

Please consult [AWS IAM](http://aws.amazon.com/iam/) for those values.

#### Config File

The deployment tool uses a configuration file that is used to work out your stacks and environments.

    git:
      repository_name: test
      repository_uri: git@test/test.git
      local_path: /tmp
    aws:
      application_name: test
      dev_tools_endpoint: git.elasticbeanstalk.us-east-1.amazonaws.com
      region: us-east-1
      hosted_zone: test.com.
      stacks:
        qa:
          domain: qa.test.com.
          endpoint: https://qa.test.com
          newrelic_application_name: test-QA
          basic_auth:
            username: test_username
            password: test_password
          environments:
            -
              name: test-QA-A
              uri: https://testqaa.com
            -
              name: test-QA-B
              uri: https://testqab.com
        uat:
          domain: uat.test.com.
          endpoint: https://uat.test.com
          newrelic_application_name: test-UAT
          basic_auth:
            username: test_username
            password: test_password
          environments:
            -
              name: test-UAT-A
              uri: https://testuata.com
            -
              name: test-UAT-B
              uri: https://testuatb.com
        live:
          domain: live.test.com.
          endpoint: https://live.test.com
          newrelic_application_name: test
          environments:
            -
              name: test-A
              uri: https://testa.com
            -
              name: test-B
              uri: https://testqb.com

### Setup & Cleanup

It is important to make sure the tool is easy to use.

To get going

> ./mist setup --email your_email

Once you have had enough

> ./mist cleanup

### Deploy

There are several ways that the application can be deployed.

#### Deploy a stack

This allows the release manager to deploy to a specific stack.

> ./mist deploy -s QA

#### Deploy a stack with version

This allows the release manager to deploy to a specific stack with a version.

> ./mist deploy -s QA -v git-24f16d3727b0271c89e213d6ded27f986dfb5436-1380729401417

#### Deploy an environment

This allows the release manager to deploy to a specific environment.

> ./mist deploy -s QA -e PINCHme-US-QA-A

#### Deploy an environment with version

This allows the release manager to deploy to a specific environment with a version.

> ./mist deploy -s QA -e PINCHme-US-QA-A -v git-24f16d3727b0271c89e213d6ded27f986dfb5436-1380729401417

### Warm an environment

This allows the release manager to warm a specific environment.

> ./mist warm -s QA -e PINCHme-US-QA-A

### Swap an environment

This allows the release manager to swap the DNS endpoint within a stack to point to the next environment.

> ./mist swap -s QA

### Marking Deployment

At PINCHme we use an awesome tool called [newrelic](http://newrelic.com/). When a deployment is finished we mark a
deployment with newrelic. If you want as a release manager you can do that yourself.

> ./mist mark -s QA

### Version

This allows the release manager to get an idea of what version is running in a stack or an environment within a stack.

> ./mist version -s QA

> ./mist version -s QA -e PINCHme-US-QA-A

## Costs

As we all know AWS costs money. For this reason we allow mist to help you manage those costs.

### Start

This allows the release manager or cron job to start the elastic beanstalk environment

> ./mist start -s QA

> ./mist start -s QA -e PINCHme-US-QA-A

### Stop

This allows the release manager or cron job to stop the elastic beanstalk environment

> ./mist stop -s QA

> ./mist stop -s QA -e PINCHme-US-QA-A

## FAQ

From time to time the tool will faq up. That is why we have this section.

### Order of events

When running the command

> ./mist deploy -s QA

Mist performs the following actions

* [Deploy an environment](#deploy-an-environment)
* [Warm an environment](#warm-an-environment)
* [Swap an environment](#swap-an-environment)
* [Marking Deployment](#marking-deployment)

If any of these steps fail. You can manually intervene and do the steps individually.

**NOTE: WHEN MANUALLY INTERVENING YOU WILL HAVE TO PASS THE -e (environment) PARAMETER FOR THE NEW ENVIRONMENT YOU ARE DEPLOYING TO!**

### Common Errors

Below is a list of common errors.

#### Could not warm up website

When this error happens all you need to do is run [Warm an environment](#warm-an-environment) and follow the other steps
