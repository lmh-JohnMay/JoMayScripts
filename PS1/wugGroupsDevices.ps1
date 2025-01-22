#region add certs and protocols
Add-Type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

#endregion

#region build WUG token
#save pw to file in updatePWfile.ps1
$cred = Import-CliXml -Path 'C:\test\cred.xml'

#WUG wont accept secure strings, so decode password :o(
$pass = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($cred.password))

$sClaim=@{}
$sClaim.add("grant_type","password")
$sClaim.add("username",$cred.UserName)
$sClaim.add("password",$pass) 
#$sClaim.add("password","dumplesnips")

$pass=""
$url="https://lmh-wug.intralee.leememorial.org:9644/api/v1/token"

$headers = @{}
try{
    $response = Invoke-RestMethod -Uri $url -UseBasicParsing -Method POST -body $sClaim -ErrorAction Stop
} catch{
    Write-output "eror retreiving token"
    $sClaim=@{}
    exit
}finally{
    $sClaim=@{}
}

$AT=$response.access_token
$headers.add("Authorization", "bearer $AT")
#endregion

#region get groups
$url="https://lmh-wug.intralee.leememorial.org:9644/api/v1/device-groups/-" 
$responseG = Invoke-RestMethod -Uri $url -UseBasicParsing -Method get -headers $headers 
$responseG.data.groups | export-csv "c:\test\wugGroups.csv" -NoTypeInformation

$nextPage=$responseG.paging.nextPageId

$body2=@{
            "limit"="100"
            "pageID"="$nextPage"
        }
do{
    if($nextPage){        
        $responseG = Invoke-RestMethod -Uri $url -UseBasicParsing -Method get -headers $headers -body $body2
        $nextPage=$responseG.paging.nextPageId

        $body2=@{
                    "limit"="100"
                    "pageID"="$nextPage"
        }
        $responseG.data.groups | export-csv -append "c:\test\wugGroups.csv" -NoTypeInformation
     }        
}until(!$responseG.paging.nextPageId)

#$headers = @{}
#$url="https://lmh-wug.intralee.leememorial.org:9644/api/v1/device-groups/-" 
#$responseG = Invoke-RestMethod -Uri $url -UseBasicParsing -Method get -headers $headers 

#endregion
#region get devices
$url="https://lmh-wug.intralee.leememorial.org:9644/api/v1/device-groups/0/devices/-"
$responseD = Invoke-RestMethod -Uri $url -UseBasicParsing -Method get -headers $headers 
$responseD.data.devices | export-csv "c:\test\wugDevices.csv" -NoTypeInformation

$nextPage=$responseD.paging.nextPageId

$body2=@{
            #"limit"="200"
            "pageID"="$nextPage"
        }
do{
    if($nextPage){        
        $responseD = Invoke-RestMethod -Uri $url -UseBasicParsing -Method get -headers $headers -body $body2
        $nextPage=$responseD.paging.nextPageId

        $body2=@{
                    #"limit"="200"
                    "pageID"="$nextPage"
        }
        $responseD.data.devices | export-csv -append "c:\test\wugDevices.csv" -NoTypeInformation
     }        
}until(!$responseD.paging.nextPageId)

$headers = @{}
#$url="https://lmh-wug.intralee.leememorial.org:9644/api/v1/device-groups/-" 
#$responseG = Invoke-RestMethod -Uri $url -UseBasicParsing -Method get -headers $headers 

#endregion

#get  /api/v1/device-groups/-
#get /api/v1/device-groups/{groupId}/devices ---groupid=0
#Authorization = bearer + token

#curl https://lmh-wug:9644/api/v1/token -data "grant_type=password&username=emmacurtis&password=1a2B3cA1b2C3"

#curl -k --request POST --url https://lmh-wug:9644/api/v1/token 
# --data "grant_type=password&username=emmacurtis&password=1a2B3cA1b2C3"