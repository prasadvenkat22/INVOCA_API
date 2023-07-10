function ParseItem($jsonItem) 
{
    if($jsonItem.PSObject.TypeNames -match 'Array') 
    {
        return ParseJsonArray($jsonItem)
    }
    elseif($jsonItem.PSObject.TypeNames -match 'Dictionary') 
    {
        return ParseJsonObject([HashTable]$jsonItem)
    }
    else 
    {
        return $jsonItem
    }
}
function ParseJsonObject($jsonObj) 
{
    $result = New-Object -TypeName PSCustomObject
    foreach ($key in $jsonObj.Keys) 
    {
        $item = $jsonObj[$key]
        if ($item) 
        {
            $parsedItem = ParseItem $item
        }
        else 
        {
            $parsedItem = $null
        }
        $result | Add-Member -MemberType NoteProperty -Name $key -Value $parsedItem
    }
    return $result
}
function ParseJsonArray($jsonArray) 
{
    $result = @()
    $jsonArray | ForEach-Object -Process {
        $result += , (ParseItem $_)
    }
    return $result
}
function ParseJsonString($json) 
{
    $config = $javaScriptSerializer.DeserializeObject($json)
    return ParseJsonObject($config)
}


function Get-InvocaAPIToCSV_2 {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string] $OutputPath # = 'D:\ftp\002_networkImports\InvocaAPI\'
        #[string] $OutputPath = 'C:\GeorgeTest\InvocaAPI\'
        , [Parameter(Mandatory = $false)]
        [datetime] $StartDate #= '2019-05-09'
        , [Parameter(Mandatory = $false)]
        [datetime] $EndDate #= '2019-05-09'
        , [Parameter(Mandatory = $true)]
        [string] $ErrorLogFile #= 'D:\ftp\002_networkImports\InvocaAPI\Error.log'
        , [Parameter(Mandatory = $false)]
        [int] $ItemLimit = 4000
        , [Parameter(Mandatory = $false)]
        [int] $debugOnly = $false
    )

    Begin {
        #Set the basis of the Csv filenames
        $BaseCSVFilePrefix = 'InvocaAPI_BaseData_'
        $SecondaryCSVFilePrefix = 'InvocaAPI_SecondaryData_'

        If (-Not (Test-Path $OutputPath)) { Throw 'OutputPath doesn''t exist!' }

        # Check values for $itemLimit
        If ( $ItemLimit -gt 4000 ) { Throw '$ ItemLimit exceeds the limit given by the API provider.  Aborting' }
        If ( $ItemLimit -lt 0 ) { Throw '$ ItemLimit cannot be negative.  Aborting' }

        #Flesh out the Start and End Dates to use
        If( ! $StartDate ) {
            [string] $strStartDate = ((Get-Date).AddDays(-1)).ToString("yyyy-MM-dd") # defaults to yesterday
            Write-Host "StartDate not Provided.  Defaulting to $strStartDate"
        }
        Else {
            $strStartDate = $StartDate.ToString("yyyy-MM-dd")
        }
        If( ! $EndDate ) {
            [string] $strEndDate = ((Get-Date).AddDays(-1)).ToString("yyyy-MM-dd") # defaults to today
            Write-Host "EndDate not Provided.  Defaulting to $strEndDate"
        }
        Else {
            $strEndDate = $EndDate.ToString("yyyy-MM-dd")
        }

        $Primary = "$BaseCSVFilePrefix$strStartDate.csv"
        $Secondary = "$SecondaryCSVFilePrefix$strStartDate.csv"

        $BaseOutputFile = Join-Path -path $OutputPath $Primary 
        $SecondaryOutputFile = Join-Path -path $OutputPath $Secondary 

    }

    Process {
        Clear-Host
        $ErrorActionPreference = "Stop" 
        $CurrentRunDate = (Get-Date).ToString() 
        "Starting Run $CurrentRunDate " | Out-File -FilePath $ErrorLogFile -Append -Encoding ascii

        "> $ strStartDate = $strStartDate" | Out-File -FilePath $ErrorLogFile -Append -Encoding ascii
        "> $ strEndDate = $strEndDate" | Out-File -FilePath $ErrorLogFile -Append -Encoding ascii

        If( $debugOnly -eq $true ) {
            #Write-Host "START" # Log this
            "> $ BaseOutputFile = $BaseOutputFile" | Out-File -FilePath $ErrorLogFile -Append -Encoding ascii
            "> $ SecondaryOutputFile = $SecondaryOutputFile" | Out-File -FilePath $ErrorLogFile -Append -Encoding ascii

            #Write-host "$ strStartDate = $strStartDate"
            #Write-host "$ strEndDate = $strEndDate"
            #Write-Host "$ BaseOutputFile = $BaseOutputFile"
            #Write-Host "$ SecondaryOutputFile = $SecondaryOutputFile"
        }

        $api_key = "Dc_g9nM8zsLzOWnsidpPJ4K9Bg82EnRR" # provided by the API owner
        
        
        # take the base web call, then add the needed columns and later add a start transactionId if necessary

        [string]$baseWebString = "https://aimediagroup.invoca.net/api/2019-02-01/networks/transactions/1659.json?from=$strStartDate&to=$strEndDate&oauth_token=$api_key"
        [string]$limit = "&limit=$itemLimit" #Max number of items to download in one go
        [string]$includeColumns = '&include_columns=$invoca_default_columns,custom_data' #custom_data is invoca variable that gives us the custom data columns
        [string]$webString = $baseWebString + $limit + $includeColumns
        If( $debugOnly -eq $true ) { 
            #Write-host "$ webString = $webString" 
            "> $ webString = $webString" | Out-File -FilePath $ErrorLogFile -Append -Encoding ascii
        }

        try {
            #must update the TLS protocol to 1.2 otherwise it doesnt work on the server [SSL requirements?]
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

            [void][System.Reflection.Assembly]::LoadWithPartialName("System.Web.Extensions")
            #$jsonserial = New-Object -TypeName System.Web.Script.Serialization.JavaScriptSerializer
            #$jsonserial.MaxJsonLength = [int]::MaxValue
            #$jsonserial.DeserializeObject($content) #this works
            
            # Download the content from the API
            $content = (Invoke-WebRequest $webString -UseBasicParsing).Content -replace '\p{Pd}', '-'
            $content = $content -replace '[^\x00-\x7F]', ''
            #$content.Count #1
            "> Completed Initial API Pull" | Out-File -FilePath $ErrorLogFile -Append -Encoding ascii

            #Deserializing the JSON data with custom maxsize [104857600 = 100MB]
            $myJson = ParseItem ((New-Object -TypeName System.Web.Script.Serialization.JavaScriptSerializer -Property @{MaxJsonLength=104857600}).DeserializeObject($content))
            #$myjson = ConvertFrom-Json -InputObject $result # Convert to PSObject
            #$content | Set-Content D:\ftp\002_networkImports\InvocaAPI\json.json -Encoding UTF8 #output to a file
            "> Completed Initial JSON Parse" | Out-File -FilePath $ErrorLogFile -Append -Encoding ascii

            #Export Base Data to CSV file.  The needed columns are in the select-object list
            $myJson | SELECT-Object "transaction_id","corrects_transaction_id","transaction_type","original_order_id","advertiser_id","advertiser_id_from_network","advertiser_name","advertiser_campaign_id","advertiser_campaign_id_from_network","advertiser_campaign_name","affiliate_id","affiliate_id_from_network","affiliate_name","affiliate_commissions_ranking","affiliate_call_volume_ranking","affiliate_conversion_rate_ranking","media_type","call_source_description","promo_line_description","virtual_line_id","call_result_description_detail","call_fee_localized","advertiser_call_fee_localized","city","region","qualified_regions","repeat_calling_phone_number","calling_phone_number","mobile","duration","connect_duration","ivr_duration","keypresses","keypress_1","keypress_2","keypress_3","keypress_4","dynamic_number_pool_referrer_search_engine","dynamic_number_pool_referrer_search_keywords","dynamic_number_pool_referrer_param1_name","dynamic_number_pool_referrer_param1_value","dynamic_number_pool_referrer_param2_name","dynamic_number_pool_referrer_param2_value","dynamic_number_pool_referrer_param3_name","dynamic_number_pool_referrer_param3_value","dynamic_number_pool_referrer_param4_name","dynamic_number_pool_referrer_param4_value","dynamic_number_pool_referrer_param5_name","dynamic_number_pool_referrer_param5_value","dynamic_number_pool_referrer_param6_name","dynamic_number_pool_referrer_param6_value","dynamic_number_pool_referrer_param7_name","dynamic_number_pool_referrer_param7_value","dynamic_number_pool_referrer_param8_name","dynamic_number_pool_referrer_param8_value","dynamic_number_pool_referrer_param9_name","dynamic_number_pool_referrer_param9_value","dynamic_number_pool_referrer_param10_name","dynamic_number_pool_referrer_param10_value","dynamic_number_pool_referrer_param11_name","dynamic_number_pool_referrer_param11_value","dynamic_number_pool_referrer_param12_name","dynamic_number_pool_referrer_param12_value","dynamic_number_pool_referrer_param13_name","dynamic_number_pool_referrer_param13_value","dynamic_number_pool_referrer_param14_name","dynamic_number_pool_referrer_param14_value","dynamic_number_pool_referrer_param15_name","dynamic_number_pool_referrer_param15_value","dynamic_number_pool_referrer_param16_name","dynamic_number_pool_referrer_param16_value","dynamic_number_pool_referrer_param17_name","dynamic_number_pool_referrer_param17_value","dynamic_number_pool_referrer_param18_name","dynamic_number_pool_referrer_param18_value","dynamic_number_pool_referrer_param19_name","dynamic_number_pool_referrer_param19_value","dynamic_number_pool_referrer_param20_name","dynamic_number_pool_referrer_param20_value","dynamic_number_pool_referrer_param21_name","dynamic_number_pool_referrer_param21_value","dynamic_number_pool_referrer_param22_name","dynamic_number_pool_referrer_param22_value","dynamic_number_pool_referrer_param23_name","dynamic_number_pool_referrer_param23_value","dynamic_number_pool_referrer_param24_name","dynamic_number_pool_referrer_param24_value","dynamic_number_pool_referrer_param25_name","dynamic_number_pool_referrer_param25_value","dynamic_number_pool_referrer_search_type","dynamic_number_pool_pool_type","dynamic_number_pool_id","start_time_local","start_time_xml","start_time_utc","start_time_network_timezone","start_time_network_timezone_xml","recording","corrected_at","opt_in_SMS","complete_call_id","transfer_from_type","notes","verified_zip","hangup_cause","real_time_response","signal_name","signal_description","signal_partner_unique_id","signal_occurred_at","signal_source","signal_value","signal_custom_parameter_1","signal_custom_parameter_2","signal_custom_parameter_3","reason_code","email_address","name","address1","address2","order_city","state_or_province","zip_code","country","home_phone_number","cell_phone_number","sku_list","quantity_list","revenue","sale_amount","call_center_call_id","destination_phone_number","display_name_data_append","first_name_data_append","last_name_data_append","age_range_data_append","gender_data_append","address_type_data_append","address_full_street_data_append","address_city_data_append","address_state_data_append","address_zip_data_append","address_country_data_append","carrier_data_append","line_type_data_append","is_prepaid_data_append","primary_email_address_data_append","linked_email_addresses_data_append","household_income_data_append","marital_status_data_append","home_owner_status_data_append","home_market_value_data_append","length_of_residence_years_data_append","occupation_data_append","education_data_append","has_children_data_append","high_net_worth_data_append" | Export-Csv -Path $BaseOutputFile -NoTypeInformation
            "> Completed Initial Base Data CSV Output " | Out-File -FilePath $ErrorLogFile -Append -Encoding ascii

            #Create the blank array we'll add the custom objects to for the Secondary [Custom] Data
            "> Create the Initial Custom Object File" | Out-File -FilePath $ErrorLogFile -Append -Encoding ascii
            [System.Collections.ArrayList]$InvocaArray = @()

            $myJson | ForEach-Object -Process {
                $CurrentTransactionId = $_.transaction_Id

                $_.custom_data |
                    ForEach-Object -Process {
                        $InvocaObject = [PSCustomObject]@{
                            transaction_id = $CurrentTransactionId
                            'Invoca_Custom_Data_Name' = $_.name
                            'Invoca_Custom_Data_Value' = $_.value
                        }
                        #Write-Host $InvocaObject

                        $InvocaArray.Add($InvocaObject) | Out-Null
                    }
            }

            #Output the CustomData file as CSV
            $InvocaArray | Export-Csv $SecondaryOutputFile -NoTypeInformation
            If( $debugOnly -eq $true ) { ">  ItemLimit = $ItemLimit" | Out-File -FilePath $ErrorLogFile -Append -Encoding ascii }
            "> Initial Custom Data Count = $($myJson.Count)" | Out-File -FilePath $ErrorLogFile -Append -Encoding ascii
            "> Completed the Initial Custom Object File" | Out-File -FilePath $ErrorLogFile -Append -Encoding ascii
            #write-host "$ ItemLimit = $ItemLimit"
#------------------------------------------------------------
            #Now handle the situation where we have to process more calls to the API
            [int] $iteration = 2;

            While ( ($myJson.Count -eq $ItemLimit) ) # -and ($iteration -lt 4)
            {   
                Start-Sleep -Seconds 60 #Sleep for 1 min between calls
                ">  Starting Iteration = $iteration" | Out-File -FilePath $ErrorLogFile -Append -Encoding ascii
                
                #Make another call to the API and ad the start_after_transaction_id param
                #$start_after_transaction_id = $CurrentTransactionId # $CurrentTransactionId is the last transaction_d from the the previous run
                [string]$newWebString =  $webString + "&start_after_transaction_id=$CurrentTransactionId" #Max number of items to download in one go

                ">  Subsequent Webstring $newWebString" | Out-File -FilePath $ErrorLogFile -Append -Encoding ascii
                #Write-Host "$ newWebString = $newWebString"

                # Download the content from the API
                $content = (Invoke-WebRequest $newWebString -UseBasicParsing).Content -replace  '[^\x00-\x7F]', '' 
                #$content.Count #1
                ">  Completed Subsequent API Pull" | Out-File -FilePath $ErrorLogFile -Append -Encoding ascii

                #Deserializing the JSON data with custom maxsize [104857600 = 100MB]
                $myJson = ParseItem ((New-Object -TypeName System.Web.Script.Serialization.JavaScriptSerializer -Property @{MaxJsonLength=104857600}).DeserializeObject($content))
                #$content | Set-Content c:\GeorgeTest\InvocaAPI\jsonNext.json -Encoding UTF8 #output to a file
                ">  Completed Subsequent JSON Parse" | Out-File -FilePath $ErrorLogFile -Append -Encoding ascii

                #Re-set the FileNames for base and custom data to include the iteration number
                $Primary = $BaseCSVFilePrefix + $strStartDate + '_' + $iteration + '.csv'
                $Secondary = $SecondaryCSVFilePrefix + $strStartDate + '_' + $iteration + '.csv'

                $BaseOutputFile = Join-Path -path $OutputPath $Primary 
                $SecondaryOutputFile = Join-Path -path $OutputPath $Secondary
                
                If( $debugOnly -eq $true ) { 
                    #Write-host "$ webString = $webString" 
                    ">  $ BaseOutputFile = $BaseOutputFile" | Out-File -FilePath $ErrorLogFile -Append -Encoding ascii
                    ">  $ SecondaryOutputFile = $SecondaryOutputFile" | Out-File -FilePath $ErrorLogFile -Append -Encoding ascii
                    #Write-Host "$ BaseOutputFile = $BaseOutputFile"
                    #Write-Host "$ SecondaryOutputFile = $SecondaryOutputFile"
                }

                #Export Base Data & APPEND to existing CSV file.  The needed columns are in the select-object list
                $myJson | SELECT-Object "transaction_id","corrects_transaction_id","transaction_type","original_order_id","advertiser_id","advertiser_id_from_network","advertiser_name","advertiser_campaign_id","advertiser_campaign_id_from_network","advertiser_campaign_name","affiliate_id","affiliate_id_from_network","affiliate_name","affiliate_commissions_ranking","affiliate_call_volume_ranking","affiliate_conversion_rate_ranking","media_type","call_source_description","promo_line_description","virtual_line_id","call_result_description_detail","call_fee_localized","advertiser_call_fee_localized","city","region","qualified_regions","repeat_calling_phone_number","calling_phone_number","mobile","duration","connect_duration","ivr_duration","keypresses","keypress_1","keypress_2","keypress_3","keypress_4","dynamic_number_pool_referrer_search_engine","dynamic_number_pool_referrer_search_keywords","dynamic_number_pool_referrer_param1_name","dynamic_number_pool_referrer_param1_value","dynamic_number_pool_referrer_param2_name","dynamic_number_pool_referrer_param2_value","dynamic_number_pool_referrer_param3_name","dynamic_number_pool_referrer_param3_value","dynamic_number_pool_referrer_param4_name","dynamic_number_pool_referrer_param4_value","dynamic_number_pool_referrer_param5_name","dynamic_number_pool_referrer_param5_value","dynamic_number_pool_referrer_param6_name","dynamic_number_pool_referrer_param6_value","dynamic_number_pool_referrer_param7_name","dynamic_number_pool_referrer_param7_value","dynamic_number_pool_referrer_param8_name","dynamic_number_pool_referrer_param8_value","dynamic_number_pool_referrer_param9_name","dynamic_number_pool_referrer_param9_value","dynamic_number_pool_referrer_param10_name","dynamic_number_pool_referrer_param10_value","dynamic_number_pool_referrer_param11_name","dynamic_number_pool_referrer_param11_value","dynamic_number_pool_referrer_param12_name","dynamic_number_pool_referrer_param12_value","dynamic_number_pool_referrer_param13_name","dynamic_number_pool_referrer_param13_value","dynamic_number_pool_referrer_param14_name","dynamic_number_pool_referrer_param14_value","dynamic_number_pool_referrer_param15_name","dynamic_number_pool_referrer_param15_value","dynamic_number_pool_referrer_param16_name","dynamic_number_pool_referrer_param16_value","dynamic_number_pool_referrer_param17_name","dynamic_number_pool_referrer_param17_value","dynamic_number_pool_referrer_param18_name","dynamic_number_pool_referrer_param18_value","dynamic_number_pool_referrer_param19_name","dynamic_number_pool_referrer_param19_value","dynamic_number_pool_referrer_param20_name","dynamic_number_pool_referrer_param20_value","dynamic_number_pool_referrer_param21_name","dynamic_number_pool_referrer_param21_value","dynamic_number_pool_referrer_param22_name","dynamic_number_pool_referrer_param22_value","dynamic_number_pool_referrer_param23_name","dynamic_number_pool_referrer_param23_value","dynamic_number_pool_referrer_param24_name","dynamic_number_pool_referrer_param24_value","dynamic_number_pool_referrer_param25_name","dynamic_number_pool_referrer_param25_value","dynamic_number_pool_referrer_search_type","dynamic_number_pool_pool_type","dynamic_number_pool_id","start_time_local","start_time_xml","start_time_utc","start_time_network_timezone","start_time_network_timezone_xml","recording","corrected_at","opt_in_SMS","complete_call_id","transfer_from_type","notes","verified_zip","hangup_cause","real_time_response","signal_name","signal_description","signal_partner_unique_id","signal_occurred_at","signal_source","signal_value","signal_custom_parameter_1","signal_custom_parameter_2","signal_custom_parameter_3","reason_code","email_address","name","address1","address2","order_city","state_or_province","zip_code","country","home_phone_number","cell_phone_number","sku_list","quantity_list","revenue","sale_amount","call_center_call_id","destination_phone_number","display_name_data_append","first_name_data_append","last_name_data_append","age_range_data_append","gender_data_append","address_type_data_append","address_full_street_data_append","address_city_data_append","address_state_data_append","address_zip_data_append","address_country_data_append","carrier_data_append","line_type_data_append","is_prepaid_data_append","primary_email_address_data_append","linked_email_addresses_data_append","household_income_data_append","marital_status_data_append","home_owner_status_data_append","home_market_value_data_append","length_of_residence_years_data_append","occupation_data_append","education_data_append","has_children_data_append","high_net_worth_data_append" | Export-Csv -Path $BaseOutputFile -NoTypeInformation -Append
                ">  Completed Subsequent Base Data CSV Output " | Out-File -FilePath $ErrorLogFile -Append -Encoding ascii

                #Create the blank array we'll add the custom objects to for the Secondary [Custom] Data
                ">  Create Subsequent Custom Object File" | Out-File -FilePath $ErrorLogFile -Append -Encoding ascii
                [System.Collections.ArrayList]$InvocaArray = @()

                $myJson | ForEach-Object -Process {
                    $CurrentTransactionId = $_.transaction_Id

                    $_.custom_data |
                        ForEach-Object -Process {
                            $InvocaObject = [PSCustomObject]@{
                                transaction_id = $CurrentTransactionId
                                'Invoca_Custom_Data_Name' = $_.name
                                'Invoca_Custom_Data_Value' = $_.value
                            }
                            #Write-Host $InvocaObject

                            $InvocaArray.Add($InvocaObject) | Out-Null
                        }
                }

                #Output the CustomData file as CSV
                $InvocaArray | Export-Csv $SecondaryOutputFile -NoTypeInformation
                If( $debugOnly -eq $true ) { ">  ItemLimit = $ItemLimit" | Out-File -FilePath $ErrorLogFile -Append -Encoding ascii}
                ">  Secondary Custom Data Count = $($myJson.Count)" | Out-File -FilePath $ErrorLogFile -Append -Encoding ascii
                ">  Completed the Secondary Custom Object File" | Out-File -FilePath $ErrorLogFile -Append -Encoding ascii
                #write-host "$ ItemLimit = $ItemLimit"
                
                ">  End Iteration = $iteration" | Out-File -FilePath $ErrorLogFile -Append -Encoding ascii
                $iteration = $iteration + 1;
            } # end While


        } # end try
        catch {
            " *** FOUND MYSELF IN THE CATCH BLOCK *** " | Out-File -FilePath $ErrorLogFile -Append -Encoding ascii
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
            #Send-MailMessage -From ExpensesBot@MyCompany.Com -To WinAdmin@MyCompany.Com -Subject "HR File Read Failed!" -SmtpServer EXCH01.AD.MyCompany.Com -Body "We failed to read file $FailedItem. The error message was $ErrorMessage"
            " *** CATCH BLOCK: $ ErrorMessage = $_.Exception.Message *** " | Out-File -FilePath $ErrorLogFile -Append -Encoding ascii
            " *** CATCH BLOCK: $ FailedItem = $_.Exception.ItemName *** " | Out-File -FilePath $ErrorLogFile -Append -Encoding ascii

            $dt = (Get-Date).ToString()
            "$dt ErrorMsg: $ErrorMessage " | Out-File -FilePath $ErrorLogFile -Append -Encoding ascii
            "$dt ErrorMsg: $FailedItem " | Out-File -FilePath $ErrorLogFile -Append -Encoding ascii
            Throw "Get-InvocaAPIToCSV_2 Function errored unexpectedly"
        }
        Finally{
            $EndingRunDate = (Get-Date).ToString()
            "Ending Run $CurrentRunDate at $EndingRunDate" | Out-File -FilePath $ErrorLogFile -Append -Encoding ascii
        }
    }
}

Clear-Host

#Get-InvocaAPIToCSV_2 -OutputPath 'C:\GeorgeTest\InvocaAPI\' -StartDate '2019-05-09' -EndDate '2019-05-09' -ErrorLogFile 'D:\ftp\002_networkImports\InvocaAPI\Error.log' -ItemLimit 1000 -debugOnly $true
Get-InvocaAPIToCSV_2 -OutputPath 'F:\ftp\002_networkImports\InvocaAPI\' -ErrorLogFile 'F:\ftp\002_networkImports\InvocaAPI\Error.log' -debugOnly $true

