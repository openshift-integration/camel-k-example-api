// camel-k: language=java
package test;

import org.apache.camel.builder.RouteBuilder;
import org.apache.camel.component.aws.s3.S3Component;

import com.amazonaws.auth.AWSCredentials;
import com.amazonaws.auth.AWSCredentialsProvider;
import com.amazonaws.auth.AWSStaticCredentialsProvider;
import com.amazonaws.auth.BasicAWSCredentials;
import com.amazonaws.client.builder.AwsClientBuilder;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3ClientBuilder;

public class MinioConfigurer extends RouteBuilder {
  @Override
  public void configure() throws Exception {

    AwsClientBuilder.EndpointConfiguration endpoint = new AwsClientBuilder.EndpointConfiguration("http://minio:9000", "US_EAST_1");
    AWSCredentials credentials = new BasicAWSCredentials("minio", "minio123");
    AWSCredentialsProvider credentialsProvider = new AWSStaticCredentialsProvider(credentials);

    AmazonS3 client = AmazonS3ClientBuilder.standard()
            .withEndpointConfiguration(endpoint)
            .withCredentials(credentialsProvider)
            .withPathStyleAccessEnabled(true)
            .build();

    S3Component s3 = getContext().getComponent("aws-s3", S3Component.class);
    s3.getConfiguration().setAmazonS3Client(client);

  }
}
