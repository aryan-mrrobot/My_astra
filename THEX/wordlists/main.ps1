$source = "extensoon.txt"
$chunkSize = 90MB
$bufferSize = 4MB
$index = 0

$reader = [System.IO.File]::OpenRead($source)
$buffer = New-Object byte[] $bufferSize

while ($reader.Position -lt $reader.Length) {
    $chunkName = "extensoon_part_{0:D3}.txt" -f $index
    $chunk = [System.IO.File]::Create($chunkName)
    $written = 0
    while ($written -lt $chunkSize -and $reader.Position -lt $reader.Length) {
        $read = $reader.Read($buffer, 0, [Math]::Min($bufferSize, $chunkSize - $written))
        $chunk.Write($buffer, 0, $read)
        $written += $read
    }
    $chunk.Close()
    $index++
}

$reader.Close()
