#require version 5


#Init LuckyPlayer
Add-Type -AssemblyName presentationCore
Add-Type -AssemblyName System.Windows.Forms
$Global:LuckyPlayer = New-Object System.Windows.Media.MediaPlayer

class Media
{
    [string]      $Name
    [string]      $Path
    [string]      $Type
    [MediaStatus] $Status = [MediaStatus]::NotPlaying
    [int]         $Duration
    [bool]        $Loop = 0
    [int]         $PlaylistOrder
	
    Media()
    {

    }
}

class Playlist
{
    [int]      $Id
    [string]   $Name
    [Media[]] $Songs
    [string]   $Path
    [PlayMode] $Mode = [PlayMode]::Sequential
    [int] $CurrentSong = 0

    Playlist()
    {
        
    }

    [void] Start()
    {
        if (($this.Songs.Count -gt 0) -and ($this.CurrentSong -lt $this.Songs.Count))
        {
            $Global:LuckyPlayer.Open($this.Songs[$this.CurrentSong].Path)
            Start-Sleep -Seconds 2
            $SongLength = $Global:LuckyPlayer.NaturalDuration.TimeSpan.TotalSeconds
            Invoke-BalloonTip -Message "Now Playing `n $($this.Songs[$this.CurrentSong].Name)" -Title "Lucky Media Player" -MessageType Info
            $Global:LuckyPlayer.Play()
            Start-Sleep -Seconds $SongLength
            $this.CurrentSong++
            $this.Start()
        }
        elseif (($this.Songs.Count -gt 0) -and (($this.CurrentSong -ge $this.Songs.Count) -or ($this.CurrentSong -lt 0)))
        {
            $this.CurrentSong = 0
            $this.Stop()
        }
        else
        {
            Write-Host "No song found!"
            break
        }

    }

    [void] Pause()
    {

    }

    [void] Stop()
    {
		
    }

    [Media] Current()
    {
        return ''
    }
}

enum MediaStatus
{
    NotPlaying
    NowPlaying
    Paused
}

enum PlayMode
{
    Sequential
    Shuffle
}

