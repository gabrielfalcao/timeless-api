provider "aws" {
	access_key = "${env.AWS_ACCESS_KEY_ID}"
	secret_key = "${env.AWS_SECRET_ACCESS_KEY}"
        region = "us-east-1"
}

resource "aws_vpc" "quietness_co_vpc" {
        cidr_block = "172.16.0.0/16"
        tags {
                Name = "quietness_co_vpc"
        }
}

resource "aws_internet_gateway" "quietness_co_igw" {
        vpc_id = "${aws_vpc.quietness_co_vpc.id}"
        tags {
                Name = "quietness_co_igw"
        }
}

# NAT instance

resource "aws_security_group" "quietness_co_nat" {
	name = "nat"
	description = "Allow services from the private subnet through NAT"

	ingress {
		from_port = 0
		to_port = 65535
		protocol = "tcp"
		cidr_blocks = ["${aws_subnet.quietness_co_east-1b-private.cidr_block}"]
	}
	ingress {
		from_port = 0
		to_port = 65535
		protocol = "tcp"
		cidr_blocks = ["${aws_subnet.quietness_co_us-east-1e-private.cidr_block}"]
	}

        vpc_id = "${aws_vpc.quietness_co_vpc.id}"
        tags {
                Name = "quietness_co_nat"
        }
}

resource "aws_instance" "quietness_co_nat" {
	ami = "${var.aws_nat_ami}"
	availability_zone = "us-east-1b"
	instance_type = "m1.small"
	key_name = "${var.aws_key_name}"
	security_groups = ["${aws_security_group.quietness_co_nat.id}"]
	subnet_id = "${aws_subnet.quietness_co_east-1b-public.id}"
	associate_public_ip_address = true
        source_dest_check = false
        tags {
                Name = "quietness_co_nat"
        }
}

resource "aws_eip" "quietness_co_nat" {
	instance = "${aws_instance.quietness_co_nat.id}"
        vpc = true
        tags {
                Name = "quietness_co_nat"
        }
}

# Public subnets

resource "aws_subnet" "quietness_co_east-1b-public" {
	vpc_id = "${aws_vpc.quietness_co_vpc.id}"

	cidr_block = "172.16.0.0/24"
        availability_zone = "us-east-1b"
        tags {
                Name = "quietness_co_nat"
        }

}

resource "aws_subnet" "quietness_co_us-east-1e-public" {
	vpc_id = "${aws_vpc.quietness_co_vpc.id}"

	cidr_block = "172.16.2.0/24"
        availability_zone = "us-east-1e"

        tags {
                Name = "quietness_co_us-east-1e-public"
        }
}

# Routing table for public subnets

resource "aws_route_table" "quietness_co_us-east-1-public" {
	vpc_id = "${aws_vpc.quietness_co_vpc.id}"

	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = "${aws_internet_gateway.quietness_co_igw.id}"
        }
        tags {
                Name = "quietness_co_us-east-1e-public"
        }
}

resource "aws_route_table_association" "quietness_co_east-1b-public" {
	subnet_id = "${aws_subnet.quietness_co_east-1b-public.id}"
	route_table_id = "${aws_route_table.quietness_co_us-east-1-public.id}"
}

resource "aws_route_table_association" "quietness_co_us-east-1e-public" {
	subnet_id = "${aws_subnet.quietness_co_us-east-1e-public.id}"
	route_table_id = "${aws_route_table.quietness_co_us-east-1-public.id}"
}

# Private subsets

resource "aws_subnet" "quietness_co_east-1b-private" {
	vpc_id = "${aws_vpc.quietness_co_vpc.id}"

	cidr_block = "172.16.1.0/24"
	availability_zone = "us-east-1b"
}

resource "aws_subnet" "quietness_co_us-east-1e-private" {
	vpc_id = "${aws_vpc.quietness_co_vpc.id}"

	cidr_block = "172.16.3.0/24"
	availability_zone = "us-east-1e"
}

# Routing table for private subnets

resource "aws_route_table" "quietness_co_us-east-1-private" {
	vpc_id = "${aws_vpc.quietness_co_vpc.id}"

	route {
		cidr_block = "0.0.0.0/0"
		instance_id = "${aws_instance.quietness_co_nat.id}"
        }
        tags {
                Name = "quietness_co_us-east-1-private"
        }
}

resource "aws_route_table_association" "quietness_co_east-1b-private" {
	subnet_id = "${aws_subnet.quietness_co_east-1b-private.id}"
	route_table_id = "${aws_route_table.quietness_co_us-east-1-private.id}"
}

resource "aws_route_table_association" "quietness_co_us-east-1e-private" {
	subnet_id = "${aws_subnet.quietness_co_us-east-1e-private.id}"
	route_table_id = "${aws_route_table.quietness_co_us-east-1-private.id}"
}

# Bastion

resource "aws_security_group" "quietness_co_bastion" {
	name = "quietness_co_bastion"
	description = "Allow SSH traffic from the internet"

	ingress {
		from_port = 22
		to_port = 22
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}

        vpc_id = "${aws_vpc.quietness_co_vpc.id}"
        tags {
                Name = "quietness_co_bastion"
        }
}

resource "aws_instance" "quietness_co_bastion" {
	ami = "${var.aws_ubuntu_ami}"
	availability_zone = "us-east-1b"
	instance_type = "t2.micro"
	key_name = "${var.aws_key_name}"
	security_groups = ["${aws_security_group.quietness_co_bastion.id}"]
        subnet_id = "${aws_subnet.quietness_co_east-1b-public.id}"
        provisioner "local-exec" {
                command = "packer build -var 'aws_access_key=${env.AWS_ACCESS_KEY_ID}' -var 'aws_secret_key=${env.AWS_SECRET_ACCESS_KEY}' bastion.json"
        }
        tags {
                Name = "quietness_co_bastion"
        }
}

resource "aws_eip" "quietness_co_bastion" {
	instance = "${aws_instance.quietness_co_bastion.id}"
	vpc = true
}
