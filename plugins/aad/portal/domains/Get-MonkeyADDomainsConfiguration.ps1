﻿# Monkey365 - the PowerShell Cloud Security Tool for Azure and Microsoft 365 (copyright 2022) by Juan Garrido
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


function Get-MonkeyADDomainsConfiguration {
<#
        .SYNOPSIS
		Plugin extract information about domain from Azure AD

        .DESCRIPTION
		Plugin extract information about domain from Azure AD

        .INPUTS

        .OUTPUTS

        .EXAMPLE

        .NOTES
	        Author		: Juan Garrido
            Twitter		: @tr1ana
            File Name	: Get-MonkeyADDomainsConfiguration
            Version     : 1.0

        .LINK
            https://github.com/silverhack/monkey365
    #>

	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $false,HelpMessage = "Background Plugin ID")]
		[string]$pluginId
	)
	begin {
		#Getting environment
		#Plugin metadata
		$monkey_metadata = @{
			Id = "aad0007";
			Provider = "AzureAD";
			Title = "Plugin to get information about domain from Azure AD";
			Group = @("AzureADPortal");
			ServiceName = "Azure AD Domain";
			PluginName = "Get-MonkeyADDomainsConfiguration";
			Docs = "https://silverhack.github.io/monkey365/"
		}
		$Environment = $O365Object.Environment
		#Get Graph Authentication
		$AADAuth = $O365Object.auth_tokens.Graph
		#Get Config
		$AADConfig = $O365Object.internal_config.azuread
		$domains = $null
	}
	process {
		if ($null -ne $Environment -and $null -ne $AADAuth) {
			$msg = @{
				MessageData = ($message.MonkeyGenericTaskMessage -f $pluginId,"Azure AD Domain Configuration",$O365Object.TenantID);
				callStack = (Get-PSCallStack | Select-Object -First 1);
				logLevel = 'info';
				InformationAction = $InformationAction;
				Tags = @('AzureADDomainConfigurationInfo');
			}
			Write-Information @msg
			$params = @{
				Environment = $Environment;
				Authentication = $AADAuth;
				ObjectType = "domains";
				APIVersion = $AADConfig.api_version
			}
			$domains = Get-MonkeyGraphObject @params
			if ($domains) {
				foreach ($domain in $domains) {
					if ($domain.supportedServices) {
						$domain.supportedServices = (@($domain.supportedServices) -join ',')
					}
				}
			}
		}
	}
	end {
		if ($null -ne $domains) {
			$domains.PSObject.TypeNames.Insert(0,'Monkey365.AzureAD.DomainConfiguration')
			[pscustomobject]$obj = @{
				Data = $domains;
				Metadata = $monkey_metadata;
			}
			$returnData.Add('aad_domains',$obj)
		}
		else {
			$msg = @{
				MessageData = ($message.MonkeyEmptyResponseMessage -f "Azure AD Domain Configuration",$O365Object.TenantID);
				callStack = (Get-PSCallStack | Select-Object -First 1);
				logLevel = 'warning';
				InformationAction = $InformationAction;
				Tags = @('AzureADDomainConfigurationEmptyResponse');
			}
			Write-Warning @msg
		}
	}
}
