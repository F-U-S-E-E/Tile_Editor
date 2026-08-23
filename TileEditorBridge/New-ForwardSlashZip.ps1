function New-ForwardSlashZip {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    param(
        [Parameter(Mandatory = $true)]
        [string]$SourceDirectory,
        [Parameter(Mandatory = $true)]
        [string]$DestinationPath
    )

    Add-Type -AssemblyName System.IO.Compression
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $source = (Resolve-Path -LiteralPath $SourceDirectory).Path.TrimEnd(
        [System.IO.Path]::DirectorySeparatorChar)
    $rootName = Split-Path -Leaf $source
    if (!$PSCmdlet.ShouldProcess(
            $DestinationPath,
            "Create forward-slash ZIP archive")) {
        return
    }
    $archive = [System.IO.Compression.ZipFile]::Open(
        $DestinationPath,
        [System.IO.Compression.ZipArchiveMode]::Create)
    try {
        $fixedTimestamp = [System.DateTimeOffset]::new(
            2000, 1, 1, 0, 0, 0, [System.TimeSpan]::Zero)
        Get-ChildItem -LiteralPath $source -Recurse -File |
            Sort-Object FullName |
            ForEach-Object {
                $relative = $_.FullName.Substring(
                    $source.Length + 1).Replace("\", "/")
                $entryName = "$rootName/$relative"
                $entry = $archive.CreateEntry(
                    $entryName,
                    [System.IO.Compression.CompressionLevel]::Optimal)
                $entry.LastWriteTime = $fixedTimestamp
                $input = [System.IO.File]::OpenRead($_.FullName)
                try {
                    $output = $entry.Open()
                    try {
                        $input.CopyTo($output)
                    }
                    finally {
                        $output.Dispose()
                    }
                }
                finally {
                    $input.Dispose()
                }
            }
    }
    finally {
        if ($null -ne $archive) {
            $archive.Dispose()
        }
    }
}
