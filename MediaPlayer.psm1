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
    [System.Collections.Generic.List[Media]] $Songs
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
        Write-Verbose "Checking if Playlist.list file is exist in `"$($env:TEMP + "\LuckyMediaPlayer")`" folder"
        if (Test-Path -Path "$env:TEMP\LuckyMediaPlayer\Playlists.xml") {
			
            Write-Verbose "The file exists. Checking if the name `"$Name`" is given to another playlist"
            [xml] $Playlist = Import-Clixml -Path "$env:TEMP\LuckyMediaPlayer\Playlists.xml"
            if ($Playlist | Where-Object {$_.Name -eq $Name}) {
                Write-Error "Invalid Name. Another playlist is already associated with this name `"$Name`""
                break
            }

            Write-Verbose "The name `"$Name`" is valid"
        }
        else {
            Write-Verbose "The file Playlist.list is not exist. Creating a new one in $($env:TEMP + "\LuckyMediaPlayer") folder."
            New-Item -Path "$env:TEMP\LuckyMediaPlayer\" -Name "Playlists.xml" -ItemType File -Force -Confirm:$false | Out-Null
        }
    }
	
    process {
        Write-Verbose "Creating playlist.."
        $NewPlaylist = New-EmptyPlaylist($Name)

        Write-Verbose 'Checking if $FolderLocation is given'
        if (![string]::IsNullOrEmpty($FolderLocation)) {
            if (Test-Path -Path $FolderLocation) {
                $AllMedia = Get-ChildItem -Path $FolderLocation -Recurse -Include *.mp3, *.wav

                if ($AllMedia.FullName.count -gt 0) {
                    foreach ($Media in $AllMedia) {
                        $NewMedia = [Media]::new()
                        $NewMedia.Name = $Media.Name
                        $NewMedia.Path = $Media.FullName
                        $NewMedia.Type = ($Media.Extension.split("."))[1]
                        $NewMedia.Duration = Get-Duration($Media.FullName) 
                            
                        $NewPlaylist.Songs += $NewMedia

                        Save-Playlist($NewPlaylist)
                    }
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
        if (Test-Path -Path "$env:TEMP\LuckyMediaPlayer\Playlists.xml") {
            $PlayLists = Get-Content -Path "$env:TEMP\LuckyMediaPlayer\Playlists.xml" -Raw | ConvertFrom-Json
            if ($PlayLists.name.count -gt 0) {
                foreach ($PlayList in $PlayLists) {
                    $NewPlaylist = [Playlist]::new()
                    $NewPlaylist.Id = $PlayList.Id
                    $NewPlaylist.Name = $PlayList.Name

                    Write-Output $NewPlaylist
                }
            }
            else {
                Write-Output "No Playlist found"
            } 
        }
        else {
            Write-Output "No Playlist found"
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

function New-EmptyPlaylist ($Name) {
    $NewPlaylist = [Playlist]::new()
    $NewPlaylist.Id = ((Get-Playlist | Sort-Object -Property Id | Select-Object -Last 1 -Property Id)[0].Id + 1)
    $NewPlaylist.Name = $Name

    Write-Verbose 'New playlist is being written in to playlist.list'
    try {
        $NewPlaylist | Export-Clixml -Path "$env:TEMP\LuckyMediaPlayer\Playlists.xml" -Append -Force
    }
    catch {
        Write-Error "Couldn't write in `"$($env:TEMP + '\LuckyMediaPlayer\Playlists.xml')`". Make sure you have sufficient permission to write in the folder`"."
        break
    }

    return $NewPlaylist
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

function Save-Playlist([Playlist] $NewPlaylist) {
    $CurrentPlaylist = Import-Clixml -Path "$env:TEMP\LuckyMediaPlayer\Playlists.xml"
    
    foreach ($item in $CurrentPlaylist) {
        if ($item.id == $NewPlaylist.Id) {
            $item = $NewPlaylist            
        }
    }
    
    $CurrentPlaylist | Export-Clixml -Path "$env:TEMP\LuckyMediaPlayer\Playlists.xml" -Force
}