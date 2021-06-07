##Author : Arvinder
##Description : Replace specific keywords with some other keywords in files having common name patterns

cd \\Filepath ##Mention file path here

$files = (Get-ChildItem | Where-Object {$_.name -like"filepattern.txt"}).name ##Enter File pattern here

foreach ($file in $files) {

(Get-Content $file ).replace('originalkeyword','Newkeywords') | Set-Content $file -Verbose ##Enter both Keywords that will be replacement of other

}
