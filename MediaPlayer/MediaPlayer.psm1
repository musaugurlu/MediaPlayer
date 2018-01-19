class Media 
{
	[string] $FullName
	[string] $Path
	[string] $Type
	[string] $Status
	[int]    $Duration
	[int]    $Order
	
	Media() 
	{

	}

	[void] Play()
	{

	}

	[void] Pause()
	{

	}

	[void] Stop()
	{
		
	}


}

class Playlist {
	[Media[]]  $Media
	[string]   $FolderLocation
	[PlayMode] $Mode

	Playlist()
	{

	}

	[void] Play()
	{

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

enum PlayMode {
	Sequential = 1
	Shuffle = 2
}

function New-Playlist {
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

function Get-Playlist {
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