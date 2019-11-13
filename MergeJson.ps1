Param (
	[Parameter(Mandatory = $true)] [string] $json1,
    [Parameter(Mandatory = $true)] [string] $json2,
    [int] $depth = 100
)

function Merge-Objects($source, $extend){
    if ($source.GetType().Name -eq "PSCustomObject" -and $extend.GetType().Name -eq "PSCustomObject") {
        foreach ($Property in $source | Get-Member -type NoteProperty, Property) {
            if ($null -eq $extend.$($Property.Name)) {
              continue;
            }

            $source.$($Property.Name) = Merge-Objects $source.$($Property.Name) $extend.$($Property.Name)
        }
        foreach($Property in $extend | Get-Member -type NoteProperty, Property) {
            if($null -eq $source.$($Property.Name)) {
                $source | Add-Member -MemberType NoteProperty -Value $extend.$($Property.Name) -Name $Property.Name `
            }
        }
    }
    else {
        $source = $extend;
    } 
        
    #Powershell inconsistencies
    if($source.GetType().Name -eq "Object[]" -and $source.Count -lt 2) {
        return ,$source
    }
        

    return $source
}

$js1 = Get-Content -Path $json1 -Raw | ConvertFrom-Json
$js2 = Get-Content -Path $json2 -Raw | ConvertFrom-Json

return (Merge-Objects $js1 $js2) | ConvertTo-Json -Depth $depth