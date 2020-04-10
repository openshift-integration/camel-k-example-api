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

From the VSCode UI, right-click on the `readme.didact.md` file and select "Didact: Start Didact tutorial from File". A new Didact tab will be opened in VS Code.

Make sure you've opened this readme file with Didact before jumping to the next section.

## Preparing the cluster

This example can be run on any OpenShift 4.3+ cluster or a local development instance (such as [CRC](https://github.com/code-ready/crc)). Ensure that you have a cluster available and login to it using the OpenShift `oc` command line tool.

You need to create a new project named `camel-api` for running this example. This can be done directly from the OpenShift web console or by executing the command `oc new-project camel-api` on a terminal window.

You need to install the Camel K operator in the `camel-api` project. To do so, go to the OpenShift 4.x web console, login with a cluster admin account and use the OperatorHub menu item on the left to find and install **"Red Hat Integration - Camel K"**. You will be given the option to install it globally on the cluster or on a specific namespace.
If using a specific namespace, make sure you select the `camel-api` project from the dropdown list.
This completes the installation of the Camel K operator (it may take a couple of minutes).

When the operator is installed, from the OpenShift Help menu ("?") at the top of the WebConsole, you can access the "Command Line Tools" page, where you can download the **"kamel"** CLI, that is required for running this example. The CLI must be installed in your system path.

Refer to the **"Red Hat Integration - Camel K"** documentation for a more detailed explanation of the installation steps for the operator and the CLI.

You can use the following section to check if your environment is configured properly.

## Checking requirements

<a href='didact://?commandId=vscode.didact.validateAllRequirements' title='Validate all requirements!'><button>Validate all Requirements at Once!</button></a>

**OpenShift CLI ("oc")**

The OpenShift CLI tool ("oc") will be used to interact with the OpenShift cluster.

[Check if the OpenShift CLI ("oc") is installed](didact://?commandId=vscode.didact.cliCommandSuccessful&text=oc-requirements-status$$oc%20help&completion=Checked%20oc%20tool%20availability "Tests to see if `oc help` returns a 0 return code"){.didact}

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

### Optional Requirements

The following requirements are optional. They don't prevent the execution of the demo, but may make it easier to follow.

**VS Code Extension Pack for Apache Camel**

The VS Code Extension Pack for Apache Camel by Red Hat provides a collection of useful tools for Apache Camel K developers,
such as code completion and integrated lifecycle management. They are **recommended** for the tutorial, but they are **not**
required.

You can install it from the VS Code Extensions marketplace.

[Check if the VS Code Extension Pack for Apache Camel by Red Hat is installed](didact://?commandId=vscode.didact.extensionRequirementCheck&text=extension-requirement-status$$redhat.apache-camel-extension-pack&completion=Camel%20extension%20pack%20is%20available%20on%20this%20system. "Checks the VS Code workspace to make sure the extension pack is installed"){.didact}

*Status: unknown*{#extension-requirement-status}


## 1. Preparing the project

We'll connect to the `camel-api` project and check the installation status.

To change project, open a terminal tab and type the following command:


```
oc project camel-api
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=camelTerm$$oc%20project%20camel-api&completion=New%20project%20creation. "Opens a new terminal and sends the command above"){.didact})


We should now check that the operator is installed. To do so, execute the following command on a terminal:

```
oc get csv
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=camelTerm$$oc%20get%20csv&completion=Checking%20Cluster%20Service%20Versions. "Opens a new terminal and sends the command above"){.didact})

When Camel K is installed, you should find an entry related to `red-hat-camel-k-operator` in phase `Succeeded`.

After successful installation, we'll configure an `IntegrationPlatform` with default settings using the following command:

```
kamel install --trait-profile=OpenShift --olm=false --skip-cluster-setup --skip-operator-setup
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=camelTerm$$kamel%20install%20--trait-profile%20OpenShift%20--olm=false%20--skip-cluster-setup%20--skip-operator-setup&completion=Camel%20K%20IntegrationPlatform%20creation. "Opens a new terminal and sends the command above"){.didact})

NOTE: We use the `OpenShift` trait profile to make the quickstart work on plain OpenShift, without Knative features. We'll enable Knative features in the last part
of the quickstart.

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

### 2.1 [Alternative 1] I don't have a S3 bucket: let's install a Minio backend

The `test` directory contains an all-in-one configuration file for creating a Minio backend that will provide a S3 compatible protocol
for storing the objects.

Open the ([test/minio.yaml](didact://?commandId=vscode.open&projectFilePath=test/minio.yaml "Opens the Minio configuration"){.didact}) file to check its content before applying.

To create the minio backend, just apply the provided file:

```
oc apply -f test/minio.yaml
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=camelTerm$$oc%20apply%20-f%20test/minio.yaml&completion=Created%20Minio%20backend. "Opens a new terminal and sends the command above"){.didact})

That's enough to have a test object storage to use with the API integration.

### 2.1 [Alternative 2] I have a S3 bucket

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

### 4.1 [Alternative 1] Using the test Minio server

As alternative, to connect the integration to the **test Minio server** deployed before using the [test/MinioCustomizer.java](didact://?commandId=vscode.open&projectFilePath=test/MinioCustomizer.java "Opens the customizer file"){.didact} class:

```
kamel run --name api test/MinioCustomizer.java API.java --property-file test/minio.properties --open-api openapi.yaml -d camel-openapi-java
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=camelTerm$$kamel%20run%20--name%20api%20test/MinioCustomizer.java%20API.java%20--property-file%20test/minio.properties%20--open-api%20openapi.yaml%20-d%20camel-openapi-java&completion=Integration%20run. "Opens a new terminal and sends the command above"){.didact})

### 4.2 [Alternative 2] Using the S3 service

To connect the integration to the **AWS S3 service**:

```
kamel run API.java --property-file s3.properties --open-api openapi.yaml -d camel-openapi-java
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=camelTerm$$kamel%20run%20API.java%20--property-file%20s3.properties%20--open-api%20openapi.yaml%20-d%20camel-openapi-java&completion=Integration%20run. "Opens a new terminal and sends the command above"){.didact})


