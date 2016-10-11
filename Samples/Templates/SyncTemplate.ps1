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
    This is a template for the Sync script
	
.DESCRIPTION
	The Sync script is used to fetch the objects that changed, that have been
	created or deleted on a target system.
	Each change is returned to the connector along with a "sync token" (timestamp, index...)
	in a "streamed" way. 
	
.INPUT VARIABLES
	The connector injects a Hashmap into the Sync script context with the following items:
	("Connector" is the default name for <prefix>)
	- <prefix>.Configuration : handler to the connector's configuration object
	- <prefix>.Options: a handler to the Operation Options
	- <prefix>.Operation: an OperationType corresponding to the operation ("SYNC" or "GET_LATEST_SYNC_TOKEN" here)
	- <prefix>.ObjectClass: the Object class object (__ACCOUNT__ / __GROUP__ / other)
	- <prefix>.Token: The current sync token value

.RETURNS
	if Operation is "GET_LATEST_SYNC_TOKEN":
	Must return an object representing the last known sync token for the corresponding ObjectClass
	
	if Operation is "SYNC":
    Changes should be returned to the connector by calling Connector.Results.Process(Hashtable|SyncDelta)
  
.NOTES  
    File Name      : SyncTemplate.ps1  
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

# Like for the Search script, define a filter to process Sync results through a pipe and feed the sync result handler.
# The special $_ is used. It contains the object passed to the filter.
filter Process-Sync {
	# The script must return either a SyncDelta object or a predefined HashTable 
	# Use the SyncDeltaBuilder to build your SyncDelta object: 
	# See: https://forgerock.org/openicf/doc/apidocs/org/identityconnectors/framework/common/objects/SyncDeltaBuilder.html
	#
	# If the HashMap is used, it has to contain the following items:
	# - "SyncToken": the value of the token. (could be Integer, Date, String). Mandatory
	# - "DeltaType": a valid change type ("CREATE"|"UPDATE"|"DELETE"|"CREATE_OR_UPDATE"). Mandatory
	# - "Uid": unique identifier of the object. Can be a String or a valid OpenICF Uid object. Mandatory
	# - "PreviousUid": If the Uid was changed, this should be the previous value of the Uid. Can be a String or a valid OpenICF Uid object.
	# - "Object": a HashTable describing the object. It can be null if the DeltaType is delete. If not null, it must contain at least the 
	# OpenICF special attribute __NAME__.
	# Here is an example:

	$object = @{"__NAME__" = $_.DistinguishedName; "__UID__" = $_.ObjectGUID.ToString();}
	$object.Add("Description", "this is a example")

	# Hashtable describing the change to sync:
	$result = @{"SyncToken" = $_.uSNChanged; "DeltaType" = "CREATE_OR_UPDATE"; "Uid" = $_.ObjectGUID.ToString(); "Object" = $object}
	
	# Pass the result to the connector by calling Process(). Process returns true if ok.
	if (!$Connector.Result.Process($result))
	{
		break
	}
}

# The script code should always be enclosed within a try/catch block. 
# If any exception is thrown, it is good practice to catch the original exception 
# message and re-throw it within an OpenICF connector exception
try
{
	# Since one script can be used for multiple actions, it is safe to check the operation first.
	if ($Connector.Operation -eq "GET_LATEST_SYNC_TOKEN")
	{
		Write-Verbose "This is the Sync (GetLatestSyncToken) Script"
		# Set the tokenValue to a value from the target system (timestamp, last change number...)
		$tokenValue = "1234"
		# Build an OpenICF SyncToken object
		$token = New-Object Org.IdentityConnectors.Framework.Common.Objects.SyncToken($tokenValue);
		# Set the result
		$Connector.Result.SyncToken = $token;
	}
	elseif ($Connector.Operation -eq "SYNC")
	{
		Write-Verbose "This is the Sync Script"
		# Switch on the different ObjectClass
		switch ($Connector.ObjectClass.Type)
		{
			"__ACCOUNT__" 	
			{
				# Like for Search, OpenICF "streams" results of the Sync. With PowerShell, it then
				# makes sense to pipe results in a filter function:
				# <list changes to the pipe> | Process-Sync
				# As an example, this is how it is done with AD:
				Get-ADUser -Filter (usnchanged > xx) -SearchBase Base -Properties attrsToGet | Process-Sync
			}
			"__GROUP__"
			{
				# AD example for group
				Get-ADGroup -Filter (usnchanged > xx) -SearchBase Base -Properties attrsToGet | Process-Sync
			}
			default 
			{
				throw "Unsupported type: $($Connector.ObjectClass.Type)"
			}
		}
	}
	else
	{
		throw new Org.IdentityConnectors.Framework.Common.Exceptions.ConnectorException("Sync Script can not handle operation: $($Connector.Operation)")
	}
}
catch #Re-throw the original exception message within a connector exception
{
	# Before re-throwing, clean up may be done (close file, connections etc...).

	# See https://forgerock.org/openicf/doc/apidocs/org/identityconnectors/framework/common/exceptions/package-frame.html
	# for the list of OpenICF exceptions
	throw New-Object Org.IdentityConnectors.Framework.Common.Exceptions.ConnectorException($_.Exception.Message)
}