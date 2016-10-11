# The contents of this file are subject to the terms of the Common Development and
# Distribution License (the License). You may not use this file except in compliance with the
# License.
#
# You can obtain a copy of the License at legal/CDDLv1.0.txt. See the License for the
# specific language governing permission and limitations under the License.
#
# When distributing Covered Software, include this CDDL Header Notice in each file and include
# the License file at legal/CDDLv1.0.txt. If applicable, add the following below the CDDL
# Header, with the fields enclosed by brackets [] replaced by your own identifying
# information: "Portions copyright [year] [name of copyright owner]".
#
# Copyright 2016 ForgeRock AS.
#
#REQUIRES -Version 2.0

<#  
.SYNOPSIS  
    This is a template for the Delete script
	
.DESCRIPTION
	The Delete script is used to remove/delete objects (users, groups, etc...)
	on a target system. It receives the UID of the object to delete. 
	It is not expected to return any value.
	
.INPUT VARIABLES
	The connector injects a Hashmap into the Delete script context with the following items:
	("Connector" is the default name for <prefix>)
	- <prefix>.Configuration : handler to the connector's configuration object
	- <prefix>.Options: a handler to the Operation Options
	- <prefix>.Operation: an OperationType corresponding to the operation ("DELETE" here)
	- <prefix>.ObjectClass: the Object class object (__ACCOUNT__ / __GROUP__ / other)
	- <prefix>.Uid: the Uid (__UID__) of the object to delete
	
.RETURNS 
	Nothing.
	
.NOTES  
    File Name      : DeleteTemplate.ps1
    Author         : Gael Allioux (gael.allioux@forgerock.com)
    Prerequisite   : PowerShell V2 and later
    Copyright      : 2016 - ForgeRock AS    

.LINK  
    OpenICF
    http://openicf.forgerock.org
	
	OpenICF Javadoc
	https://forgerock.org/openicf/doc/apidocs/
#>

# Preferences variables can be set here.
# See https://technet.microsoft.com/en-us/library/hh847796.aspx
$ErrorActionPreference = "Stop"
$VerbosePreference     = "Continue"

# The script code should always be enclosed within a try/catch block. 
# If any exception is thrown, it is good practice to catch the original exception 
# message and re-throw it within an OpenICF connector exception
try
{
	# Since one script can be used for multiple actions, it is safe to check the operation first.
	if ($Connector.Operation -eq "DELETE")
	{
		Write-Verbose "This is the Delete Script"
		# Switch on the different ObjectClass
		switch ($Connector.ObjectClass.Type)
		{
			"__ACCOUNT__"  
			{
				# Put your code here to delete the account
				# Use the value of the entry UID with 
				# $Connector.Uid.GetUidValue()
			}
			"__GROUP__"    
			{ 
				# Put your code here to delete the group
			}
			"OtherObject"
			{
				# Put your code here to delete other objects
			}
			# Throw an exception if the ObjectClass is not handled by the script
			default 
			{
				throw New-Object Org.IdentityConnectors.Framework.Common.Exceptions.ConnectorException("Unsupported type: $($Connector.ObjectClass.Type)")
			}
		}
	}
	else
	{
		throw New-Object Org.IdentityConnectors.Framework.Common.Exceptions.ConnectorException("DeleteScript can not handle operation: $($Connector.Operation)")
	}
}
catch #Re-throw the original exception message within a connector exception
{
	# Before re-throwing, clean up may be done (close file, connections etc...).

	# See https://forgerock.org/openicf/doc/apidocs/org/identityconnectors/framework/common/exceptions/package-frame.html
	# for the list of OpenICF exceptions
	throw New-Object Org.IdentityConnectors.Framework.Common.Exceptions.ConnectorException($_.Exception.Message)
}