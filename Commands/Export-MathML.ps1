function Export-MathML {
    <#
    .SYNOPSIS
        Exports MathML
    .DESCRIPTION
        Exports MathML into a file
    .EXAMPLE
        MathML https://dlmf.nist.gov/2.1 | 
            Export-MathML ./dlmf.2.1.html
    #>
    [Alias('Save-MathML')]    
    param(
    # The export file path.
    [Parameter(Mandatory)]
    [Alias('Fullname')]
    [string]
    $FilePath,

    # Any input objects.
    [Parameter(ValueFromPipeline)]
    [PSObject[]]
    $InputObject,

    # If set, will force an export, even if a file already exists.
    [switch]
    $Force
    )

    # Gather all the input
    $allInput = @($input)
    
    # If nothing was passed
    if ($allInput.Length -eq 0) {
        # briefly check for non-piped -InputObject
        if ($PSBoundParameters.InputObject) {
            $allInput = @($PSBoundParameters.InputObject | . { process { $_ } })
        }
        # If we still have no input, return (there is nothing to export)
        if ($allInput.Length -eq 0) {return}
    }
    
    # Find the full path, but do not resolve it
    $unresolvedPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($FilePath)
    # If it already existed, and we are not using the `-Force`
    if ((Test-Path $unresolvedPath) -and -not $Force) {
        # write an error
        Write-Error "$unresolvedPath already exists, use -Force"
        # and return
        return
    }
    
    
    # IF we have one MathML 
    if ($allInput.Length -eq 1 -and $allInput[0] -is [xml]) {
        # save that to a file
        $newFile = New-Item -Path $unresolvedPath -Force -ItemType File
        # If the extension was .svg or .html, and the input has an SVG
        if ($newFile.Extension -in '.svg', '.html' -and $allInput[0].SVG -is [xml]) {
            # save the SVG to the file
            $allInput[0].SVG.Save($newFile.FullName)
        } else {
            # otherwise, save the XML to the file
            $allInput[0].Save($newFile.FullName)
        }        
    }
    # If we have multiple MathML
    else {
        # we can store them in an XHTML file
        $html = @(
            # construct a simple header
            "<html><title>MathML</title><body>"
            foreach ($in in $allInput) {
                # and put each MathML within a div
                "<div>"

                # If it was XML
                if ($in -is [xml]) {
                    $in.OuterXml # put it inline
                } 
                # If there was a SVG property
                elseif ($in.SVG) {
                    # put that inline
                    $in.SVG.OuterXml
                }
                # If there was a HTML property
                elseif ($in.HTML) {
                    # put that inline (if it was unbalanced, export will not work)
                    $in.HTML
                }
                # last but not least, escape any text
                else {                    
                    [Security.SecurityElement]::Escape("$in")
                }
                "</div>"
            }
            "</body></html>"
        ) -join [Environment]::NewLine

        # Create a new file containing the HTML
        New-Item -Path $unresolvedPath -Force -ItemType File -Value $html
    }
}
