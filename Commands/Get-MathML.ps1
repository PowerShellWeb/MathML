function Get-MathML
{
    <#
    .SYNOPSIS
        Gets MathML 
    .DESCRIPTION
        Gets MathML from a file or page
    .EXAMPLE
        MathML https://dlmf.nist.gov/2.1
    .EXAMPLE
        MathML 'https://en.wikipedia.org/wiki/Rose_(mathematics)'
    .EXAMPLE
        MathML "<math xmlns='http://www.w3.org/1998/Math/MathML'>
            <semantics>
                <mrow>
                    <mn>1</mn>
                    <mo>+</mo>
                    <mn>1</mn>
                    <mo>=</mo>
                    <mn>2</mn>
                </mrow>
            </semantics>
        </math>"
    #>    
    [Alias('MathML')]
    param(
    # A url or file path that hopefully contains MathML
    # The response from this URL will be cached.
    [Parameter(ValueFromPipelineByPropertyName)]
    [Alias('Uri','FilePath','Fullname')]
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
        # If we have no URL
        if (-not $PSBoundParameters.Url) {
            # get any loaded MathML
            $mathMLValues = @($script:MathMLCache.Values.MathML)
            if ($mathMLValues) {
                # unroll each result
                foreach ($value in $mathMLValues) {
                    if (-not $value) { continue }
                    # and return non-null values
                    $value
                }
            }   
            return         
        }
        
        # If we have not yet cached this URL, or we are using the `-Force`
        if (-not $script:MathMLCache["$url"] -or $Force) {
            # Create a cache object
            $script:MathMLCache["$url"] = [Ordered]@{
                Response =
                    # If the URL could be XML
                    if ($url -as [xml]) {
                        # use that as the source.
                        ($url -as [xml]).OuterXml
                    }
                    # If the URL was actually a file path
                    elseif (Test-Path $url)
                    {
                        # get it's content.
                        Get-Content -Raw $Url
                    }
                    # If we are not using chromium,
                    elseif (-not $UseChromium)
                    {
                        # use Invoke-RestMethod to get the URL
                        Invoke-RestMethod $url                        
                    }
                    # If we are using chromium
                    else
                    {
                        # Call chromium in headless mode and dump DOM
                        & $ChromiumPath --headless --disable-gpu --no-sandbox --dump-dom "$url" *>&1 |
                            # strip out any chromium trace messages
                            Where-Object { $_ -notmatch '^\[\d+:\d+' } |
                            # and stringify the whole response.
                            Out-String -Width 1mb
                    }
            }
        }

        # If we have a response for this URL, but no MathML yet
        if (
            $script:MathMLCache["$url"].Response -and -not
            $script:MathMLCache["$url"].MathML
        ) {
            $script:MathMLCache["$url"].MathML =
                # find any matches for our pattern
                @(foreach ($match in $mathMlPattern.Matches("$(
                    $script:MathMLCache["$url"].Response
                )")) {
                    # and cast them into XML.
                    $matchXml = $match.Value -as [xml]
                    
                    if (-not $matchXML) { continue }
                    # If they do not have the xml namespace
                    if (-not $matchXML.math.xmlns) {
                        # add it
                        $matchXML.math.setAttribute('xmlns', 'http://www.w3.org/1998/Math/MathML')
                    }
                    # decorate the return as MathML
                    $matchXml.pstypenames.insert(0, 'MathML')
                    # and output it to the cache
                    $matchXml                
                })
            
        }

        # Last but not least, output any MathML objects in the cache for this URL.
        $script:MathMLCache["$url"].MathML
    }
}

