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
`aws eks --region eu-west-1 update-kubeconfig \
    --name example` (be sure to set the region and name aligned with your own setup)
9. Once set up, check cluster connectivity by running `kubectl cluster-info`. The output must list the endpoint, matching to the `terraform apply` output named `cluster_endpoint`. You can also run `kubectl get nodes -o wide` to list nodes info.
10. Go to [workload](./workload/) directory, and run each manifest like ```sh
kubectl apply -f backend-deployment.yaml
kubectl apply -f backend-service.yaml
kubectl apply -f frontend-deployment.yaml
kubectl apply -f frontend-service.yaml
```

