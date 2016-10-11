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
    This is a template for the Create script

.DESCRIPTION
	The Create script is used to create objects (users, groups, etc...)
	on a target system. It receives a set of attributes for the object to create.
	If the special OpenICF __NAME__ attribute is set, then it is passed to the connector
	in the special variable Connector.Id.
	The script MUST return the unique identifier of the created object on the target system.
	
.INPUT VARIABLES
	The connector injects a Hashmap into the Create script context with the following items:
	("Connector" is the default name for <prefix>)
	- <prefix>.Configuration : handler to the connector's configuration object
	- <prefix>.Options: a handler to the Operation Options
	- <prefix>.Operation: an OperationType corresponding to the operation ("CREATE" here)
	- <prefix>.ObjectClass: the Object class object (__ACCOUNT__ / __GROUP__ / other)
	- <prefix>.Attributes: A collection of ConnectorAttributes representing the entry attributes
	- <prefix>.Id: Corresponds to the OpenICF __NAME__ attribute if it is provided as part of the attribute set,
	 otherwise null
	
.RETURNS
	Must return the object unique ID (OpenICF __UID__).
	To do so, set the <prefix>.Result.Uid property either as a String or as an OpenICF Uid object.

.NOTES  
    File Name      : CreateTemplate.ps1  
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

# Script may need to decrypt OpenICF GuardedString attributes.
# See: https://forgerock.org/openicf/doc/apidocs/org/identityconnectors/common/security/SecurityUtil.html
$secutil = [Org.IdentityConnectors.Common.Security.SecurityUtil]

# Put your code for the Create User logic here.
# Make sure to return the newly created user unique identifier.
# Be careful, a PowerShell function captures all output
# and returns it in an array once done or call to 'return'.
# So, make sure your code captures any output of cmdlet calls
# and return only the new user unique identifier.
function Create-NewUser ($attributes)
{
	# Attributes Accessor has convenient methods for accessing attributes
	# See: https://forgerock.org/openicf/doc/apidocs/org/identityconnectors/framework/common/objects/AttributesAccessor.html
	$accessor = New-Object Org.IdentityConnectors.Framework.Common.Objects.ConnectorAttributesAccessor($attributes)
	
	# use PowerShell Splatting to prepare the arguments for the specific cmdlet.
	# See: https://technet.microsoft.com/en-us/library/gg675931.aspx
	# For example:
	$param = @{"UserPrincipalName" = $accessor.GetName().GetNameValue()}
	$param.Add("DisplayName", $accessor.FindString("DisplayName"))

	# Quiet often, GuardedString password needs to be converted to Secure String or clear text.
	$password = $accessor.GetPassword()
	If ($password -ne $null)
	{
		$clearText    = $secutil::Decrypt($password)
		$secureString = $password.ToSecureString()
	}

	# Call the target system specific cmdlet and return the unique id of the entry
	# Example:
	# $user = New-User-Cmdlet @param
	# return $user.ObjectId.ToString()
}

# Put your code for the Create Group logic here. 
function Create-NewGroup ($attributes)
{
# apply same logic as Create-NewUser
}


# The script code should always be enclosed within a try/catch block. 
# If any exception is thrown, it is good practice to catch the original exception 
# message and re-throw it within an OpenICF connector exception
try
{
	# Since one script can be used for multiple actions, it is safe to check the operation first.
	if ($Connector.Operation -eq "CREATE")
	{
		Write-Verbose "This is the Create Script"
		# Switch on the different ObjectClass
		switch ($Connector.ObjectClass.Type)
		{
			# Since the Create operation may be a bit complex, it is good
			# practice to put the logic in a dedicated function.
			# The set of attributes is passed to that function.
			# The function MUST return the unique identifier of the created
			# object to set $Connector.Result.Uid.
			"__ACCOUNT__"
			{
				$Connector.Result.Uid = Create-NewUser $Connector.Attributes
			}
			"__GROUP__" 
			{
				$Connector.Result.Uid = Create-NewGroup $Connector.Attributes
			}
			"OtherObject"
			{
				# Put your code here to create other objects
			}
			default
			{
				throw New-Object Org.IdentityConnectors.Framework.Common.Exceptions.ConnectorException("Unsupported type: $($Connector.ObjectClass.Type)")	
			}
		}
	}
	else
	{
		throw New-Object Org.IdentityConnectors.Framework.Common.Exceptions.ConnectorException("CreateScript can not handle operation: $($Connector.Operation)")
	}
}
catch #Re-throw the original exception message within a connector exception
{
	# Before re-throwing, clean up may be done (close file, connections etc...).

	# See https://forgerock.org/openicf/doc/apidocs/org/identityconnectors/framework/common/exceptions/package-frame.html
	# for the list of OpenICF exceptions
	throw New-Object Org.IdentityConnectors.Framework.Common.Exceptions.ConnectorException($_.Exception.Message)
}