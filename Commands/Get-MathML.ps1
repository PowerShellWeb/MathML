function Get-MathML
{
    <#
    .SYNOPSIS
        Gets MathML 
    .DESCRIPTION
        Gets MathML from a file or page
    .EXAMPLE
        MathML https://dlmf.nist.gov/2.1
    #>    
    [Alias('MathML')]
    param(
    # A url or file path that hopefully contains MathML
    # The response from this URL will be cached.
    [Parameter(ValueFromPipelineByPropertyName)]
    [Alias('Uri')]
    [string]
    $Url,    

    # If set, will request the URL, even if it has been cached.
    [Parameter(ValueFromPipelineByPropertyName)]
    [switch]
    $Force,

    # If set, will use chromium to request the page, and will 
    [Parameter(ValueFromPipelineByPropertyName)]
    [switch]
    $UseChromium,

    # The path to a chromium browser.
    [Parameter(ValueFromPipelineByPropertyName)]
    [string]
    $ChromiumPath = 'chromium'
    )

    begin {
        if (-not $script:MathMLCache) {
            $script:MathMLCache = [Ordered]@{}
        }
        
        $mathMlPattern = [Regex]::new('<math[\s\S]+?</math>','IgnoreCase')
    }

    process {
        if (-not $PSBoundParameters.Url) {
            $mathMLValues = @($script:MathMLCache.Values.MathML)
            if ($mathMLValues) {
                foreach ($value in $mathMLValues) {
                    if (-not $value) { continue }
                    $value
                }
            } else {
                
            }   
            return         
        }
        
        if (-not $script:MathMLCache["$url"] -or $Force) {
            $script:MathMLCache["$url"] = [Ordered]@{
                Response =
                    if ($url -as [xml]) {
                        $url -as [xml]
                    } elseif (Test-Path $url) {
                        Get-Content -Raw $Url
                    } elseif (-not $UseChromium) {                        
                        Invoke-RestMethod $url                        
                    } else {
                        & $ChromiumPath --headless --dump-dom --disable-gpu --no-sandbox "$url" *>&1 |
                            Where-Object { $_ -notmatch '^\[\d+:\d+' } |
                            Out-String -Width 1mb
                    }
            }
        }

        if (
            $script:MathMLCache["$url"].Response -and -not
            $script:MathMLCache["$url"].MathML
        ) {
            $script:MathMLCache["$url"].MathML =
                @(foreach ($match in $mathMlPattern.Matches("$(
                    $script:MathMLCache["$url"].Response
                )")) {
                    $matchXml = $match.Value -as [xml]
                    if ($matchXml) {
                        $matchXml.pstypenames.insert(0, 'MathML')
                    }
                    $matchXml
                })
            
        }

        $script:MathMLCache["$url"].MathML                
    }
}

