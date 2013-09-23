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

For the deployment tool to work you will need to add some keys to your environment.

> export AWS_APP_ACCESS_KEY_ID=VALUE

> export AWS_APP_SECRET_KEY=VALUE

> export AWS_DNS_ACCESS_KEY_ID=VALUE

> export AWS_DNS_SECRET_KEY=VALUE

> export NEWRELIC_API_KEY=NEWRELIC_API_KEY

> export GITHUB_ACCESS_TOKEN=GITHUB_ACCESS_TOKEN

Please consult [AWS IAM](http://aws.amazon.com/iam/) for those values.

### Setup & Cleanup

It is important to make sure the tool is easy to use.

To get going

> ./mist setup --email your_email

Once you have had enough

> ./mist cleanup

### Deploy a stack

This allows the release manager to deploy to a specific stack

> ./mist deploy -s QA

### Deploy an environment

This allows the release manager to deploy to a specific environment.

> ./mist deploy -s QA -e PINCHme-US-QA-A

### Swap an environment

This allows the release manager to swap the DNS endpoint within a stack to point to the next environment.

> ./mist swap -s QA

### Warm an environment

This allows the release manager to warm a specific environment.

> ./mist warm -s QA -e PINCHme-US-QA-A

### Version

This allows the release manager to get an idea of what version is running in a stack or an environment within a stack.

> ./mist version -s QA

> ./mist version -s QA -e PINCHme-US-QA-A

### Marking Deployment

At PINCHme we use an awesome tool called [newrelic](http://newrelic.com/). When a deployment is finished we mark a
deployment with newrelic. If you want as a release manager you can do that yourself.

> ./mist mark
