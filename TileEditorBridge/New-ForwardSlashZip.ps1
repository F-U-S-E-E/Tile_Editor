function New-ForwardSlashZip {
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
    $archive = [System.IO.Compression.ZipFile]::Open(
        $DestinationPath,
        [System.IO.Compression.ZipArchiveMode]::Create)
    try {
        Get-ChildItem -LiteralPath $source -Recurse -File |
            Sort-Object FullName |
            ForEach-Object {
                $relative = $_.FullName.Substring(
                    $source.Length + 1).Replace("\", "/")
                $entryName = "$rootName/$relative"
                [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile(
                    $archive,
                    $_.FullName,
                    $entryName,
                    [System.IO.Compression.CompressionLevel]::Optimal) |
                    Out-Null
            }
    }
    finally {
        if ($null -ne $archive) {
            $archive.Dispose()
        }
    }
}
