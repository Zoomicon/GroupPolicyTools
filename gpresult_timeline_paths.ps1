$ErrorActionPreference = 'Stop'

$outFile = 'gpresult_timeline_paths.txt'
"Group Policy timeline with XML paths (consecutive gpresult_YYYYMMDD.xml snapshots)" | Out-File -FilePath $outFile -Encoding UTF8
"" | Out-File -FilePath $outFile -Append

$files = Get-ChildItem -LiteralPath . -Filter 'gpresult_*.xml' | Sort-Object Name
if (-not $files) {
    'No gpresult_*.xml files found.' | Out-File -FilePath $outFile -Append
    exit 0
}

Write-Host "[DEBUG] Found $($files.Count) file(s)."

$prev = $files[0]
Write-Host "[DEBUG] Starting point is $($prev.Name)"
"Starting point: $($prev.Name)" | Out-File -FilePath $outFile -Append
"" | Out-File -FilePath $outFile -Append

# Helper: Recursively collect leaf values keyed by unique XPath
function Get-LeafNodes {
    param ([System.Xml.XmlNode]$Node, [string]$CurrentPath = "")
    $leaves = @{}

    # Skip processing for non-element/document nodes (except text itself)
    if ($Node.NodeType -eq 'Text') {
        # Parent element path is the key
        return @{ $CurrentPath = $Node.Value }
    }
    
    # Traverse children
    if ($Node.HasChildNodes) {
        # Group children by tag name to assign index [1], [2]...
        $tagCounts = @{}
        foreach ($child in $Node.ChildNodes) {
            if ($child.NodeType -eq 'Element') {
                $name = $child.Name
                $idx = if ($tagCounts.ContainsKey($name)) { $tagCounts[$name] + 1 } else { 1 }
                $tagCounts[$name] = $idx
                
                $childPath = "$CurrentPath/$name[$idx]"
                $childLeaves = Get-LeafNodes -Node $child -CurrentPath $childPath
                foreach ($k in $childLeaves.Keys) { $leaves[$k] = $childLeaves[$k] }
            }
            elseif ($child.NodeType -eq 'Text' -and -not [string]::IsNullOrWhiteSpace($child.Value)) {
                # Text content of current element
                $leaves[$CurrentPath] = $child.Value.Trim()
            }
        }
    }
    return $leaves
}

for ($i = 1; $i -lt $files.Count; $i++) {
    $cur = $files[$i]
    Write-Host "[DEBUG] Comparing $($cur.Name) to $($prev.Name)"
    '==========================================================' | Out-File -FilePath $outFile -Append
    "Changes in $($cur.Name) (vs $($prev.Name)):" | Out-File -FilePath $outFile -Append
    "" | Out-File -FilePath $outFile -Append

    try {
        [xml]$oldXml = Get-Content -LiteralPath $prev.FullName
        [xml]$newXml = Get-Content -LiteralPath $cur.FullName
        
        # Map Path -> Value for both files
        $oldLeaves = Get-LeafNodes -Node $oldXml.DocumentElement -CurrentPath ""
        $newLeaves = Get-LeafNodes -Node $newXml.DocumentElement -CurrentPath ""
        
        # Compare sets
        $allPaths = $oldLeaves.Keys + $newLeaves.Keys | Select-Object -Unique | Sort-Object

        foreach ($path in $allPaths) {
            $oldVal = if ($oldLeaves.ContainsKey($path)) { $oldLeaves[$path] } else { $null }
            $newVal = if ($newLeaves.ContainsKey($path)) { $newLeaves[$path] } else { $null }
            
            if ($oldVal -ne $newVal) {
                "PATH: $path" | Out-File -FilePath $outFile -Append
                if ($oldVal -ne $null) { "OLD: $oldVal" | Out-File -FilePath $outFile -Append }
                if ($newVal -ne $null) { "NEW: $newVal" | Out-File -FilePath $outFile -Append }
                "" | Out-File -FilePath $outFile -Append
            }
        }
    } catch {
        "Error comparing XMLs: $_" | Out-File -FilePath $outFile -Append
    }
    
    "" | Out-File -FilePath $outFile -Append
    $prev = $cur
}

"Timeline with paths written to $outFile" | Out-File -FilePath $outFile -Append
