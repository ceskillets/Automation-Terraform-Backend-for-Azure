############################################################################################
# Copyright 2019 Palo Alto Networks.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
############################################################################################

output "storage_account_name" {
    value = "${azurerm_storage_account.tfstate-sa.name}"
    description = "Terraform backend storage account"
}

output "access_key" {
    value = "${azurerm_storage_account.tfstate-sa.primary_access_key}"
    description = "Terraform backend storage account access key"
}

output "container_name" {
    value = "${azurerm_storage_container.tfstate-blob.name}"
    description = "Terraform backend storage container name"
}
