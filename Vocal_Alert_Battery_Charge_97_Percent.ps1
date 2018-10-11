# Description : Will use speech to tell user that battery has been charged to 97% and can be removed
# IMP : Needs to be set on Task scheduler on a Laptop with run time always to make it work 

$battery = (Get-WmiObject -Class win32_battery).EstimatedChargeRemaining

If ($battery -gt 97) {

Add-Type -AssemblyName System.speech
$speak = New-Object System.Speech.Synthesis.SpeechSynthesizer
$speak.Speak('Battery is at Ninety Seven percent, Please disconnect AC adapter to protect Battery Cycle ')

}
