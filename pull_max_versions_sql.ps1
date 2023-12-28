
############################################################### 
#Date: 11/05/2023                                             #
#Version: 1.0                                                 #
#Author: Mark Jones                                           #
#Details: Pulls the latest SQL version of the MS website      #
#date       version    author        details                  #
#11/05/2023   1.0       M Jones      initial Script           #                        
############################################################### 
$Instance = "{SQL INSTANCE}"
$database = "{SQLDB}"
function write_to_db($sqlserver,$version,$SP,$CU){


# for this to work a table called [dbo].[latestVersion] with the columns [SQlServer] [varchar](100) NULL, [version] [varchar](50) NULL,	[servicePack] [varchar](10) NULL,
#	[CUNumber] [varchar](5) NULL,[mostRecentSP] [varchar](1) NULL,[mostRecentVersion] [varchar](1) NULL is required 
$sql_query = "merge into dbo.latestVersion as target using (select '$sqlserver' as 'SQL', '$version' as 'Version','$sp' as 'ServicePack', '$cu' as 'CUNumber') as source
               on target.SQlServer = source.SQL and target.version = source.version
               
               when matched then 
               update set target.servicePack = source.ServicePack, target.CUNumber = Source.CUNumber

               
               when not matched then 
               insert (SQLServer,Version,servicePack,CUNumber)
               values (SQL,Version,ServicePack,CUNumber);
               
               
               " 

Invoke-Sqlcmd -ServerInstance $instance -Database $database -Query $sql_query                
                

}



function get_2022($html){
$searchClass =  "16\.0\.[0-9\.][0-9\.][0-9\.][0-9\.][0-9\.][0-9\.][0-9 \D\.\s].*"
$innerversion = "16\.0\.[0-9\.][0-9\.][0-9\.][0-9\.][0-9\.][0-9\.][0-9\.\D\s]"
$innerSP = "SP[0-9]"
$innerCU = "CU[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9 \D\.\s]"
$versions = @()
$upload = @()
$match = ($html|Select-String $searchClass -AllMatches).Matches
$versions = $match.value
$versions = Sort-Object -InputObject $versions -Descending

foreach($r in $versions) {
$sp= ""
$sp1 = ""
$ver = ""
$ver1 = ""
$CU = ""
$CU1 = "" 


$ver = ($r|Select-string -Pattern $innerversion -AllMatches).Matches

if ($ver.value -match "16\.0\.[0-9\.][0-9\.][0-9\.][0-9\.][0-9\.][0-9\.][\D]") {
$ver1 = $ver.value.substring(0,$ver.value.length - 1) 
}
else {$ver1 = $ver.Value}
$sp = ($r|Select-string -pattern $innerSP -AllMatches).Matches
if ($sp -ne $null) {
$sp1 = $sp.value
} else {$sp1 = "RTM"} 

$CU = ($r|Select-string -pattern $innerCU -AllMatches).Matches


if($cu -ne $null) {
$cu1 = $CU.value.substring(0,$CU.value.Length-7)
}
if($cu.Value -match "CU[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][\D\.\s]") {
$cu1 = $CU1.substring(0,$CU1.Length-1)
}




$output =  new-object -TypeName PSObject
$output|Add-Member -MemberType NoteProperty -Name Server -Value "SQL Server 2022"
$output|Add-Member -MemberType NoteProperty -Name Version -Value $ver1
$output|Add-Member -MemberType NoteProperty -Name ServicePack -Value $sp1
$output|Add-Member -MemberType NoteProperty -Name CUNumber -Value $cu1 
$upload +=  $output

}


#$final_version = $versions|measure -maximum
foreach($t in $upload){
write_to_db -sqlserver $t.Server -version $t.Version -SP $t.ServicePack  -CU $t.CUNumber
}


}


