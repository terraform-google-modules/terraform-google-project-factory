# Simple project with GKE shared VPC

This example illustrates how to create a project with a shared VPC from a host project that is GKE suitable.

As shown in this exmaple, GKE shared VPC is only enabled if the "container.googleapis.com" API is in the "activate_apis" variable list.

It will do the following:
- Create a project
- Create a Gsuite group
- Give members of the newly created Gsuite group the appropriate access on the project
- Make APIs service account member of api_sa_group in Gsuite

Expected variables:
- `gsuite_admin_user`
- `org_id`
- `billing_account`
- `shared_vpc`

To specify a subnet use the "shared_vpc_subnets" variable, and list subnets like the following:
- ["projects/<my-project-id>/regions/<my-region>/subnetworks/<subnet-one-id>", "projects/<my-project-id>/regions/<my-region>/subnetworks/<subnet-two-id>"]

If no subnets are specified, all networks and subnets from the host project are shared.