## 5. Using the API

After running the integration API, you should be able to call the API endpoints to check its behavior.

Make sure the integration is running, by checking its status:

```
oc get integrations
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=camelTerm$$oc%20get%20integrations&completion=Getting%20running%20integrations. "Opens a new terminal and sends the command above"){.didact})

An integration named `api` should be present in the list and it should be in status `Running`. There's also a `kamel get` command which is an alternative way to list all running integrations.

NOTE: it may take some time, the first time you run the integration, for it to reach the `Running` state.

After the integraiton has reached the running state, you can get the route corresponding to it via the following command:

```
URL=http://$(oc get route api -o jsonpath='{.spec.host}')
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=camelTerm$$URL%3Dhttp%3A%2F%2F%24%28oc%20get%20route%20api%20-o%20jsonpath%3D%27%7B.spec.host%7D%27%29&completion=Getting%20route. "Opens a new terminal and sends the command above"){.didact})


You can print the route to check if it's correct:

```
echo $URL
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=camelTerm$$echo%20$URL&completion=Print%20route. "Opens a new terminal and sends the command above"){.didact})

You can now play with it!

Get the list of objects:
```
curl -i $URL/
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=camelTerm$$curl%20-i%20$URL&completion=Use%20the%20API. "Opens a new terminal and sends the command above"){.didact})

Upload an object:
```
curl -i -X PUT --header "Content-Type: application/octet-stream" --data-binary "@API.java" $URL/example
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=camelTerm$$curl%20-i%20-X%20PUT%20--header%20%22Content-Type%3A%20application%2Foctet-stream%22%20--data-binary%20%22%40API.java%22%20%24URL%2Fexample&completion=Use%20the%20API. "Opens a new terminal and sends the command above"){.didact})

Get the new list of objects:
```
curl -i $URL/
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=camelTerm$$curl%20-i%20$URL&completion=Use%20the%20API. "Opens a new terminal and sends the command above"){.didact})

Get the content of a file:
```
curl -i $URL/example
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=camelTerm$$curl%20-i%20%24URL%2Fexample&completion=Use%20the%20API. "Opens a new terminal and sends the command above"){.didact})

Delete the file:
```
curl -i -X DELETE $URL/example
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=camelTerm$$curl%20-i%20-X%20DELETE%20%24URL%2Fexample&completion=Use%20the%20API. "Opens a new terminal and sends the command above"){.didact})

