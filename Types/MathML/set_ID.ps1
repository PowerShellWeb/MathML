<#
.SYNOPSIS
    Sets a MathML id
.DESCRIPTION
    Sets the ID attribute on a MathML element.

    MathML does not need to have an identifier, but it certainly can help.
#>
$this.Math.setAttribute("id", "$args")