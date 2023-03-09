# Terraform provider Azure

terraform {
  required_version = ">=v1.1.3, <2.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0.0, <4.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}