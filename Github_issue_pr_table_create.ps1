$token = read-host
$bod = '{  "query": " {  repository(name: \"ansible\", owner: \"ansible\") {    id   pullRequests(labels: \"windows\", states: OPEN, first: 100)    {      edges {        node {          title          number          url          body        }      }    } issues(labels: \"windows\", states: OPEN, first: 100) {      edges {        node {          title          url          body        number}      }    }  }}"}'
$res = Invoke-WebRequest -UseBasicParsing -Uri "https://api.github.com/graphql" -Headers @{"authorization"="bearer $token"} -Method Post -Body $bod
$jsn = $res.Content | ConvertFrom-Json
$issues = $jsn.data.repository.issues.edges.node
$issues | % {
    write-host "| <ul><li>[ ] </li></ul> | [$($_.number)]($($_.url)) | $($_.title) | |"
}
$pullrequests = $jsn.data.repository.pullRequests.edges.node
$pullrequests | % {
    write-host "| <ul><li>[ ] </li></ul> | [$($_.number)]($($_.url)) | $($_.title) | |"
}
