# demo.tape — generates demo/scan.gif with charmbracelet/vhs
# install: sudo pacman -S vhs   |   build: vhs demo.tape
Output demo/scan.gif

Set Shell "bash"
Set FontFamily "monospace"
Set FontSize 10
Set Width 1000
Set Height 560
Set Theme "Monochrome"
Set Padding 20

Type "silverpurge --version"
Enter
Sleep 1s

Type "silverpurge --help"
Enter
Sleep 3s

Type "silverpurge scan"
Enter
Sleep 4s
