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


Function Get-PSGraphSecureScore{
    <#
        .SYNOPSIS
		Get Secure Score

        .DESCRIPTION
		Get Secure Score

        .INPUTS

        .OUTPUTS

        .EXAMPLE

        .NOTES
	        Author		: Juan Garrido
            Twitter		: @tr1ana
            File Name	: Get-PSGraphSecureScore
            Version     : 1.0

        .LINK
            https://github.com/silverhack/monkey365
    #>

    try{
        #Import Localized data
        $LocalizedDataParams = $O365Object.LocalizedDataParams
        Import-LocalizedData @LocalizedDataParams;
        $Environment = $O365Object.Environment
        #Get Graph Auth
        $graphAuth = $O365Object.auth_tokens.MSGraph
        $msg = @{
            MessageData = $message.SecureScoreMessage;
            callStack = (Get-PSCallStack | Select-Object -First 1);
            logLevel = 'info';
            InformationAction = $InformationAction;
            Tags = @('SecureScoreInfo');
        }
        Write-Information @msg
        $params = @{
            Authentication = $graphAuth;
            ObjectType = "Security/secureScores";
            Environment = $Environment;
            Top = '1';
            Select = "createdDateTime","averageComparativeScores","controlScores";
            ContentType = 'application/json';
            Method = "GET";
            APIVersion = 'v1.0';
        }
        $secure_score = Get-GraphObject @params
        if($null -ne $secure_score){
            return $secure_score
        }
    }
    catch{
        $msg = @{
            MessageData = ("Unable to get secure score information from Graph");
            callStack = (Get-PSCallStack | Select-Object -First 1);
            logLevel = 'warning';
            InformationAction = $InformationAction;
            Tags = @('AzureGraphSecureScore');
        }
        Write-Warning @msg
        #Set verbose
        $msg.MessageData = $_
        $msg.logLevel = 'Verbose'
        Write-Verbose @msg
    }
}
