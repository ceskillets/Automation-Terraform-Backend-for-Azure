# terraform-backend-azurerm
A Terraform plan for building a state locking backend in Azure.

## Background
By default, Terraform stores [state](https://www.terraform.io/docs/state/index.html) information about the infrastructure it manages in a local file named `terraform.tfstate`.  Any modifications to infrastructure definitions will reference this state information and update it once the required changes have been implemented.  However, local state management is not suitable for team collaboration.  Each team member would need a current copy of the state file.  Even then, they would need to ensure that only one team member at a time can make changes to the infrastructure in order to avoid conflicting changes.

Fortunately, Terraform supports [remote state](https://www.terraform.io/docs/state/remote.html) management using a number of different [backend](https://www.terraform.io/docs/backends) solutions in which to centrally store state information.  Many of these backends also support [state locking](https://www.terraform.io/docs/state/locking.html) to ensure that only one team member at a time can make changes to the infrastructure.

## Implementation
The Terraform plan contained in this repository will create a backend in Azure for state file storage and locking operations.  This backend can be creating using the following steps:

1. Clone the repository to your local machine.

```bash
$ git clone https://github.com/stealthllama/terraform-backend-azurerm.git
```

2. Change into the repository directory.

```bash
$ cd terraform-backend-azurerm
```

3. Create a `terraform.tfvars` file containing the variables defined in `variables.tf` and their values.

```bash
azure_subscription_id = "MY_SUBSCRIPTION_ID"
azure_tenant_id = "MY_TENANT_ID"
azure_client_id = "MY_CLIENT_ID"
azure_client_secret = "MY_CLIENT_SECRET"
azure_location = "eastus"
```
4. Initialize the Terraform provider.

```bash
$ terraform init
```

5. Validate the Terraform plan.

```bash
$ terraform plan
```

6. Implement the Terraform plan.

```bash
$ terraform apply
```

The Terraform plan will output the name of the Azure storage account, container name, and access key used for state storage and locking.  These values will be referenced in other Terraform plans that utilize this backend.

```bash
Apply complete! Resources: 4 added, 0 changed, 0 destroyed.

Outputs:

storage_account_name = tfstate37589
container_name = tfstate
access_key = SUPERSECRETKEY
```

## Usage
Once the backend has been created it can be used by another Terraform plan.  However, it is recommended that you create a separate backend for each Terraform project in order to ensure state files in the backend are not overwritten.

To use this backend in a Terraform plan you will define a `backend` configuration such as the following either in an existing Terraform plan file or in a separate `backend.tf` file within the project directory:

```hcl
terraform {
  backend "azurerm" {
    storage_account_name    = "tfstate37589"
    container_name          = "tfstate"
    key                     = "terraform.tfstate"
    access_key              = "SUPERSECRETKEY"
  }
}
```

Once included in a Terraform plan the backend will need to be initialized with the remainder of the plan.  The output of the `terraform init` command should include the following output:

```
Initializing the backend...

Successfully configured the backend "azurerm"! Terraform will automatically
use this backend unless the backend configuration changes.
```

From this point forward any Terraform commands issued within the project directory will reference the state information contained in the backend storage.  All commands will also acquire a state lock in order to ensure the requestor has exclusive access to the state information.  The lock will then be released once the command actions have completed.

Happy Terraforming!