Get (again) the new list of objects:
```
curl -i $URL/
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=camelTerm$$curl%20-i%20$URL&completion=Use%20the%20API. "Opens a new terminal and sends the command above"){.didact})


## 6. Running as Knative service (Optional - Requires Knative)

The API integration can also run as Knative service and be able to scale to zero and scale out automatically, based on the received load.

To expose the integration as Knative service, you need to have OpenShift serverless installed in the cluster.



### 6.1 [Alternative 1] Using the test Minio server

As alternative, to connect the integration to the **test Minio server**:

```
kamel run --name api test/MinioCustomizer.java API.java --property-file test/minio.properties --open-api openapi.yaml -d camel-openapi-java --profile Knative
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=camelTerm$$kamel%20run%20--name%20api%20test%2FMinioCustomizer.java%20API.java%20--property-file%20test%2Fminio.properties%20--open-api%20openapi.yaml%20-d%20camel-openapi-java%20--profile%20Knative&completion=Integration%20run. "Opens a new terminal and sends the command above"){.didact})

### 6.2 [Alternative 2] Using the S3 service

To connect the integration to the **AWS S3 service**:

```
kamel run API.java --property-file s3.properties --open-api openapi.yaml -d camel-openapi-java --profile Knative
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=camelTerm$$kamel%20run%20API.java%20--property-file%20s3.properties%20--open-api%20openapi.yaml%20-d%20camel-openapi-java%20--profile%20Knative&completion=Integration%20run. "Opens a new terminal and sends the command above"){.didact})

### 6.3 Test the Knative integrations

Now you can check the integrations to see when they are ready:

```
oc get integrations
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=camelTerm$$oc%20get%20integrations&completion=Getting%20running%20integrations. "Opens a new terminal and sends the command above"){.didact})

When the `api` integration is ready, you should be able to get a route to invoke it.

```
URL=$(oc get routes.serving.knative.dev api -o jsonpath='{.status.url}')
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=camelTerm$$URL%3D%24%28oc%20get%20routes.serving.knative.dev%20api%20-o%20jsonpath%3D%27%7B.status.url%7D%27%29&completion=Getting%20route. "Opens a new terminal and sends the command above"){.didact})

You can print the route to check if it's correct:

```
echo $URL
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=camelTerm$$echo%20$URL&completion=Print%20route. "Opens a new terminal and sends the command above"){.didact})

You can (again) play with it!

Get the list of objects:
```
curl -i $URL/
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=camelTerm$$curl%20-i%20$URL&completion=Use%20the%20API. "Opens a new terminal and sends the command above"){.didact})

Looking at the pods, you should find a pod corresponding to the API integration:

```
oc get pods
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=camelTerm$$oc%20get%20pods&completion=Getting%20running%20pods. "Opens a new terminal and sends the command above"){.didact})

If you wait **at least one minute** without invoking the API, you'll find that the pod will disappear.
Calling the API again will make the pod appear to serve the request.

## 7. Configuring 3Scale (Optional - Requires 3scale)

This optional step allows you to expose the integration in the 3scale API management solution.

Ensure that 3scale is installed and watches the current namespace. We're going to add annotations to the service to allow 3scale to discover the integration 
and manage it. This process is accomplished via the `3scale` trait in Camel K.

### 7.1 [Alternative 1] Using the test Minio server

As alternative, to connect the integration to the **test Minio server**:

```
kamel run --name api test/MinioCustomizer.java API.java --property-file test/minio.properties --open-api openapi.yaml -d camel-openapi-java -t 3scale.enabled=true --profile OpenShift
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=camelTerm$$kamel%20run%20--name%20api%20test%2FMinioCustomizer.java%20API.java%20--property-file%20test%2Fminio.properties%20--open-api%20openapi.yaml%20-d%20camel-openapi-java%20-t%203scale.enabled%3Dtrue%20--profile%20OpenShift&completion=Integration%20run. "Opens a new terminal and sends the command above"){.didact})

### 7.2 [Alternative 2] Using the S3 service

To connect the integration to the **AWS S3 service**:

```
kamel run API.java --property-file s3.properties --open-api openapi.yaml -d camel-openapi-java -t 3scale.enabled=true --profile OpenShift
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=camelTerm$$kamel%20run%20API.java%20--property-file%20s3.properties%20--open-api%20openapi.yaml%20-d%20camel-openapi-java%20-t%203scale.enabled%3Dtrue%20--profile%20OpenShift&completion=Integration%20run. "Opens a new terminal and sends the command above"){.didact})


After the integration is updated, when looking in the 3scale API manager, you should find the new service.