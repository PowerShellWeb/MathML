function Import-MathML
{
    <#
    .SYNOPSIS
        Imports MathML
    .DESCRIPTION
        Imports MathML from a file or URL
    .LINK
        Get-MathML
    #>
    [Alias('Restore-MathML')]
    param(
    # The path to a file or URL that hopefully contains MathML
    [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
    [string]
    $FilePath
    )

    process {
        # This is an extremely light wrapper of Get-MathML.
        Get-MathML @PSBoundParameters
    }

}
