function Get-Entries
{
    [CMDLetBinding()]
    Param(
        $list
    )
    $res = ""
    $list | % {
        $max_date = Get-Date ($_.comments.nodes | Measure-Object -Maximum -Property createdAt,lastEditedAt |  Measure-Object -Maximum -Property Maximum).Maximum -Format d
        $comps = $null
        $comp_section = ""
        $comp_section = $_.body.Split('#####') | Where-Object {$_ -ilike '*COMPONENT NAME*'}
        $comps = "$comp_section".Replace([regex]::Matches("$comp_section", '<!--.*-->', [System.Text.RegularExpressions.RegexOptions]::Singleline).value,' ').Split("`r`n",[System.StringSplitOptions]::RemoveEmptyEntries)
        if($comps) {
            $title = "$([String]::Join(',',$comps, 1, $comps.Length - 1))"
        } else {
            $title = "$($_.title)"
        }

        [String]::Format("| {0} | {1} | {2} |`r`n", 
                         "[$($_.number)]($($_.url))",
                         "$title",
                         "$max_date")
    }

    return $res
}

$token = Read-Host
$bod = '{ "query": " { repository(name: \"ansible\", owner: \"ansible\") { id pullRequests(labels: \"windows\", states: OPEN, last: 100) { nodes { comments(last: 100) { nodes { lastEditedAt createdAt } } title number url body } } issues(labels: \"windows\", states: OPEN, last: 100) { nodes { comments(last: 100) { nodes { lastEditedAt createdAt } } title number url body } } } }"}'
$res = Invoke-WebRequest -UseBasicParsing -Uri "https://api.github.com/graphql" -Headers @{"authorization"="bearer $token"} -Method Post -Body $bod

$jsn = $res.Content | ConvertFrom-Json

$issues = $jsn.data.repository.issues.nodes
[String]::Format("| Issue | Title / Module | Last comment |`r`n")
Get-Entries -list $issues

$pullrequests = $jsn.data.repository.pullRequests.nodes
[String]::Format("| PR | Title / Module | Last comment |`r`n")
Get-Entries -list $pullrequests
