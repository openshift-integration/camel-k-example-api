# Camel K API Example
 
![Camel K CI](https://github.com/openshift-integration/camel-k-example-api/workflows/Camel%20K%20CI/badge.svg)

This example demonstrates how to write an API based Camel K integration, from the design of the OpenAPI definition 
to the implementation of the specific endpoints.

In this specific example, the API enables users to store generic objects, such as files, in a backend system, allowing all CRUD operation on them.

The backend is an Amazon AWS S3 bucket that you might provide. In alternative, you'll be given instructions on how to 
create a simple [Minio](https://min.io/) backend, which uses a S3 compatible protocol.


## Before you begin

Make sure you check-out this repository from git and open it with [VSCode](https://code.visualstudio.com/).

Instructions are based on [VSCode Didact](https://github.com/redhat-developer/vscode-didact), so make sure it's installed
from the VSCode extensions marketplace.

From the VSCode UI, click on the `readme.didact.md` file and select "Didact: Start Didact tutorial from File". A new Didact tab will be opened in VS Code.

## Checking requirements

<a href='didact://?commandId=vscode.didact.validateAllRequirements' title='Validate all requirements!'><button>Validate all Requirements at Once!</button></a>

**VS Code Extension Pack for Apache Camel**

The VS Code Extension Pack for Apache Camel by Red Hat provides a collection of useful tools for Apache Camel K developers,
such as code completion and integrated lifecycle management.

You can install it from the VS Code Extensions marketplace.

[Check if the VS Code Extension Pack for Apache Camel by Red Hat is installed](didact://?commandId=vscode.didact.extensionRequirementCheck&text=extension-requirement-status$$redhat.apache-camel-extension-pack&completion=Camel%20extension%20pack%20is%20available%20on%20this%20system. "Checks the VS Code workspace to make sure the extension pack is installed"){.didact}

*Status: unknown*{#extension-requirement-status}

**OpenShift CLI ("oc")**

The OpenShift CLI tool ("oc") will be used to interact with the OpenShift cluster.

[Check if the OpenShift CLI ("oc") is installed](didact://?commandId=vscode.didact.requirementCheck&text=oc-requirements-status$$oc%20version$$oc&completion=OpenShift%20%20CLI%20is%20available%20on%20this%20system. "Tests to see if `oc version` returns a result"){.didact}

*Status: unknown*{#oc-requirements-status}


**Connection to an OpenShift cluster**

You need to connect to an OpenShift cluster in order to run the examples.

[Check if you're connected to an OpenShift cluster](didact://?commandId=vscode.didact.requirementCheck&text=cluster-requirements-status$$oc%20get%20project$$NAME&completion=OpenShift%20is%20connected. "Tests to see if `kamel version` returns a result"){.didact}

*Status: unknown*{#cluster-requirements-status}

**Apache Camel K CLI ("kamel")**

Apart from the support provided by the VS Code extension, you also need the Apache Camel K CLI ("kamel") in order to 
access all Camel K features.

[Check if the Apache Camel K CLI ("kamel") is installed](didact://?commandId=vscode.didact.requirementCheck&text=kamel-requirements-status$$kamel%20version$$Camel%20K%20Client&completion=Apache%20Camel%20K%20CLI%20is%20available%20on%20this%20system. "Tests to see if `kamel version` returns a result"){.didact}

*Status: unknown*{#kamel-requirements-status}


## 1. Preparing a new OpenShift project

We'll setup a new project called `camel-api` where we'll run the integrations.

To create the project, open a terminal tab and type the following command:


```
oc new-project camel-api
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=camelTerm$$oc%20new-project%20camel-api&completion=New%20project%20creation. "Opens a new terminal and sends the command above"){.didact})


Upon successful creation, you should ensure that the Camel K operator is installed. We'll use the `kamel` CLI to do it:

```
kamel install
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=camelTerm$$kamel%20install&completion=Camel%20K%20operator%20installation. "Opens a new terminal and sends the command above"){.didact})


Camel K should have created an IntegrationPlatform custom resource in your project. To verify it:

```
oc get integrationplatform
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=camelTerm$$oc%20get%20integrationplatform&completion=Camel%20K%20integration%20platform%20verification. "Opens a new terminal and sends the command above"){.didact})

If everything is ok, you should see an IntegrationPlatform named `camel-k` with phase `Ready` (it can take some time for the 
operator to being installed).


## 2. Configuring the object storage backend

You have two alternative options for setting up the S3 backend that will be used to store the objects via the Camel K API: 
you can use an existing S3 bucket of your own or you can set up a local S3 compatible object storage.

### 2.1 I don't have a S3 bucket: let's install a Minio backend

The `test` directory contains an all-in-one configuration file for creating a Minio backend that will provide a S3 compatible protocol
for storing the objects.

Open the ([test/minio.yaml](didact://?commandId=vscode.open&projectFilePath=test/minio.yaml "Opens the Minio configuration"){.didact}) file to check its content before applying.

To create the minio backend, just apply the provided file:

```
oc apply -f test/minio.yaml
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=camelTerm$$oc%20apply%20-f%20test/minio.yaml&completion=Created%20Minio%20backend. "Opens a new terminal and sends the command above"){.didact})

That's enough to have a test object storage to use with the API integration.

### 2.1 I have a S3 bucket

If you have a S3 bucket and you want to use it instead of the test backend, you can do it. The only 
things that you need to provide are a **AWS Access Key ID and Secret** that you can obtain from the Amazon AWS console.

Edit the ([s3.properties](didact://?commandId=vscode.open&projectFilePath=s3.properties "Opens the S3 configuration"){.didact}) to set the right value for the properties `camel.component.aws-s3.access-key` and `camel.component.aws-s3.secret-key`.
Those properties will be automatically injected into the Camel `aw3-s3` component.

## 3. Designing the API

An object store REST API is provided in the [openapi.yaml](didact://?commandId=vscode.open&projectFilePath=openapi.yaml "Opens the OpenAPI definition"){.didact} file.

It contains operations for:
- Listing the name of the contained objects
- Creating a new object
- Getting the content of an object
- Deleting an object

The file can be edited manually or better using an online editor, such as [Apicurio](https://studio.apicur.io/).

## 4. Running the API integration

The endpoints defined in the API can be implemented in a Camel K integration using a `direct:<operationId>` endpoint.
This has been implemented in the [API.java](didact://?commandId=vscode.open&projectFilePath=API.java "Opens the integration file"){.didact} file.

To run the integration, you need to link it to the proper configuration, that depends on what configuration you've chosen.

### 4.1 Using the S3 service

To connect the integration to the **AWS S3 service**:

```
kamel run API.java --property-file s3.properties --open-api openapi.yaml
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=camelTerm$$kamel%20run%20API.java%20--property-file%20s3.properties%20--open-api%20openapi.yaml&completion=Integration%20run. "Opens a new terminal and sends the command above"){.didact})

### 4.2 Using the test Minio server

As alternative, to connect the integration to the **test Minio server** deployed before:

```
kamel run test/MinioConfigurer.java API.java --open-api openapi.yaml -p api.bucket=camel-k
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=camelTerm$$kamel%20run%20test/MinioConfigurer.java%20API.java%20--open-api%20openapi.yaml%20-p%20api.bucket=camel-k&completion=Integration%20run. "Opens a new terminal and sends the command above"){.didact})


## 5. Using the API

After running the integration API, you should be able to call the API endpoints to check its behavior.

Make sure the integration is running, by checking its status:

```
oc get integrations
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=camelTerm$$oc%20get%20integrations&completion=Getting%20running%20integrations. "Opens a new terminal and sends the command above"){.didact})

An integration named `api` should be present in the list and it should be in status `Running`. There's also a `kamel get` command which is an alternative way to list all running integrations.

NOTE: it may take some time, the first time you run the integration, for it to reach the `Running` state.

**TO BE CONTINUED with:**
- OpenAPI test UI
- 3scale management


