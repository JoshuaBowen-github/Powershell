# PATHS TO BE CHECKED
param(
	[Parameter(Mandatory=$true)]
	[string[]]$Paths,
	
	[Parameter(Mandatory=$true)]
	[string]$OutputPath
)

# CHECK ALL FILES AND SUBFOLDERS
$files1 = Get-ChildItem -Path $path1 -File -Recurse
$files2 = Get-ChildItem -Path $path2 -File -Recurse

# Start array to hold duplicates
$duplicates = @()
$totalSizeBytes = 0

# Compare files based on name and creation date
foreach ($path in $Paths) {
	$allfiles += Get-ChildItem -Path $path -File -Recurse
}

for ($i = 0; $i -lt $allFiles.Count; $i++) {
	for ($j = $i + 1; $j -lt $allFiles.Count; $j++) {
		$file1 = $allFiles[$i]
		$file2 = $allfiles[$j]
		
        if ($file1.Name -eq $file2.Name -and $file1.CreationTime -eq $file2.CreationTime) {
            $size1 = $file1.Length  
            $size2 = $file2.Length  
            $totalSizeBytes += $size1 + $size2  

            $duplicates += [PSCustomObject]@{
                FileName = $file1.Name  
                Path1 = $file1.FullName  
                Path1CreationDate = $file1.CreationTime  
                Path1LastModified = $file1.LastWriteTime  
                Path1SizeMB = [math]::Round($size1 / 1MB, 2)  
                Path2 = $file2.FullName  
                Path2CreationDate = $file2.CreationTime  
                Path2LastModified = $file2.LastWriteTime  
                Path2SizeMB = [math]::Round($size2 / 1MB, 2)  
            }
        }
    }
}

# Calculate total size in gigabytes
$totalSizeGB = [math]::Round($totalSizeBytes / 1GB, 2)

# Output
if ($duplicates.Count -eq 0) {
    Write-Output "No duplicate files found."
} else {
    Write-Output "Duplicate files found:"
    $duplicates | Format-Table -AutoSize
    Write-Output "Total size of duplicated files: $totalSizeGB GB"
}

# Export results to a CSV file
$duplicates | Export-Csv -Path $OutputPath -NoTypeInformation