function get_2019($html){
$searchClass =  "15\.0\.[0-9\.][0-9\.][0-9\.][0-9\.][0-9\.][0-9\.][0-9 \D\.\s].*"
$innerversion = "15\.0\.[0-9\.][0-9\.][0-9\.][0-9\.][0-9\.][0-9\.][0-9\.\D\s]"
$innerSP = "SP[0-9]"
$innerCU = "CU[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9 \D\.\s]"
$versions = @()
$upload = @()
$match = ($html|Select-String $searchClass -AllMatches).Matches
$versions = $match.value
$versions = Sort-Object -InputObject $versions -Descending
foreach($r in $versions) {
$sp= ""
$sp1 = ""
$ver = ""
$ver1 = ""
$CU = ""
$CU1 = "" 


$ver = ($r|Select-string -Pattern $innerversion -AllMatches).Matches

if ($ver.value -match "15\.0\.[0-9\.][0-9\.][0-9\.][0-9\.][0-9\.][0-9\.][\D]") {
$ver1 = $ver.value.substring(0,$ver.value.length - 1) 
}
else {$ver1 = $ver.Value}
$sp = ($r|Select-string -pattern $innerSP -AllMatches).Matches
if ($sp -ne $null) {
$sp1 = $sp.value
} else {$sp1 = "RTM"} 

$CU = ($r|Select-string -pattern $innerCU -AllMatches).Matches


if($cu -ne $null) {
$cu1 = $CU.value.substring(0,$CU.value.Length-7)
}
if($cu.Value -match "CU[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][\D\.\s]") {
$cu1 = $CU1.substring(0,$CU1.Length-1)
}




$output =  new-object -TypeName PSObject
$output|Add-Member -MemberType NoteProperty -Name Server -Value "SQL Server 2019"
$output|Add-Member -MemberType NoteProperty -Name Version -Value $ver1
$output|Add-Member -MemberType NoteProperty -Name ServicePack -Value $sp1
$output|Add-Member -MemberType NoteProperty -Name CUNumber -Value $cu1 
$upload +=  $output

}


#$final_version = $versions|measure -maximum

foreach($t in $upload){
write_to_db -sqlserver $t.Server -version $t.Version -SP $t.ServicePack  -CU $t.CUNumber
}


}


function get_2017($html){
$searchClass =  "14\.0\.[0-9\.][0-9\.][0-9\.][0-9\.][0-9\.][0-9\.][0-9 \D\.\s].*"
$innerversion = "14\.0\.[0-9\.][0-9\.][0-9\.][0-9\.][0-9\.][0-9\.][0-9\.\D\s]"
$innerSP = "SP[0-9]"
$innerCU = "CU[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9 \D\.\s]"
$versions = @()
$upload = @()
$match = ($html|Select-String $searchClass -AllMatches).Matches
$versions = $match.value
$versions = Sort-Object -InputObject $versions -Descending
foreach($r in $versions) {
$sp= ""
$sp1 = ""
$ver = ""
$ver1 = ""
$CU = ""
$CU1 = "" 


$ver = ($r|Select-string -Pattern $innerversion -AllMatches).Matches

if ($ver.value -match "14\.0\.[0-9\.][0-9\.][0-9\.][0-9\.][0-9\.][0-9\.][\D]") {
$ver1 = $ver.value.substring(0,$ver.value.length - 1) 
}
else {$ver1 = $ver.Value}
$sp = ($r|Select-string -pattern $innerSP -AllMatches).Matches
if ($sp -ne $null) {
$sp1 = $sp.value
} else {$sp1 = "RTM"} 

$CU = ($r|Select-string -pattern $innerCU -AllMatches).Matches


if($cu -ne $null) {
$cu1 = $CU.value.substring(0,$CU.value.Length-7)
}
if($cu.Value -match "CU[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][\D\.\s]") {
$cu1 = $CU1.substring(0,$CU1.Length-1)
}




$output =  new-object -TypeName PSObject
$output|Add-Member -MemberType NoteProperty -Name Server -Value "SQL Server 2017"
$output|Add-Member -MemberType NoteProperty -Name Version -Value $ver1
$output|Add-Member -MemberType NoteProperty -Name ServicePack -Value $sp1
$output|Add-Member -MemberType NoteProperty -Name CUNumber -Value $cu1 
$upload +=  $output

}


#$final_version = $versions|measure -maximum

foreach($t in $upload){
write_to_db -sqlserver $t.Server -version $t.Version -SP $t.ServicePack  -CU $t.CUNumber
}


}


