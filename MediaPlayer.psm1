#require version 5

class Media {
    [string]      $Name
    [string]      $Path
    [string]      $Type
    [MediaStatus] $Status = [MediaStatus]::NotPlaying
    [int]         $Duration
    [bool]        $Loop = 0
	
    Media() {

    }

    [void] Play() {

    }

    [void] Pause() {

    }

    [void] Stop() {
		
    }


}

class Playlist {
    [int]      $Id
    [string]   $Name
    [Media[]] $Songs
    [string]   $Path
    [PlayMode] $Mode = [PlayMode]::Sequential

    Playlist() {
        
    }

    [void] Play() {

    }

    [void] Pause() {

    }

    [void] Stop() {
		
    }

    [Media] Current() {
        return ''
    }
}

enum MediaStatus {
    NotPlaying
    NowPlaying
    Paused
}

enum PlayMode {
    Sequential
    Shuffle
}

function New-Playlist {
    [CmdletBinding()]
    param (
        # Name
        [Parameter(Mandatory = $true)]
        [string] $Name,

        # Folder Location
        [Parameter(Mandatory = $false)]
        [string] $FolderLocation
    )
	
    begin {
        Write-Verbose "Checking if Playlist file is exist in `"$($env:TEMP + "\LuckyMediaPlayer\Playlists")`" folder"
        if (Test-Path -Path "$env:TEMP\LuckyMediaPlayer\Playlists\$Name.xml") {
			
            Write-Error "Invalid Name. Another playlist is already associated with this name `"$Name`""
            break
        } 
    }
	
    process {
        Write-Verbose "Creating playlist.."
        New-Item -Path "$env:TEMP\LuckyMediaPlayer\Playlists\" -Name "$Name.xml" -ItemType File -Force -Confirm:$false | Out-Null

        Write-Verbose 'Checking if $FolderLocation is given'
        if (![string]::IsNullOrEmpty($FolderLocation)) {
            if (Test-Path -Path $FolderLocation) {
                $AllMedia = Get-ChildItem -Path $FolderLocation -Recurse -Include *.mp3, *.wav

                if ($AllMedia.FullName.count -gt 0) {

                    $NewPlaylist = [Playlist]::new()
                    $NewPlaylist.Name = $Name
                    $NewPlaylist.Path = (Resolve-Path -Path $FolderLocation).Path

                    foreach ($Media in $AllMedia) {
                        $NewMedia = [Media]::new()
                        $NewMedia.Name = $Media.Name
                        $NewMedia.Path = $Media.FullName
                        $NewMedia.Type = ($Media.Extension.split("."))[1]
                        $NewMedia.Duration = Get-Duration($Media.FullName) 
                            
                        $NewPlaylist.Songs += $NewMedia
                    }

                    Export-Clixml -Path "$env:TEMP\LuckyMediaPlayer\Playlists\$Name.xml" -InputObject $NewPlaylist
                }
                else {
                    Write-Warning "The folder given has no media files. No media has been added."
                }

            }
            else {
                Write-Error "Invalid folder path `"$FolderLocation`"."
                break
            }
        }
    }
	
    end {
        Write-Output $NewPlaylist
    }
}

function Get-Playlist {
    [CmdletBinding()]
    param (
        # Name
        [Parameter(Mandatory = $false)]
        [string] $Name
    )
	
    begin {
    }
	
    process {
        if ([string]::IsNullOrEmpty($Name)) {
            $Playlists = Get-ChildItem -Path "$env:TEMP\LuckyMediaPlayer\Playlists\" -Filter *.xml

            foreach ($Item in $Playlists) {
                [Playlist] $Playlist = Import-Clixml -Path $Item.FullName

                Write-Output $Playlist
            }
        }
    }
	
    end {
    }
}

function Start-Playlist {
    [CmdletBinding()]
    param (
		
    )
	
    begin {
    }
	
    process {
    }
	
    end {
    }
}

function Stop-Playlist {
    [CmdletBinding()]
    param (
		
    )
	
    begin {
    }
	
    process {
    }
	
    end {
    }
}

function Add-ToPlaylist {
    [CmdletBinding()]
    param (
        # Playlist
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Playlist] $PlaylistName,
		
        # File Path
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string] $FilePath
    )
	
    begin {
    }
	
    process {
    }
	
    end {
    }
}

function Get-Duration ($Path) {
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