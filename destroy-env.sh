

#!/bin/bash

if [ $# != 1 ]; then
	echo "Please run the script with autoscaling_group_name parameter. Usage: destroy-env.sh autoscaling_group_name"
else
	LoadBalancerName=`aws autoscaling describe-load-balancers --auto-scaling-group-name $1 --output text --query LoadBalancers[*].LoadBalancerName`
	echo "Detaching Load Balancer and updating autoscale group"
	aws autoscaling detach-load-balancers --auto-scaling-group-name $1 --load-balancer-names $LoadBalancerName
	LaunchConfiguration=`aws autoscaling describe-auto-scaling-groups --output text --query AutoScalingGroups[*].Instances[0].LaunchConfigurationName`
	RunningInstances=`aws autoscaling describe-auto-scaling-instances --output text --query AutoScalingInstances[*].InstanceId`
	aws autoscaling update-auto-scaling-group --auto-scaling-group-name $1 --min-size 0 --max-size 0 --desired-capacity 0
	echo "Terminating instances. Please be patient for some time..."
	aws ec2 wait instance-terminated --instance-ids $RunningInstances
	echo "Deleting the Autoscale Group, Launch Configuration and Load Balancer"
	aws autoscaling delete-auto-scaling-group --auto-scaling-group-name $1
	aws autoscaling delete-launch-configuration --launch-configuration-name $LaunchConfiguration
	aws elb delete-load-balancer --load-balancer-name $LoadBalancerName
	echo "Environment destroyed!"

fi
