# Camel K Serverless API Example

This example demonstrates how to write an API based Camel K integration, from the design of the OpenAPI definition
to the implementation of the specific endpoints up to the deployment as serverless API in **Knative**.

In this specific example, the API enables users to store generic objects, such as files, in a backend system, allowing all CRUD operation on them.

The backend is an Amazon AWS S3 bucket that you might provide. In alternative, you'll be given instructions on how to
create a simple [Minio](https://min.io/) backend, which uses a S3 compatible protocol.


### Installing OpenShift Serverless

This demo also needs OpenShift Serverless (Knative) installed and working.

Go to the OpenShift 4.x WebConsole page, use the OperatorHub menu item on the left hand side then find and install **"OpenShift Serverless"**
from a channel that best matches your OpenShift version.

The operator installation page reports links to the documentation where you can find information about **additional steps** that must
be done in order to have OpenShift serverless completely installed into your cluster.

Make sure you follow all the steps in the documentation before continuing to the next section.

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

**OpenShift CLI ("oc")**

The OpenShift CLI tool ("oc") will be used to interact with the OpenShift cluster.

**Connection to an OpenShift cluster**

You need to connect to an OpenShift cluster in order to run the examples.

**Apache Camel K CLI ("kamel")**

Apart from the support provided by the VS Code extension, you also need the Apache Camel K CLI ("kamel") in order to
access all Camel K features.

**Knative installed on the cluster**

The cluster also needs to have Knative installed and working. Refer to steps above for information on how to install it in your cluster.


### Optional Requirements

The following requirements are optional. They don't prevent the execution of the demo, but may make it easier to follow.

**VS Code Extension Pack for Apache Camel**

The VS Code Extension Pack for Apache Camel by Red Hat provides a collection of useful tools for Apache Camel K developers,
such as code completion and integrated lifecycle management. They are **recommended** for the tutorial, but they are **not**
required.

You can install it from the VS Code Extensions marketplace.

## 1. Preparing the project

We'll connect to the `camel-api` project and check the installation status.

To change project, open a terminal tab and type the following command:


```
oc project camel-api
```


We should now check that the operator is installed. To do so, execute the following command on a terminal:

```
oc get csv
```

When Camel K is installed, you should find an entry related to `red-hat-camel-k-operator` in phase `Succeeded`.

You can now proceed to the next section.

## 2. Configuring the object storage backend

You have two alternative options for setting up the S3 backend that will be used to store the objects via the Camel K API:
you can use an existing S3 bucket of your own, or you can set up a local S3 compatible object storage.

### 2.1 [Alternative 1] I don't have a S3 bucket: let's install a Minio backend

The `test` directory contains an all-in-one configuration file for creating a Minio backend that will provide a S3 compatible protocol
for storing the objects.

Open the `test/minio.yaml` file to check its content before applying.

To create the minio backend, just apply the provided file:

```
oc apply -f test/minio.yaml
```

That's enough to have a test object storage to use with the API integration.

### 2.1 [Alternative 2] I have a S3 bucket

If you have a S3 bucket, and you want to use it instead of the test backend, you can do it. The only
things that you need to provide are an **AWS Access Key ID and Secret** that you can obtain from the Amazon AWS console.

Edit the `s3.properties` to set the right value for the properties `camel.component.aws2-s3.region`, `camel.component.aws-s3.access-key` and `camel.component.aws-s3.secret-key`.
Those properties will be automatically injected into the Camel `aw3-s3` component.

## 3. Designing the API

An object store REST API is provided in the `openapi.yaml` file.

It contains operations for:
- Listing the name of the contained objects
- Creating a new object
- Getting the content of an object
- Deleting an object

The file can be edited manually or better using an online editor, such as [Apicurio](https://studio.apicur.io/).

## 4. Running the API integration

The endpoints defined in the API can be implemented in a Camel K integration using a `direct:<operationId>` endpoint.
This has been implemented in the `API.java` file.

To run the integration, you need to link it to the proper configuration, that depends on what configuration you've chosen.

### 4.1 [Alternative 1] Using the test Minio server

As alternative, to connect the integration to the **test Minio server** deployed before:

```
kamel run API.java --open-api file:openapi.yaml --property file:test/minio.properties 
```

### 4.2 [Alternative 2] Using the S3 service

To connect the integration to the **AWS S3 service**:

```
kamel run API.java --open-api file:openapi.yaml --property file:s3.properties 
```

## 5. Using the API

After running the integration API, you should be able to call the API endpoints to check its behavior.

Make sure the integration is running, by checking its status:

```
oc get integrations
```

An integration named `api` should be present in the list, and it should be in status `Running`. There's also a `kamel get` command which is an alternative way to list all running integrations.

NOTE: it may take some time, the first time you run the integration, for it to reach the `Running` state.

After the integration has reached the running state, you can get the route corresponding to it via the following command:

```
URL=$(oc get routes.serving.knative.dev api -o jsonpath='{.status.url}')/v1
```

You can print the route to check if it's correct:

```
echo $URL
```

You can now play with it!

Get the list of objects:
```
curl -i $URL/
```

Upload an object:
```
curl -i -X PUT --header "Content-Type: application/octet-stream" --data-binary "@API.java" $URL/example
```

Get the new list of objects:
```
curl -i $URL/
```

Get the content of a file:
```
curl -i $URL/example
```

Delete the file:
```
curl -i -X DELETE $URL/example
```

Get (again) the new list of objects:
```
curl -i $URL/
```

## 6 Check the serverless behavior

Let's try to get the list of objects:

```
curl -i $URL/
```

After a successful reply, looking at the pods, you should find a pod corresponding to the API integration:

```
oc get pods
```

If you wait **at least one minute** without invoking the API, you'll find that the pod will disappear.

Calling the API again, a new pod will be created to service your request:

```
curl -i $URL/
```

Check again the list of pods. A new pod has been created, and it will be again destroyed in 1 minute if no new requests arrive.

## 7. Configuring 3Scale (Optional - Requires 3scale)

This optional step allows you to expose the integration in the 3scale API management solution.

Ensure that 3scale is installed and watches the current namespace. We're going to add annotations to the service to allow 3scale to discover the integration
and manage it. This process is accomplished via the `3scale` trait in Camel K.

### 7.1 [Alternative 1] Using the test Minio server

As alternative, to connect the integration to the **test Minio server**:

```
kamel run API.java --property file:test/minio.properties --open-api file:openapi.yaml -t 3scale.enabled=true -t 3scale.description-path=/openapi.json --profile OpenShift
```

### 7.2 [Alternative 2] Using the S3 service

To connect the integration to the **AWS S3 service**:

```
kamel run API.java --property file:s3.properties --open-api file:openapi.yaml -t 3scale.enabled=true -t 3scale.description-path=/openapi.json --profile OpenShift
```

After the integration is updated, when looking in the 3scale API manager, you should find the new service.

## 8. Uninstall

To clean up everything, execute the following command:

```oc delete project camel-api```
