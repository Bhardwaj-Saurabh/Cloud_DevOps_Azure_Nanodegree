variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
  default = "project"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  default = "East US"
}

  
variable "resource_group" {
  description = "Name of the resource group"
  default     = "Azuredevops"
  type        = string
}

variable "tags" {
  description = "A map of the tags to use for the resources that are deployed"
  type        = map(string)
  default = {
    Name = "project"
  }
}

variable "username" {
  description = "Enter username to associate with the machine"
  default     =  "aryan"
} 

variable "password" {
  description = "Enter password to use to access the machine"
  default     = "password@123"
}

variable "packer_resource_group" {
  description = "Resource group of the Packer image"
  default     =  "Azuredevops"
  type        = string
}

variable "packer_image_name" {
  description = "Image name of the Packer image"
  default     =  "Packer-Server-Image"
  type        = string
}

variable "num_of_vms" {
  description = "Number of VM resources to be  created behnd the load balancer"
  default     = 2
  type        = number
}