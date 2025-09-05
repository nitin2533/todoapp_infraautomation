module "resource_group_name" {
  source = "../module/azurerm_rg"

  rg_name  = "anchorage_rgroup1"
  location = "Japan East"
}

module "vnet" {
  depends_on = [module.resource_group_name]
  source     = "../module/azurerm_vnet"

  virtual_network_name = "anchorage_vnet"
  address_space        = ["192.168.0.0/16"]
  location             = "Japan East"
  rg_name              = "anchorage_rgroup1"
}

variable "subnet_config" {
  type = map(any)
  default = {
    "frontend" = {
      name             = "anchorage_subnet_frontend"
      address_prefixes = ["192.168.1.0/24"]
    }
    "backend" = {
      name             = "anchorage_subnet_backend"
      address_prefixes = ["192.168.2.0/24"]
    }
  }
}
module "subnet" {
  for_each             = var.subnet_config
  depends_on           = [module.vnet]
  source               = "../module/azurerm_subnet"
  name                 = each.value.name
  rg_name              = "anchorage_rgroup1"
  virtual_network_name = "anchorage_vnet"
  address_prefixes     = each.value.address_prefixes
}

/*module "subnet_backend" {
  depends_on = [module.vnet]
  source     = "./azurerm_subnet"
  name                 = "polaris_subnet_backend"
  rg_name              = "polaris_rgroup"
  virtual_network_name = "polaris_vnet"
  address_prefixes     = ["192.168.2.0/24"]
}

variable "pip" {
  type = map(string)
  default = {
    "frontend" = "polaris_pip_frontend"
    "backend"  = "polaris_pip_backend"
  }
}

module "public_ip" {
  for_each   = var.pip
  source     = "../module/azurerm_public-ip"
  depends_on = [module.resource_group_name]
  name       = each.value
  location   = "Japan East"
  rg_name    = "polaris_rgroup"
}

module "public_ip_backend" {
  source     = "./azurerm_public-ip"
  depends_on = [module.resource_group_name]
  name       = "polaris_pip_backend"
 location   = "Japan East"
  rg_name    = "polaris_rgroup"
}

variable "nic_config" {
  type = map(any)
  default = {
    "frontend" = {
      name      = "nic-frontend"
      subnet    = "polaris_subnet_frontend"
      public_ip = "polaris_pip_frontend"
    }
    "backend" = {
      name      = "nic-backend"
      subnet    = "polaris_subnet_backend"
      public_ip = "polaris_pip_backend"
    }
  }
}
module "nic" {
  for_each             = var.nic_config
  source               = "../module/azurerm_nic"
  depends_on           = [module.subnet, module.public_ip]
  name                 = each.value.name
  location             = "Japan East"
  rg_name              = "polaris_rgroup"
  subnet               = each.value.subnet
  public_ip            = each.value.public_ip
  virtual_network_name = "polaris_vnet"
}
module "nic-backend" {
  source               = "./azurerm_nic"
  depends_on           = [module.subnet_backend, module.public_ip_backend]
  name                 = "nic-backend"
   location   = "Japan East"
  rg_name    = "polaris_rgroup"
  subnet               = "polaris_subnet_backend"
  public_ip            = "polaris_pip_backend"
  virtual_network_name = "polaris_vnet"
}

variable "vm_config" {
  type = map(any)
  default = {
    "frontend" = {
      nic_name       = "nic-frontend"
      admin_username = "frontendadmin"
      admin_password = "frontendpass"
      publisher      = "Canonical"
      offer          = "0001-com-ubuntu-server-jammy"
      sku            = "22_04-lts"
      custom_data    = <<-EOF
        #!/bin/bash
        sudo apt update
        sudo apt install -y nginx
        sudo systemctl enable nginx
        sudo systemctl start nginx
      EOF
    }
    "backend" = {
      nic_name       = "nic-backend"
      admin_username = "backendadmin"
      admin_password = "backendpass"
      publisher      = "Canonical"
      offer          = "0001-com-ubuntu-server-focal"
      sku            = "20_04-lts"
      custom_data    = <<-EOF
        #!/bin/bash
        sudo apt update
        sudo apt install -y python3 python3-pip
      EOF

    }
  }
}
module "virtual_machine" {
  depends_on             = [module.subnet, module.nic]
  for_each               = var.vm_config
  source                 = "../module/azurerm_vm"
  name                   = "polaris-${each.key}vm"
  rg_name                = "polaris_rgroup"
  network_interface_name = each.value.nic_name
  key_vault_name         = "polaris-key"
  admin_username         = each.value.admin_username
  admin_password         = each.value.admin_password
  location               = "Japan East"
  publisher              = each.value.publisher
  offer                  = each.value.offer
  sku                    = each.value.sku
  custom_data            = base64encode(each.value.custom_data)
}

module "virtual_machine_backend" {
  depends_on = [module.subnet_backend, module.nic-backend]

  source = "./azurerm_vm"

  name                   = "polaris-backendvm"
  rg_name                = "polaris_rgroup"
  network_interface_name = "nic-backend"
  key_vault_name         = "polaris-key"
  admin_username         = "backendadmin"
  admin_password         = "backendpass"
  location               = "Japan East"
  publisher              = "Canonical"
  offer                  = "0001-com-ubuntu-server-jammy"
  sku                    = "22_04-lts"


  custom_data = base64encode(<<-EOF
              #!/bin/bash
              sudo apt update
              sudo apt install -y python3 python3-pip
              EOF
  )
} 

module "server" {
  depends_on      = [module.resource_group_name]
  source          = "../module/azurerm_sql-server"
  sql_server_name = "polaris-server"
  rg_name         = "polaris_rgroup"
  location        = "Japan East"
  key_vault_name  = "polaris-key"
  admin_username  = "dbadmin"
  admin_password  = "dbpass"
}

module "database" {
  depends_on        = [module.server]
  source            = "../module/azurerm_sql-database"
  sql_database_name = "polaris-database"
  sql_server_name   = "polaris-server"
  rg_name           = "polaris_rgroup"
}*/
