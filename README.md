# Instructions
Note: This assumes that you have an AWS account, IAM user with required permissions, and its credentials were set up as a profile for [aws-cli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-quickstart.html#getting-started-quickstart-new-command), and you have **kubectl** installed.

Be sure to set correct values to the required fields on;

1. [backend.tf](backend.tf) for the remote state bucket and prefix (you'll need to create the bucket beforehand)
2. [main.tf](main.tf#L3-L6) also has some lines that needs modification according to the region and AZs you'll be using
3. Again [main.tf](main.tf#L19-21) should match the configuration on the [backend.tf](backend.tf)
4. Before running the terraform commands, export your AWS_PROFILE like:
`export AWS_PROFILE=your_profile_name`

5. Then, go to the root path and run : `terraform init`
6. If step 5 is successfull, run `terraform plan`. It should be adding ~37 resources. Inspect the output, and if it's listing all the intended resources, carry on with the next step.
7. Run `terraform apply` and wait for it to finish. Inspect the outputs. It should include `natgw_outbound_ips`, listing the outbound IP addresses of the EKS cluster. These IP addresses can be used for any kind of IP allowlisting.
8. To be able to interact with your EKS cluster, setup your kubeconfig by running;
`aws eks --region eu-west-1 update-kubeconfig
    --name example` (be sure to set the region and name aligned with your own setup)
9. Once set up, check cluster connectivity by running `kubectl cluster-info`. The `Kubernetes control plane` line on the output must list the endpoint, matching to the `terraform apply` output named `cluster_endpoint`. You can also run `kubectl get nodes -o wide` to list nodes info.
10. Go to [workload](./workload/) directory, and run `kubectl apply` for each manifest 

```sh
kubectl apply -f backend-deployment.yaml
kubectl apply -f backend-service.yaml
kubectl apply -f frontend-deployment.yaml
kubectl apply -f frontend-service.yaml
```
11. If the above commands succeed, run `kubectl get svc frontend` and get the `EXTERNAL-IP` column for the service URL, exposed publicly. Let's assume the URL is `a89e305127e4a4f54b0d3fe1e12ac29e-674045712.eu-west-1.elb.amazonaws.com`. Check the availability of the URL by running:
`curl http://a89e305127e4a4f54b0d3fe1e12ac29e-674045712.eu-west-1.elb.amazonaws.com`. It should print "{"message":"Hello"}"

Here's a summary of what we've created with the steps above:

* A VPC
* Private and public subnets on 3 different AZs
* An EKS cluster with 3 nodes spread across these private subnets
* 3 NAT gateways on 3 different public subnets
* An internet gateway, attached to the VPC
* Route tables for private subnets, pointing to the NAT gateways, for the default route
* Route tables for the public subnets, pointing to the internet gateway, for the default route
* Route table associations for the related subnet / route table pairs
* Private EKS nodes can reach the internet, with 3 NAT gateway IP addresses from 3 AZs
* Backend service is not exposed to the public, and not reachable
* Frontend service is exposed to the public, and reachable
* Both deployments are scalable (replica count can be tuned), and highly available (multi-az setup)

What can be improved?
1. We can add anti-affinity definitions to the deployment manifests to guarantee each replicas' provisioning to a separate node
2. We can improve the way we call subnet.ids from the module on [main.tf](main.tf#L31-33), by directly calling the output from the module and not calling it from the remote state.