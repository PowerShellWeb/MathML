# MathML

MathML is an XML stanard for representing mathematics, and a part of HTML5.

## MathML Module

This module allows you to get MathML from anywhere and work with it as an object.

### Installing and Importing

MathML can be installed from the PowerShell gallery

~~~PowerShell
Install-Module MathML
~~~

After installation, you can import it like any module:

~~~PowerShell
Import-Module MathML
~~~

### Getting MathML

We can use `Get-MathML` (alias `MathML`) to extract MathML from a source

~~~PowerShell
MathML https://dlmf.nist.gov/2.1
~~~

This works for Wikipedia as well:

~~~PowerShell
$roseMath = MathML 'https://en.wikipedia.org/wiki/Rose_(mathematics)'
$roseMath
~~~

We can also pass MathML directly in

~~~PowerShell
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
~~~


We can get any previously loaded MathML by running Get-MathML with no parameters

~~~PowerShell
MathML
~~~

## Future Goals

MathML offers a unique opportunity for metaprogramming.

In theory, expressions in most programming languages, including PowerShell, could be written as MathML.

Thus one future goal is to provide translation from languages to MathML.

More interestingly, MathML could also represent a "base language" used to reconstruct expressions in other languages.

Thus the other major future goal is provide translation from MathML into various programming languages.