#!/bin/bash

if [ $# != 5 ]; then
	echo "Please run the script with following parameters: ami_id key_name security_group launch_configuration_name count"
else
	echo "Creating Load Balancer, LoadBalancer Policy"
	aws elb create-load-balancer --load-balancer-name loadBalancer --listeners Protocol=http,LoadBalancerPort=80,InstanceProtocol=http,InstancePort=80 --availability-zones "us-west-2b"
	aws elb create-load-balancer-policy --load-balancer-name loadBalancer --policy-name nxtGenBalancerPolicy --policy-type-name ProxyProtocolPolicyType --policy-attributes AttributeName=ProxyProtocol,AttributeValue=true
	echo "Configuring Launch Policy and Autoscale Group"
	aws autoscaling create-launch-configuration --launch-configuration-name $4 --image-id $1 --key-name $2 --security-groups $3 --instance-type t2.micro --user-data file://installenv.sh --placement AvailabilityZone=us-west-2b --placement-tenancy default
	aws autoscaling create-auto-scaling-group --launch-configuration-name $4 --auto-scaling-group-name autoScaleGroup --min-size 2 --max-size 5 --desired-capacity 4 --availability-zones "us-west-2b"
	echo "Attaching the Load Balancer to Autoscale Group"
	aws autoscaling attach-load-balancers --auto-scaling-group-name autoScaleGroup --load-balancer-names loadBalancer
	echo "Webserver ready!"
fi
