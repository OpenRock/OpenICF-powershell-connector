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
    This is a template for the Update script

.DESCRIPTION
	The Update script is used to update/patch objects (users, groups, etc...)
	on a target system. It receives a set of attributes to update along with the object unique Id.
	An update can be done in 3 ways:
	- add values to attributes
	- remove values from attributes
	- replace values from attributes.
	See: https://forgerock.org/openicf/doc/apidocs/org/identityconnectors/framework/spi/operations/UpdateAttributeValuesOp.html
	To figure out what kind of update needs to be done, the script relies on the Operation type.
	
	The script MUST return the unique identifier of the updated object on the target system.
	
.INPUT VARIABLES
	The connector injects a Hashmap into the Update script context with the following items:
	("Connector" is the default name for <prefix>)
	- <prefix>.Configuration : handler to the connector's configuration object
	- <prefix>.Options: a handler to the Operation Options
	- <prefix>.Operation: an OperationType corresponding to the operation ("UPDATE"/"ADD_ATTRIBUTE_VALUES"/"REMOVE_ATTRIBUTE_VALUES")
	- <prefix>.ObjectClass: the Object class object (__ACCOUNT__ / __GROUP__ / other)
	- <prefix>.Attributes: A collection of ConnectorAttributes to update.
	- <prefix>.Uid: Corresponds to the OpenICF __UID__ attribute for the entry to update
	
.RETURNS
	Must return the user unique ID (__UID__) of the modified entry.
	To do so, set the <prefix>.Result.Uid property either as a String or as an OpenICF Uid object.

.NOTES  
    File Name      : UpdateTemplate.ps1  
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

# Put your code for the Update User logic here.
# Make sure to return the object unique identifier.
# Be careful, a PowerShell function captures all output
# and returns it in an array once done or call to 'return'.
# So, make sure your code captures any output of cmdlet calls
# and return only the object unique identifier.

function Update-User ($attributes)
{
	# Attributes Accessor has convenient methods for accessing attributes
	# See: https://forgerock.org/openicf/doc/apidocs/org/identityconnectors/framework/common/objects/AttributesAccessor.html
	$accessor = New-Object Org.IdentityConnectors.Framework.Common.Objects.ConnectorAttributesAccessor($attributes)
	
	# use PowerShell Splatting to prepare the arguments for cmdlets.
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

	# If the object UID has not been modified, return the original Uid.
	$Connector.Uid
}


function Add-Attributes-User ($attributes)
{
	# Put your code here

	# If the object UID has not been modified, return the original Uid.
	$Connector.Uid
}

function Remove-Attributes-User ($attributes)
{
	# Put your code here

	# If the object UID has not been modified, return the original Uid.
	$Connector.Uid
}


function Update-Group ($attributes)
{
	# Put your code here

	# If the object UID has not been modified, return the original Uid.
	$Connector.Uid
}

function Add-Attributes-Group ($attributes)
{
	# Put your code here

	# If the object UID has not been modified, return the original Uid.
	$Connector.Uid
}

function Remove-Attributes-Group ($attributes)
{
	# Put your code here

	# If the object UID has not been modified, return the original Uid.
	$Connector.Uid
}

# The script code should always be enclosed within a try/catch block. 
# If any exception is thrown, it is good practice to catch the original exception 
# message and re-throw it within an OpenICF connector exception
try
{
	# An update may be done in 3 different ways:
	# - replace/update attributes
	# - add attribute values
	# - remove attribute values
	# so the script can deal with the 3 different actions.
	# You may not want to implement the 3 actions, depending on the target system.
	# In that case, remove not needed actions in the following switch.
	switch ($Connector.Operation)
	{
		"UPDATE"
		{
			Write-Verbose "This is the Update Script (UPDATE action)"
			switch ($Connector.ObjectClass.Type)
			{
				# Since the Update operation may be a bit complex, it is good
				# practice to put the logic in a dedicated function.
				# The set of attributes to update is passed to that function.
				# The function MUST return the unique identifier of the updated
				# object to set $Connector.Result.Uid.

				"__ACCOUNT__"
				{
					$Connector.Result.Uid = Update-User $Connector.Attributes
				}
				"__GROUP__" 
				{
					$Connector.Result.Uid = Update-Group $Connector.Attributes
				}
				"OtherObject"
				{
					# Put your code here to update other objects
				}
				default
				{
					throw New-Object Org.IdentityConnectors.Framework.Common.Exceptions.ConnectorException("Unsupported type: $($Connector.ObjectClass.Type)")	
				}
			}

		}
		"ADD_ATTRIBUTE_VALUES"
		{
			Write-Verbose "This is the Update Script (ADD_ATTRIBUTE_VALUES action)"
			switch ($Connector.ObjectClass.Type)
			{
				"__ACCOUNT__"
				{
					$Connector.Result.Uid = Add-Attributes-User $Connector.Attributes
				}
				"__GROUP__" 
				{
					$Connector.Result.Uid = Add-Attributes-Group $Connector.Attributes
				}
				"OtherObject"
				{
					# Put your code here to update other objects
				}
				default
				{
					throw New-Object Org.IdentityConnectors.Framework.Common.Exceptions.ConnectorException("Unsupported type: $($Connector.ObjectClass.Type)")	
				}
			}
		}
		"REMOVE_ATTRIBUTE_VALUES"
		{
			Write-Verbose "This is the Update Script (REMOVE_ATTRIBUTE_VALUES action)"
			switch ($Connector.ObjectClass.Type)
			{
				"__ACCOUNT__"
				{
					$Connector.Result.Uid = Remove-Attributes-User $Connector.Attributes
				}
				"__GROUP__" 
				{
					$Connector.Result.Uid = Remove-Attributes-Group $Connector.Attributes
				}
				"OtherObject"
				{
					# Put your code here to update other objects
				}
				default
				{
					throw New-Object Org.IdentityConnectors.Framework.Common.Exceptions.ConnectorException("Unsupported type: $($Connector.ObjectClass.Type)")	
				}
			}
		}
		default
		{
			throw New-Object Org.IdentityConnectors.Framework.Common.Exceptions.ConnectorException("UpdateScript can not handle operation: $($Connector.Operation)")
		}
	}
}
catch #Re-throw the original exception message within a connector exception
{
	# Before re-throwing, clean up may be done (close file, connections etc...).

	# See https://forgerock.org/openicf/doc/apidocs/org/identityconnectors/framework/common/exceptions/package-frame.html
	# for the list of OpenICF exceptions
	throw New-Object Org.IdentityConnectors.Framework.Common.Exceptions.ConnectorException($_.Exception.Message)
}