function get_2016($html){
$searchClass =  "13\.0\.[0-9\.][0-9\.][0-9\.][0-9\.][0-9\.][0-9\.][0-9 \D\.\s].*"
$innerversion = "13\.0\.[0-9\.][0-9\.][0-9\.][0-9\.][0-9\.][0-9\.][0-9\.\D\s]"
$innerSP = "SP[0-9]"
$innerCU = "CU[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9 \D\.\s]"
$versions = @()
$upload = @()
$match = ($html|Select-String $searchClass -AllMatches).Matches
$versions = $match.value
$versions = Sort-Object -InputObject $versions -Descending

foreach($r in $versions) {
$sp= ""
$sp1 = ""
$ver = ""
$ver1 = ""
$CU = ""
$CU1 = "" 


$ver = ($r|Select-string -Pattern $innerversion -AllMatches).Matches

if ($ver.value -match "13\.0\.[0-9\.][0-9\.][0-9\.][0-9\.][0-9\.][0-9\.][\D]") {
$ver1 = $ver.value.substring(0,$ver.value.length - 1) 
}
else {$ver1 = $ver.Value}
$sp = ($r|Select-string -pattern $innerSP -AllMatches).Matches
if ($sp -ne $null) {
$sp1 = $sp.value
} else {$sp1 = "RTM"} 

$CU = ($r|Select-string -pattern $innerCU -AllMatches).Matches


if($cu -ne $null) {
$cu1 = $CU.value.substring(0,$CU.value.Length-7)
}
if($cu.Value -match "CU[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][\D\.\s]") {
$cu1 = $CU1.substring(0,$CU1.Length-1)
}




$output =  new-object -TypeName PSObject
$output|Add-Member -MemberType NoteProperty -Name Server -Value "SQL Server 2016"
$output|Add-Member -MemberType NoteProperty -Name Version -Value $ver1
$output|Add-Member -MemberType NoteProperty -Name ServicePack -Value $sp1
$output|Add-Member -MemberType NoteProperty -Name CUNumber -Value $cu1 
$upload +=  $output

}


#$final_version = $versions|measure -maximum

foreach($t in $upload){
write_to_db -sqlserver $t.Server -version $t.Version -SP $t.ServicePack  -CU $t.CUNumber
}


}

function get_2014($html){
$searchClass =  "12\.0\.[0-9\.][0-9\.][0-9\.][0-9\.][0-9\.][0-9\.][0-9 \D\.\s].*"
$innerversion = "12\.0\.[0-9\.][0-9\.][0-9\.][0-9\.][0-9\.][0-9\.][0-9\.\D\s]"
$innerSP = "SP[0-9]"
$innerCU = "CU[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9 \D\.\s]"

$versions = @()
$upload = @()

$match = ($html|Select-String -pattern $searchClass -AllMatches ).Matches
$versions = $match.value
$versions = Sort-Object -InputObject $versions -Descending


foreach($r in $versions) {
$sp= ""
$sp1 = ""
$ver = ""
$ver1 = ""
$CU = ""
$CU1 = "" 


$ver = ($r|Select-string -Pattern $innerversion -AllMatches).Matches

if ($ver.value -match "12\.0\.[0-9\.][0-9\.][0-9\.][0-9\.][0-9\.][0-9\.][\D]") {
$ver1 = $ver.value.substring(0,$ver.value.length - 1) 
}
else {$ver1 = $ver.Value}
$sp = ($r|Select-string -pattern $innerSP -AllMatches).Matches
if ($sp -ne $null) {
$sp1 = $sp.value
} else {$sp1 = "RTM"} 

$CU = ($r|Select-string -pattern $innerCU -AllMatches).Matches


if($cu -ne $null) {
$cu1 = $CU.value.substring(0,$CU.value.Length-7)
}
if($cu.Value -match "CU[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][\D\.\s]") {
$cu1 = $CU1.substring(0,$CU1.Length-1)
}



$output =  new-object -TypeName PSObject
$output|Add-Member -MemberType NoteProperty -Name Server -Value "SQL Server 2014"
$output|Add-Member -MemberType NoteProperty -Name Version -Value $ver1
$output|Add-Member -MemberType NoteProperty -Name ServicePack -Value $sp1
$output|Add-Member -MemberType NoteProperty -Name CUNumber -Value $cu1 
$upload +=  $output

}


#$final_version = $versions|measure -maximum

foreach($t in $upload){
write_to_db -sqlserver $t.Server -version $t.Version -SP $t.ServicePack  -CU $t.CUNumber
}

}

