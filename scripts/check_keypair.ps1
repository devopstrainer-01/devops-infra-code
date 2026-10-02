$stdin = [Console]::In.ReadToEnd()
$query = $stdin | ConvertFrom-Json -ErrorAction Stop

$keyName = $query.key_name
$region  = $query.region

$ErrorActionPreference = "Continue"
aws ec2 describe-key-pairs --key-names $keyName --region $region *> $null

if ($LASTEXITCODE -eq 0) {
    $exists = "true"
} else {
    $exists = "false"
}

[PSCustomObject]@{ exists = $exists } | ConvertTo-Json -Compress

exit 0
