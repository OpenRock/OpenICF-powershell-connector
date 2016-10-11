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
    This is a template for the Schema script
	
.DESCRIPTION
	The Schema script is used to build the OpenICF schema for users, groups
	and other objects. In OpenICF, The schema describes which types of objects 
	the Connector manages on the target system and which operations, which options 
	the Connector supports for each type of object.
	A Schema script may or may not have to connect to the target system to extract
	the object types and their properties.
	
.INPUT VARIABLES
	The connector injects a Hashmap into the Sync script context with the following items:
	("Connector" is the default name for <prefix>)
	- <prefix>.Configuration : handler to the connector's configuration object
	- <prefix>.Operation: an OperationType corresponding to the operation ("SCHEMA" here)
	- <prefix>.SchemaBuilder: an instance of SchemaBuilder that must be used to build the schema.
	  See: https://forgerock.org/openicf/doc/apidocs/org/identityconnectors/framework/common/objects/SchemaBuilder.html
	
.RETURNS 
	Nothing. Connector will finalize the schema build.
	
.NOTES  
    File Name      : AzureADSchema.ps1  
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

try
{
	# Use the AttributeInfoBuilder to define attribute properties
	# See: https://forgerock.org/openicf/doc/apidocs/org/identityconnectors/framework/common/objects/AttributeInfoBuilder.html
	$AttributeInfoBuilder = [Org.IdentityConnectors.Framework.Common.Objects.ConnectorAttributeInfoBuilder]

	# Since one script can be used for multiple actions, it is safe to check the operation first.
	if ($Connector.Operation -eq "SCHEMA")
	{
		Write-Verbose "This is the Schema Script"

		# Let's provide an example for the __ACCOUNT__
		# to show how the different types of atttributes are defined

		# First define the ObjectClassInfo.
		# See: https://forgerock.org/openicf/doc/apidocs/org/identityconnectors/framework/common/objects/ObjectClassInfoBuilder.html
		$ocib = New-Object Org.IdentityConnectors.Framework.Common.Objects.ObjectClassInfoBuilder
		$ocib.ObjectType = "__ACCOUNT__"
	
		# Define required Attributes
		$Required = @("DisplayName","UserPrincipalName")
	
		foreach ($attr in $Required)
		{
			$caib = New-Object Org.IdentityConnectors.Framework.Common.Objects.ConnectorAttributeInfoBuilder($attr);
			$caib.Required = $TRUE
			$caib.ValueType = [string];
			# Once defined, each attribute info is added to the object class info
			$ocib.AddAttributeInfo($caib.Build())
		}
	
		# Define standard attributes - single valued
		$StandardSingle = @("City","Country ","Department")
	
		foreach ($attr in $StandardSingle)
		{
			# Once defined, each attribute info is added to the object class info
			$ocib.AddAttributeInfo($AttributeInfoBuilder::Build($attr,[string]))
		}
	
		# Define standard attributes - multi valued
		$StandardMulti = @("AlternateEmailAddresses", "AlternateMobilePhones", "Licenses")
	
		foreach ($attr in $StandardMulti)
		{
			$caib = New-Object Org.IdentityConnectors.Framework.Common.Objects.ConnectorAttributeInfoBuilder($attr);
			$caib.MultiValued = $TRUE
			$caib.ValueType = [string];
			$ocib.AddAttributeInfo($caib.Build())
		}
		
		# Define special attributes
		$Special = @("EnabledFilter")
	
		foreach ($attr in $Special)
		{
			$caib = New-Object Org.IdentityConnectors.Framework.Common.Objects.ConnectorAttributeInfoBuilder($attr);
			$caib.Creatable = $FALSE
			$caib.Updateable = $FALSE
			$caib.ValueType = [string];
			$ocib.AddAttributeInfo($caib.Build())
		}
	
 		# Define a few operational attributes as well
		$opAttrs = [Org.IdentityConnectors.Framework.Common.Objects.OperationalAttributeInfos]
		$ocib.AddAttributeInfo($opAttrs::ENABLE)
		$ocib.AddAttributeInfo($opAttrs::PASSWORD)
		$ocib.AddAttributeInfo($opAttrs::LOCK_OUT)
	
		# Final step: pass the object class info to the schema builder.
		$Connector.SchemaBuilder.DefineObjectClass($ocib.Build())
	}
 }
catch #Re-throw the original exception message within a connector exception
{
	# Before re-throwing, clean up may be done (close file, connections etc...).

	# See https://forgerock.org/openicf/doc/apidocs/org/identityconnectors/framework/common/exceptions/package-frame.html
	# for the list of OpenICF exceptions
	throw New-Object Org.IdentityConnectors.Framework.Common.Exceptions.ConnectorException($_.Exception.Message)
}