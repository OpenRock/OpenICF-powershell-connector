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
    This is a template for the Authenticate script

.DESCRIPTION
	The Authenticate script is used to authenticate an object on a target
	system based on the object "username" and password. It is most of the
	time used for users only. Since the UID is not known, Authenticate script
	may need to leverage the ResolveUsername script code to find the __UID__

.INPUT VARIABLES
	The connector injects a Hashmap into the Delete script context with the following items:
	("Connector" is the default name for <prefix>)
	- <prefix>.Configuration : handler to the connector's configuration object
	- <prefix>.Options: a handler to the Operation Options
	- <prefix>.Operation: an OperationType corresponding to the operation ("AUTHENTICATE" here)
	- <prefix>.ObjectClass: the Object class object (__ACCOUNT__ / __GROUP__ / other)
	- <prefix>.Username: Username String
	- <prefix>.Password: Password in GuardedString format
	
.RETURNS
	Must return the user unique ID (__UID__).
	To do so, set the <prefix>.Result.Uid property either as a String or as an OpenICF Uid object.
	
.NOTES  
    File Name      : AuthenticateTemplate.ps1  
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
	if ($Connector.Operation -eq "AUTHENTICATE")
	{
		Write-Verbose "This is the Authenticate Script"
		# Most of the time only users needs authenticate
		if ($Connector.ObjectClass.Type -eq "__ACCOUNT__")
		{
			# use $Connector.Username and $Connector.Password 
			# if you need to convert the Password GuardedSting to clear text or secure string, do the following:
			$secutil = [Org.IdentityConnectors.Common.Security.SecurityUtil]
			$clearText    = $secutil::Decrypt($Connector.Password)
			$secureString = $Connector.Password.ToSecureString()

			# Unique id must be returned
			$Connector.Result.Uid = <value of the uid>
		}
		else
		{
			throw New-Object System.NotSupportedException("$($Connector.Operation) operation on type: $($Connector.ObjectClass.Type) is not supported")
		}
	}
	else
	{
		throw New-Object Org.IdentityConnectors.Framework.Common.Exceptions.ConnectorException("Authenticate Script can not handle operation: $($Connector.Operation)")
	}
}
catch #Re-throw the original exception message within a connector exception
{
	# Before re-throwing, clean up may be done (close file, connections etc...).

	# See https://forgerock.org/openicf/doc/apidocs/org/identityconnectors/framework/common/exceptions/package-frame.html
	# for the list of OpenICF exceptions
	# throw New-Object Org.IdentityConnectors.Framework.Common.Exceptions.ConnectorException($_.Exception.Message)

	# InvalidCredential is probably more appropiate
	throw New-Object org.identityconnectors.framework.common.exceptions.InvalidCredentialException($_.Exception.Message)
}