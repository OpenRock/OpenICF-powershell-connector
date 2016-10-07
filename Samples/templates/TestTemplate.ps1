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
    This is a template for the Test script
	
.DESCRIPTION
	The Test script is used to check the if configuration is good 
	and the target system is reachable.

.INPUT VARIABLES
	The connector injects a Hashmap into the Test script context with the following items:
	("Connector" is the default name for <prefix>)
	- <prefix>.Configuration : handler to the connector's configuration object
	- <prefix>.Operation: String corresponding to the operation ("TEST" here)
	
.RETURNS
	Nothing. An exception should be thrown if the test failed
	
.NOTES  
    File Name      : TestTemplate.ps1  
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
	if ($Connector.Operation -eq "TEST")
	{
		Write-Verbose "This is the Test Script"

		# Put your code here
		# Configuration object properties:
		# $Connector.Configuration.Login, 
		# $Connector.Configuration.Password.ToSecureString()
		# $Connector.Configuration.Host
		# $Connector.Configuration.Port
	}
	else
	{
 		throw New-Object Org.IdentityConnectors.Framework.Common.Exceptions.ConnectorException("TestScript can not handle operation: $($Connector.Operation)")
	}
}
catch #Re-throw the original exception message within a connector exception
{
	# Before re-throwing, clean up may be done (close file, connections etc...).

	# See https://forgerock.org/openicf/doc/apidocs/org/identityconnectors/framework/common/exceptions/package-frame.html
	# for the list of OpenICF exceptions
	throw New-Object Org.IdentityConnectors.Framework.Common.Exceptions.ConnectorException($_.Exception.Message)
}
