<#

Configure Windows 11

A PowerShell script used to configure things how I like them on Windows 11.
Created by Daniel Gilbert on 2025-01-11.

Note: You may have to enable a different execution policy to run this script.
      For example, RemoteSigned may work.
      You can do this by running the following PowerShell command:
      set-executionpolicy remotesigned
      If you're particular, you can limit scope to the process, etc.

Usage:
.\config-win11.ps1

Some things this script does:
- Increases display size for easy viewing.
- Creates a "Shortcuts" folder on the Desktop for hotkey-activated lnk files.
- Installs and configures Notepad++.

Keyboard shortcuts that will be configured:
- Notepad++: ctrl+alt+n

#>

$sys_drive        = $env:systemdrive
$user             = "user" # Win11 Username
$clear_pass       = "user" # Win11 Password
$secure_pass      = convertto-securestring $clear_pass -asplaintext -force
$user_cred        = new-object system.management.automation.pscredential `
                               $user, $secure_pass
$home_dir         = "${sys_drive}\users\${user}"
$shortcuts_dir    = "${home_dir}\desktop\Shortcuts"

# Functions must be declared before use (above calls).
# Scroll to bottom of script for main script logic.

# This should increase the OS display scale to 125%.
# You may have to adjust the sendkeys() args as required if the UI changes.
# Alas, there is no way but WSH Shell (COM Object) to do this part.
function increaseDisplayScale {
  explorer ms-settings:display
  start-sleep -seconds 2
  # Create Windows Script Host shell:
  # https://learn.microsoft.com/en-us/previous-versions/windows/
  # internet-explorer/ie-developer/windows-scripting/ahcz2kh6(v=vs.84)
  $shell = new-object -comobject wscript.shell
  start-sleep -seconds 1
  $shell.sendkeys("{tab 8}{down 1}")
  start-sleep -seconds 1
  $shell.sendkeys("%{f4}")
}

# Create a Shortcuts directory on the user home Desktop.
function createShortcutsDir {
  mkdir -force "${shortcuts_dir}" | out-null
}

# Install and configure Notepad++.
# This is still a work in progress.
# Will probably circle back to this at the end...
function installNotepadPlusPlus {
  # This command just accepts the agreement for msstore to use winget.
  winget search notepad --accept-source-agreements | out-null
  winget install notepad++
  $npp_program = cmd /c "dir /s/b c:\*notepad++.exe"
  # If the appdata config file is not found, try to uncomment the line below
  # to ensure it gets created by launching Notepad++ as the target user.
  # start-process $npp_program -credential $cred
  $shell = new-object -comobject wscript.shell
  start-sleep -seconds 1
  $shortcut = $shell.createshortcut("${shortcuts_dir}\Notepad++.lnk")
  $shortcut.targetpath = $npp_program
  $shortcut.hotkey = "Ctrl+Alt+N"
  $shortcut.save()
  $npp_config = "${env:appdata}\notepad++\config.xml"
  # Enable Dark Mode.
  (get-content $npp_config) `
    -replace  'name="DarkMode" enable="no"', `
              'name="DarkMode" enable="yes"' `
    | set-content $npp_config
  # Convert tabs to spaces and set width to 2.
  (get-content $npp_config) `
    -replace  'name="TabSetting" replaceBySpace="no" size="4"', `
              'name="TabSetting" replaceBySpace="yes" size="2"' `
    | set-content $npp_config
}

# Begin main script logic.
# Basically, just run the configurations sequentially...

# Temporarily commented out to make testing easier...
#increaseDisplayScale
createShortcutsDir
installNotepadPlusPlus


