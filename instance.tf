# Create an EC2 instance with provided parameters
resource "aws_instance" "my_ec2" {
  ami           = var.EC2_AMI      # Replace with your AMI ID
  instance_type = var.EC2_type  # Replace with your instance type
  key_name      = var.EC2_key # Replace with your key pair name
  subnet_id     = "subnet-04c184658d26881db"      # Replace with your subnet ID
  vpc_security_group_ids = var.EC2_SecurityGroupIDs # Provide security group IDs
  iam_instance_profile = var.EC2_Role

  # Attach additional EBS volumes
  root_block_device {
    volume_size = 80   # Root volume size in GB, change it if needed
    volume_type = "gp2"  # General purpose SSD (gp2), can change based on your requirements
      # Dynamically using the same tags as the EC2 instance
  tags = var.EC2_tags
  }

  # First additional storage volume
  ebs_block_device {
    device_name = "/dev/sdd"  # The device name for the first volume
    volume_size = 50          # Volume size in GB, change as needed
    volume_type = "gp2"       # Can be "gp2", "io1", etc. depending on your use case
  }


  # Enable termination protection (disable API termination)
  disable_api_termination = true  # Protects against accidental termination

  # Enable stop protection (stops the instance on shutdown)
  instance_initiated_shutdown_behavior = "stop"  # Stops the instance when an OS shutdown occurs, instead of terminating

  # Set instance tags
  tags = var.EC2_tags

  # Optional: If you want to associate the instance with a public IP
  associate_public_ip_address = true

  user_data = <<-EOF

<powershell>

# User Data PowerShell Script for Windows EC2

# Set Execution Policy to allow scripts to run
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

try {
    # Set timezone to EST
    Set-TimeZone -Name 'Eastern Standard Time'
    Write-Host "Timezone set to Eastern Standard Time."

    # Initialize and partition offline disks using GPT
    $offlineDisks = Get-Disk | Where-Object { $_.OperationalStatus -eq 'Offline' }
    Write-Host "Offline disks found: $($offlineDisks.Count)"
    
    foreach ($disk in $offlineDisks) {
        # Bring the disk online
        Set-Disk -Number $disk.Number -IsOffline $false
        Write-Host "Disk $($disk.Number) is now online."

        # Initialize the disk with GPT if not already initialized
        if ($disk.PartitionStyle -ne 'GPT') {
            Initialize-Disk -Number $disk.Number -PartitionStyle GPT
            Write-Host "Disk $($disk.Number) initialized with GPT."
        } else {
            Write-Host "Disk $($disk.Number) is already initialized with GPT."
        }

        # Create a new partition using maximum space and assign a drive letter
        $newPartition = New-Partition -DiskNumber $disk.Number -UseMaximumSize -AssignDriveLetter
        Write-Host "Created new partition on disk $($disk.Number)."

        # Format the partition with NTFS
        Format-Volume -DriveLetter $newPartition.DriveLetter -FileSystem NTFS -Confirm:$false
        Write-Host "Disk $($disk.Number) formatted with NTFS."
    }

  #Rename the instance using tags in instance metadata.
  [string]$token = Invoke-RestMethod -Headers @{"X-aws-ec2-metadata-token-ttl-seconds" = "21600"} -Method PUT -Uri 'http://169.254.169.254/latest/api/token' -UseBasicParsing
  $instanceId = Invoke-RestMethod -Headers @{"X-aws-ec2-metadata-token" = $token} -Method GET -Uri 'http://169.254.169.254/latest/meta-data/instance-id' -UseBasicParsing
	$nameValue = (Get-EC2Tag -Filter @{Name="resource-id";Value=$instanceid},@{Name="key";Value="Name"}).Value
	$pattern = "^(?![0-9]{1,15}$)[a-zA-Z0-9-]{1,15}$"
	#Verify Name Value satisfies best practices for Windows hostnames
	If ($nameValue -match $pattern) 
	    {Try
	        {Rename-Computer -NewName $nameValue -Restart -ErrorAction Stop} 
	    Catch
	        {$ErrorMessage = $_.Exception.Message
	        Write-Output "Rename failed: $ErrorMessage"}}
	Else
	    {Throw "Provided name not a valid hostname. Please ensure Name value is between 1 and 15 characters in length and contains only alphanumeric or hyphen characters"}

}
catch {
    Write-Host "Error: $_"
    $_ | Out-File "C:\windows\logfile.txt"
}

</powershell>

            EOF

}