function New-Playlist
{
    [CmdletBinding()]
    param (
        # Name
        [Parameter(Mandatory = $true)]
        [string] $Name,

        # Folder Location
        [Parameter(Mandatory = $false)]
        [string] $FolderLocation
    )
	
    begin
    {
        Write-Verbose "Checking if Playlist file is exist in `"$($env:TEMP + "\LuckyMediaPlayer\Playlists")`" folder"
        if (Test-Path -Path "$env:TEMP\LuckyMediaPlayer\Playlists\$Name.xml")
        {
			
            Write-Error "Invalid Name. Another playlist is already associated with this name `"$Name`""
            break
        } 
    }
	
    process
    {
        # Write-Verbose "Creating playlist.."
        # New-Item -Path "$env:TEMP\LuckyMediaPlayer\Playlists\" -Name "$Name.xml" -ItemType File -Force -Confirm:$false | Out-Null

        Write-Verbose 'Checking if $FolderLocation is given'
        if (![string]::IsNullOrEmpty($FolderLocation))
        {
            if (Test-Path -Path $FolderLocation)
            {
                
                $NewPlaylist = [Playlist]::new()
                $NewPlaylist.Id = [int](Get-PlaylistID)
                $NewPlaylist.Name = $Name
                $NewPlaylist.Path = (Resolve-Path -Path $FolderLocation).Path

                $AllMedia = Get-ChildItem -Path $FolderLocation -Recurse -Include *.mp3, *.wav

                if ($AllMedia.FullName.count -gt 0)
                {
                    foreach ($Media in $AllMedia)
                    {
                        $NewMedia = [Media]::new()
                        $NewMedia.Name = $Media.Name
                        $NewMedia.Path = $Media.FullName
                        $NewMedia.Type = ($Media.Extension.split("."))[1]
                        $NewMedia.Duration = Get-Duration($Media.FullName) 
                            
                        $NewPlaylist.Songs += $NewMedia
                    } 
                }
                else
                {
                    Write-Warning "The folder given has no media files. No media has been added."
                }

                New-Item -Path "$env:TEMP\LuckyMediaPlayer\Playlists\" -Name "$Name.xml" -ItemType File -Force -Confirm:$false | Out-Null
                Export-Clixml -Path "$env:TEMP\LuckyMediaPlayer\Playlists\$Name.xml" -InputObject $NewPlaylist
            }
            else
            {
                Write-Error "Invalid folder path `"$FolderLocation`"."
                break
            }
        }
    }
	
    end
    {
        Write-Output $NewPlaylist
    }
}

function Get-Playlist
{
    [CmdletBinding()]
    param (
        # Name
        [Parameter(Mandatory = $false)]
        [string] $Name
    )
	
    begin
    {
        if (-not(Test-Path "$env:TEMP\LuckyMediaPlayer\Playlists\") -or -not(Get-ChildItem "$env:TEMP\LuckyMediaPlayer\Playlists\"))
        {
            Write-Host "No playlist found!"
            break
        }
    }
	
    process
    {
        if ([string]::IsNullOrEmpty($Name))
        {
            $Playlists = Get-ChildItem -Path "$env:TEMP\LuckyMediaPlayer\Playlists\" -Filter *.xml

            foreach ($Item in $Playlists)
            {
                [Playlist] $Playlist = Import-Clixml -Path $Item.FullName

                Write-Output $Playlist
            }
        }
    }
	
    end
    {
    }
}

function Start-Playlist
{
    [CmdletBinding()]
    param (
		
    )
	
    begin
    {
    }
	
    process
    {
    }
	
    end
    {
    }
}

function Stop-Playlist
{
    [CmdletBinding()]
    param (
		
    )
	
    begin
    {
    }
	
    process
    {
    }
	
    end
    {
    }
}

function Add-ToPlaylist
{
    [CmdletBinding()]
    param (
        # Playlist
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Playlist] $PlaylistName,
		
        # File Path
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string] $FilePath
    )
	
    begin
    {
    }
	
    process
    {
    }
	
    end
    {
    }
}

function Get-PlaylistID
{
    if (-not(Test-Path "$env:TEMP\LuckyMediaPlayer\Playlists\"))
    {
        return 1
    }
    else
    {
        $Items = Get-ChildItem -Path "$env:TEMP\LuckyMediaPlayer\Playlists\" -Filter *.xml

        if ($Items.FullName.count -lt 1)
        {
            return 1
        }
        else
        {
            
            [Playlist[]] $AllPlaylists = @()

            foreach ($Item in $Items)
            {
                [Playlist] $Playlist = Import-Clixml -Path $Item.FullName 

                $AllPlaylists += $Playlist
            }

            $AllPlaylists = $AllPlaylists | Sort-Object -Property Id

            return ($AllPlaylists[-1].Id + 1)
        }
    }
}

function Get-Duration ($Path)
{
    # Part of this code copied from https://superuser.com/questions/704575/get-song-duration-from-an-mp3-file-in-a-script
    $shell = New-Object -COMObject Shell.Application
    $folder = Split-Path $Path
    $file = Split-Path $Path -Leaf
    $shellfolder = $shell.Namespace($folder)
    $shellfile = $shellfolder.ParseName($file)

    $Duration = $shellfolder.GetDetailsOf($shellfile, 27);
    $Time = $Duration.split(":")
    #convert string type duration to int type seconds
    return (([int]$Time[0] * 60 * 60) + ([int]$Time[1] * 60) + ([int]$Time[2]))
}

# Below script is copied from https://github.com/proxb/PowerShell_Scripts/blob/master/Invoke-BalloonTip.ps1
Function Invoke-BalloonTip
{
    <#
    .Synopsis
        Display a balloon tip message in the system tray.
    .Description
        This function displays a user-defined message as a balloon popup in the system tray. This function
        requires Windows Vista or later.
    .Parameter Message
        The message text you want to display.  Recommended to keep it short and simple.
    .Parameter Title
        The title for the message balloon.
    .Parameter MessageType
        The type of message. This value determines what type of icon to display. Valid values are
    .Parameter SysTrayIcon
        The path to a file that you will use as the system tray icon. Default is the PowerShell ISE icon.
    .Parameter Duration
        The number of seconds to display the balloon popup. The default is 1000.
    .Inputs
        None
    .Outputs
        None
    .Notes
         NAME:      Invoke-BalloonTip
         VERSION:   1.0
         AUTHOR:    Boe Prox
    #>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $True, HelpMessage = "The message text to display. Keep it short and simple.")]
        [string]$Message,

        [Parameter(HelpMessage = "The message title")]
        [string]$Title = "Attention $env:username",

        [Parameter(HelpMessage = "The message type: Info,Error,Warning,None")]
        [System.Windows.Forms.ToolTipIcon]$MessageType = "Info",
     
        [Parameter(HelpMessage = "The path to a file to use its icon in the system tray")]
        [string]$SysTrayIconPath = 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe',     

        [Parameter(HelpMessage = "The number of milliseconds to display the message.")]
        [int]$Duration = 1000
    )

    Add-Type -AssemblyName System.Windows.Forms

    If (-NOT $global:balloon)
    {
        $global:balloon = New-Object System.Windows.Forms.NotifyIcon

        #Mouse double click on icon to dispose
        [void](Register-ObjectEvent -InputObject $balloon -EventName MouseDoubleClick -SourceIdentifier IconClicked -Action {
                #Perform cleanup actions on balloon tip
                Write-Verbose 'Disposing of balloon'
                $global:balloon.dispose()
                Unregister-Event -SourceIdentifier IconClicked
                Remove-Job -Name IconClicked
                Remove-Variable -Name balloon -Scope Global
            })
    }

    #Need an icon for the tray
    $path = Get-Process -id $pid | Select-Object -ExpandProperty Path

    #Extract the icon from the file
    $balloon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($SysTrayIconPath)

    #Can only use certain TipIcons: [System.Windows.Forms.ToolTipIcon] | Get-Member -Static -Type Property
    $balloon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]$MessageType
    $balloon.BalloonTipText = $Message
    $balloon.BalloonTipTitle = $Title
    $balloon.Visible = $true

    #Display the tip and specify in milliseconds on how long balloon will stay visible
    $balloon.ShowBalloonTip($Duration)

    Write-Verbose "Ending function"

}