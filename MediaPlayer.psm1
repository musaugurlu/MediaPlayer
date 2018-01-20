class Media {
    [string]      $FullName
    [string]      $Path
    [string]      $Type
    [MediaStatus] $Status = [MediaStatus]::NotPlaying
    [int]         $Duration
    [int]         $Order
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
    [Media[]]  $Media
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
        if (Test-Path -Path "$env:TEMP\LuckyMediaPlayer\Playlists.list") {
			
            Write-Verbose "The file exists. Checking if the name `"$Name`" is given to another playlist"
            $Playlist = Import-Csv -Path "$env:TEMP\LuckyMediaPlayer\Playlists.list"
            if ($Playlist | Where-Object {$_.Name -eq $Name}) {
                Write-Error "Invalid Name. Another playlist is already associated with this name `"$Name`""
                break
            }

            Write-Verbose "The name `"$Name`" is valid"
        }
        else {
            Write-Verbose "The file Playlist.list is not exist. Creating a new one in $($env:TEMP + "\LuckyMediaPlayer") folder."
            New-Item -Path "$env:TEMP\LuckyMediaPlayer\" -Name "Playlists.list" -ItemType File -Force -Confirm:$false | Out-Null
        }
    }
	
    process {
        Write-Verbose 'Checking if $FolderLocation is given'
        if ([string]::IsNullOrEmpty($FolderLocation)) {
            Write-Verbose '$FolderLocation is not given. Empty playlist is being created.'
			New-EmptyPlaylist($Name)
			
        } else {
			if (Test-Path -Path $FolderLocation) {
				$AllMedia = Get-ChildItem -Path $FolderLocation -Recurse -Include *.mp3,*.wav

				if ($AllMedia.FullName.count -gt 0) {
					
				} else {
					Write-Verbose "The folder given has no media files. Empty playlist will be created"
					New-EmptyPlaylist($Name)
				}

			} else {
				Write-Error "Invalid folder path `"$FolderLocation`"."
				break
			}
		}
    }
	
    end {
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
        if (Test-Path -Path "$env:TEMP\LuckyMediaPlayer\Playlists.list") {
            $PlayLists = Import-Csv -Path "$env:TEMP\LuckyMediaPlayer\Playlists.list"
            if ($PlayLists.name.count -gt 0) {
                foreach ($PlayList in $PlayLists) {
                    $NewPlaylist = [Playlist]::new()
                    $NewPlaylist.Id = $PlayList.Id
                    $NewPlaylist.Name = $PlayList.Name

                    Write-Output $NewPlaylist
                }
            }
            else {
                $NewPlaylist = [Playlist]::new()
                Write-Output $NewPlaylist
            } 
        }
        else {
            $NewPlaylist = [Playlist]::new()
            Write-Output $NewPlaylist
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
		$NewPlaylist | Export-Csv -Path "$env:TEMP\LuckyMediaPlayer\Playlists.list" -NoTypeInformation -Append
	}
	catch {
		Write-Error "Couldn't write in `"$($env:TEMP + '\LuckyMediaPlayer\Playlists.list')`". Make sure you have sufficient permission to write in the folder`"."
	}

	return $NewPlaylist
}