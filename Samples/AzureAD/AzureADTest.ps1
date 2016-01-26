# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
#
# Copyright (c) 2015-2016 ForgeRock AS. All Rights Reserved
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
# @author Gael Allioux <gael.allioux@forgerock.com>
#
#REQUIRES -Version 2.0

<#  
.SYNOPSIS  
    This is a sample Test script for Azure Active Directory
	
.DESCRIPTION
	The script tries to fetch the company-level information.

.INPUT
	The connector sends us the following:
	- <prefix>.Configuration : handler to the connector's configuration object
	- <prefix>.Operation: String correponding to the action ("TEST" here)
	
.RETURNS
	Nothing. Should throw an exception if test failed
	
.NOTES  
    File Name      : AzureADTest.ps1  
    Author         : Gael Allioux (gael.allioux@forgerock.com)
    Prerequisite   : PowerShell V2 and later
    Copyright      : 2015-2016 - ForgeRock AS    
	
.LINK  
    Script posted over:  
    http://openicf.forgerock.org
	
	Azure Active Directory Module for Windows PowerShell
	https://msdn.microsoft.com/en-us/library/azure/jj151815.aspx
#>

try
{
 if ($Connector.Operation -eq "TEST")
 {
	if (!$Env:OpenICF_AAD) {
		$msolcred = New-object System.Management.Automation.PSCredential $Connector.Configuration.Login, $Connector.Configuration.Password.ToSecureString()
		connect-msolservice -credential $msolcred
		$Env:OpenICF_AAD = $true
		Write-Verbose -verbose "New session created"
	}
	
	$comp = Get-MsolCompanyInformation
	Write-Verbose -verbose $comp.DisplayName
 }
 else
 {
 	throw new Org.IdentityConnectors.Framework.Common.Exceptions.ConnectorException("TestScript can not handle operation: $($Connector.Operation)")
 }
}
catch #Rethrow the original exception
{
	throw
}
