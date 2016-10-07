# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
#
# Copyright (c) 2016 ForgeRock AS. All Rights Reserved
#
# The contents of this file are subject to the terms
# of the Common Development and Distribution License
# (the License). You may not use this file except in
# compliance with the License.
#
# You can obtain a copy of the License at
# http://forgerock.org/license/CDDLv1.0.html
# See the License for the specific language governing
# permission and limitations under the License.
#
# When distributing Covered Code, include this CDDL
# Header Notice in each file and include the License file
# at http://forgerock.org/license/CDDLv1.0.html
# If applicable, add the following below the CDDL Header,
# with the fields enclosed by brackets [] replaced by
# your own identifying information:
# " Portions Copyrighted [year] [name of copyright owner]"
#
#REQUIRES -Version 2.0

<#  
.SYNOPSIS  
    This is a template for the Search script
	
.DESCRIPTION
	The Search script is used to query a target system. The queries are
	passed to the script in a format that is configured at the connector level.
	The results of the query should be "streamed" back to the connector framework,
	using a callback injected in the script context by the connector.
	
.INPUT VARIABLES
	The connector injects a Hashmap into the Sync script context with the following items:
	("Connector" is the default name for <prefix>)
	- <prefix>.Configuration : handler to the connector's configuration object
	- <prefix>.Options: a handler to the Operation Options
	- <prefix>.Operation: an OperationType corresponding to the operation ("SEARCH" here)
	- <prefix>.ObjectClass: the Object class object (__ACCOUNT__ / __GROUP__ / other)	
	- <prefix>.Query: a handler to the Query.
	
.RETURNS
	Results of the search should be returned to the connector by calling Connector.Results.Process(Hashtable|ConnectorObject).
	The callback Connector.Results.Complete(void|string|SearchResult) can be used as well to complete the results of a search.
	See: https://forgerock.org/openicf/doc/apidocs/org/identityconnectors/framework/common/objects/SearchResult.html
	
.NOTES  
    File Name      : SearchTemplate.ps1  
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

# We define a filter to process results through a pipe and feed the result handler
# The special $_ is used. It contains the object passed to the filter.
filter Process-Users {
	# The script must return either a ConnectorObject or a predefined HashTable 
	# Use the ConnectorObjectBuilder to build your ConnectorObject object: 
	# See: https://forgerock.org/openicf/doc/apidocs/org/identityconnectors/framework/common/objects/ConnectorObjectBuilder.html
	#
	# If the HashMap is used, it has to contain the following mandatory items:
	# - "__UID__": The unique identifier of the object
	# - "__NAME_": The common "name" (mutable identifier) of the object.
	# Here is an example:

	$object = @{"__UID__" = $_.ObjectId.ToString(); "__NAME__"= $_.UserPrincipalName}
	$object.Add("Description", "this is a example")
	
	$Connector.Result.Process($object)
}

filter Process-Groups {
}

# The script code should always be enclosed within a try/catch block. 
# If any exception is thrown, it is good practice to catch the original exception 
# message and re-throw it within an OpenICF connector exception
try
{
	# Since one script can be used for multiple actions, it is safe to check the operation first.
	if ($Connector.Operation -eq "SEARCH")
	{
		Write-Verbose "This is the Search Script"
		switch ($Connector.ObjectClass.Type)
		{
			"__ACCOUNT__"
			{
				# At first, the query should be analyzed. Here we take the example
				# of the Map filter visitor which will present the query to the script
				# in a form of a predefined HashTable.
				# The "Map" filter visitor put the query in a HashMap with the following keys:
				# 'Not': boolean to tell if the query uses the NOT (!)
				# 'Left': the left side of the query
				# 'Right: the right side of the query
				# 'Operation': the query operation. Possible values are:
				#  CONTAINS, EQUALS, GREATERTHAN, GREATERTHANOREQUAL, LESSTHAN, LESSTHANOREQUAL, STARTSWITH, ENDSWITH
				#
				# Example: 
				# the query filter "UserPrincipalName eq JSmith" will come as the following map:
				# @{'Not' = false; 'Left' = 'UserPrincipalName'; 'Operation' = 'EQUALS'; 'Right' = 'JSmith'}
				# 
				# The following illustrate the query processing with an imaginary set of search
				# cmdlets (Get-AllUsers/Get-User/Get-AllGroups)
				#
				# Results are piped in the filter function (Process-Users & Process-Groups)
				if ($Connector.Query -eq $null) {
					# A null query means "fetch all entries"
					Get-AllUsers | Process-Users
				}
				elseif ($Connector.Query.Operation -eq "STARTSWITH")
				{
					Get-User -SearchString $Connector.Query.Right | Process-Users
				}
				elseif ($Connector.Query.Operation -eq "EQUALS")
				{
					switch ($Connector.Query.Left)
					{
						"__UID__"
						{
							Get-User -ObjectId $Connector.Query.Right | Process-Users
						}
						"__NAME__"
						{
							Get-User -DisplayName $Connector.Query.Right | Process-Users
						}
						"DisplayName"
						{

						}
					}
				}
			}
			"__GROUP__"
			{
				if ($Connector.Query -eq $null) {
					# A null query means "fetch all entries"
					Get-AllGroups | Process-Groups
				}
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
	else
	{
		throw New-Object Org.IdentityConnectors.Framework.Common.Exceptions.ConnectorException("UpdateScript can not handle operation: $($Connector.Operation)")
	}	
}
catch #Re-throw the original exception message within a connector exception
{
	# Before re-throwing, clean up may be done (close file, connections etc...).

	# See https://forgerock.org/openicf/doc/apidocs/org/identityconnectors/framework/common/exceptions/package-frame.html
	# for the list of OpenICF exceptions
	throw New-Object Org.IdentityConnectors.Framework.Common.Exceptions.ConnectorException($_.Exception.Message)
}