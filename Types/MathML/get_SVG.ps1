<#
.SYNOPSIS
    Gets MathML as SVG
.DESCRIPTION
    Gets a MathML equation within an SVG
.LINK
    https://developer.mozilla.org/en-US/docs/Web/SVG/Reference/Element/foreignObject
#>
[xml]@"
<svg xmlns="http://www.w3.org/2000/svg" width="100%" height="100%" font-size="3em">  
    <foreignObject x="0%" y="0%" width="100%" height="100%">
        $($this.OuterXml)
    </foreignObject>
</svg>
"@