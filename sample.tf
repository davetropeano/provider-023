# Configure the IBM Cloud Provider
provider "ibmcloud" {
  bluemix_api_key    = "${var.ibmcloud_bmx_api_key}"
  softlayer_username = "${var.ibmcloud_sl_username}"
  softlayer_api_key  = "${var.ibmcloud_sl_api_key}"
}

# Create an SSH key. The SSH key surfaces in the SoftLayer console under Devices > Manage > SSH Keys.
resource "ibmcloud_infra_ssh_key" "test_key_1" {
  label      = "test_key_1"
  public_key = "${file(\"~/.ssh/id_rsa_test_key_1.pub\")}"

  # Windows example:
  # public_key = "${file(\"C:\ssh\keys\path\id_rsa_test_key_1.pub\")}"
}

# Virtual server created with above ssh key
resource "ibmcloud_infra_virtual_guest" "my_server_2" {
  hostname          = "host-b.example.com"
  domain            = "example.com"
  ssh_keys          = [123456, "${ibmcloud_infra_ssh_key.test_key_1.id}"]
  os_reference_code = "CENTOS_6_64"
  datacenter        = "ams01"
  network_speed     = 10
  cores             = 1
  memory            = 1024
}

# Read details of IBM Bluemix Space
data "ibmcloud_cf_space" "space" {
  space = "${var.space}"
  org   = "${var.org}"
}

# Create Cloud Foundry Service Instance
resource "ibmcloud_cf_service_instance" "service" {
  name       = "${var.instance_name}"
  space_guid = "${data.ibmcloud_cf_space.space.id}"
  service    = "cleardb"
  plan       = "spark"
  tags       = ["cluster-service", "cluster-bind"]
}
