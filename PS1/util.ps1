measure-command{
$null=get-eventlog -logname application #-computername 'GW-LT-S200-276'
}

measure-command{
$null=get-winevent -logname application #-computername 'GW-LT-S200-276'
}

get-winevent -logname security -maxevents 50 |
    select-object timecreated, providername, mesage |
    format-table -autosize

get-winevent -filterhashtable @{logname='application'; id=1}

get-winevent -filterhashtable @{logname='system'; data='ad\jomay'}

#xml comes from system event log - filter then xml tab
$query=@"
<QueryList>
  <Query Id="0" Path="Application">
    <Select Path="Application">*[System[(Level=1  or Level=3)]]</Select>
  </Query>
</QueryList>
"@
get-winevent -FilterXml $query