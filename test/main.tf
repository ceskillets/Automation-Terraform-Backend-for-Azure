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


provider "azurerm" {
  version                   = "~> 1.30"
  subscription_id           = "${var.azure_subscription_id}"
  tenant_id                 = "${var.azure_tenant_id}"
  client_id                 = "${var.azure_client_id}"
  client_secret             = "${var.azure_client_secret}"
}

resource "azurerm_resource_group" "test-rg" {
  name     = "test-rg"
  location = "${var.azure_location}"
  tags = {
    environment = "Terraform State Testing"
  }
}

resource "azurerm_virtual_network" "test-net" {
  name                = "test-network"
  address_space       = ["10.0.0.0/16"]
  location            = "${azurerm_resource_group.test-rg.location}"
  resource_group_name = "${azurerm_resource_group.test-rg.name}"
}

resource "azurerm_subnet" "test-sub" {
  name                 = "internal"
  resource_group_name  = "${azurerm_resource_group.test-rg.name}"
  virtual_network_name = "${azurerm_virtual_network.test-net.name}"
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_network_interface" "test-nic" {
  name                = "test-nic"
  location            = "${azurerm_resource_group.test-rg.location}"
  resource_group_name = "${azurerm_resource_group.test-rg.name}"

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = "${azurerm_subnet.test-sub.id}"
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "test-vm" {
  name                  = "test-vm"
  location              = "${azurerm_resource_group.test-rg.location}"
  resource_group_name   = "${azurerm_resource_group.test-rg.name}"
  network_interface_ids = ["${azurerm_network_interface.test-nic.id}"]
  vm_size               = "Standard_DS1_v2"

  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "testsrv"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "test server"
  }
}