function get_2012($html){

$searchClass =  "11\.0\.[0-9\.][0-9\.][0-9\.][0-9\.][0-9\.][0-9\.][0-9 \D\.\s].*"
$innerversion = "11\.0\.[0-9\.][0-9\.][0-9\.][0-9\.][0-9\.][0-9\.][0-9\.\D\s]"
$innerSP = "SP[0-9]"
$innerCU = "CU[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9 \D\.\s]"

$versions = @()
$upload = @()
$match = ($html|Select-String -pattern $searchClass -AllMatches ).Matches
$versions = $match.value
$versions = Sort-Object -InputObject $versions -Descending



foreach($r in $versions) {
$sp= ""
$sp1 = ""
$ver = ""
$ver1 = ""
$CU = ""
$CU1 = "" 


$ver = ($r|Select-string -Pattern $innerversion -AllMatches).Matches

if ($ver.value -match "11\.0\.[0-9\.][0-9\.][0-9\.][0-9\.][0-9\.][0-9\.][\D]") {
$ver1 = $ver.value.substring(0,$ver.value.length - 1) 
}
else {$ver1 = $ver.Value}
$sp = ($r|Select-string -pattern $innerSP -AllMatches).Matches
if ($sp -ne $null) {
$sp1 = $sp.value
} else {$sp1 = "RTM"} 

$CU = ($r|Select-string -pattern $innerCU -AllMatches).Matches


if($cu -ne $null) {
$cu1 = $CU.value.substring(0,$CU.value.Length-7)
}
if($cu.Value -match "CU[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][\D\.\s]") {
$cu1 = $CU1.substring(0,$CU1.Length-1)
}






$output =  new-object -TypeName PSObject
$output|Add-Member -MemberType NoteProperty -Name Server -Value "SQL Server 2012"
$output|Add-Member -MemberType NoteProperty -Name Version -Value $ver1
$output|Add-Member -MemberType NoteProperty -Name ServicePack -Value $sp1
$output|Add-Member -MemberType NoteProperty -Name CUNumber -Value $cu1 
$upload +=  $output

}



#$final_version = $versions|measure -maximum


foreach($t in $upload){
write_to_db -sqlserver $t.Server -version $t.Version -SP $t.ServicePack  -CU $t.CUNumber
}
}

function get_pagedetails{

$url = "https://learn.microsoft.com/en-us/troubleshoot/sql/releases/download-and-install-latest-updates";

$arc = Invoke-RestMethod -Uri $url
$HTML = New-Object -Com "HTMLFile"
try{
$HTML.IHTMLDocument2_write($arc)
}
catch{
 $src = [System.Text.Encoding]::Unicode.GetBytes($arc)
    $HTML.write($src)
}
$html = $HTML.body.outertext
#$html
get_2012($html)
get_2014($html)
get_2016($html)
get_2017($html)
get_2019($html)
get_2022($html)

}

$sql_proc = 'exec [dbo].[update_latest_version]'
get_pagedetails 
Invoke-Sqlcmd -ServerInstance $instance -Database $database -Query $sql_proc    