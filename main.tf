resource "azurerm_resource_group" "tfdevgs" {
  name     = "tfdevrg"
  location = "North Europe"
}

resource "azurerm_virtual_network" "tfdevgs" {
  name                = "tfvnet"
  address_space       = ["10.0.0.0/16"]
  location            = "${azurerm_resource_group.tfdevgs.location}"
  resource_group_name = "${azurerm_resource_group.tfdevgs.name}"
}

resource "azurerm_subnet" "tfdevgs" {
  name                 = "tfsubnet"
  resource_group_name  = "${azurerm_resource_group.tfdevgs.name}"
  virtual_network_name = "${azurerm_virtual_network.tfdevgs.name}"
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_network_interface" "tfdevgs" {
  name                = "tfnet"
  location            = "${azurerm_resource_group.tfdevgs.location}"
  resource_group_name = "${azurerm_resource_group.tfdevgs.name}"

  ip_configuration {
    name                          = "tfipconfigdev"
    subnet_id                     = "${azurerm_subnet.tfdevgs.id}"
    private_ip_address_allocation = "dynamic"
  }
}

resource "azurerm_managed_disk" "tfdevgs" {
  name                 = "tddev_data"
  location             = "${azurerm_resource_group.tfdevgs.location}"
  resource_group_name  = "${azurerm_resource_group.tfdevgs.name}"
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1023"
}

resource "azurerm_virtual_machine" "tfdevgs" {
  name                  = "tfdevgsvm"
  location              = "${azurerm_resource_group.tfdevgs.location}"
  resource_group_name   = "${azurerm_resource_group.tfdevgs.name}"
  network_interface_ids = ["${azurerm_network_interface.tfdevgs.id}"]
  vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "tfosdiskdev"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_data_disk {
    name              = "tfdevdata"
    managed_disk_type = "Standard_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "1023"
  }

  os_profile {
    computer_name  = "tfdevgs"
    admin_username = "admchso"
    admin_password = "Test11!!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags {
    environment = "dev"
  }
}
