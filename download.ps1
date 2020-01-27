#!/usr/bin/env pwsh
# Command-line arguments
Param([String]$id, [Int]$version)
# Definition of platforms to download
$platforms = "ANDROID", "IOS"
# Format validation of a theme ID
function ValidateThemeIdFormat([String]$id) {
  return ($id.Length -ge 6) -and ($id -cmatch "^[-a-z0-9]+$")
}
# Checks if it is able to get the URI content
function CheckHttpResponseStatus([String]$uri) {
  try {
    Invoke-WebRequest -Uri $uri -Method GET -UseBasicParsing > $Null
    return $True
  } catch {
    return $False
  }
}
# Returns the URI of a small asset associated with the specified theme
function BuildThemeEvidenceUri([String]$id, [Int]$version) {
  $subdir1 = $id.Substring(0, 2)
  $subdir2 = $id.Substring(2, 2)
  $subdir3 = $id.Substring(4, 2)
  $baseuri = "http://dl.shop.line.naver.jp/themeshop/v1/products"
  $packuri = "{0}/{1}/{2}/{3}/{4}" -f $baseuri, $subdir1, $subdir2, $subdir3, $id
  return "{0}/{1}/ANDROID/icon_86x123.png" -f $packuri, $version
}
# Returns the URI of the specified theme's zip
function BuildThemeZipUri([String]$id, [Int]$version, [String]$platform) {
  $subdir1 = $id.Substring(0, 2)
  $subdir2 = $id.Substring(2, 2)
  $subdir3 = $id.Substring(4, 2)
  $baseuri = "http://dl.shop.line.naver.jp/themeshop/v1/products"
  $packuri = "{0}/{1}/{2}/{3}/{4}" -f $baseuri, $subdir1, $subdir2, $subdir3, $id
  return "{0}/{1}/{2}/theme.zip" -f $packuri, $version, $platform
}
# Whether the URI content as a evidence of the theme existence exists
function CheckThemeExistence([String]$id, [Int]$version=1) {
  return CheckHttpResponseStatus (BuildThemeEvidenceUri $id $version)
}
# Returns a filename to save a theme zip
function BuildThemeZipFilename([String]$id, [Int]$version, [String]$platform) {
  return "Theme-{0}-{1}-{2}.zip" -f $id, $version, $platform
}
# Downloads the zip of the specified theme and returns the path saved to
function DownloadThemeZip([String]$id, [Int]$version, [String]$platform) {
  $uri = BuildThemeZipUri $id $version $platform
  $path = BuildThemeZipFilename $id $version $platform
  Invoke-WebRequest -Uri $uri -OutFile $path -UseBasicParsing
  return $path
}
# Show help
if (-not $id) {
  Write-Output "* Usage *"
  Get-Help $PSCommandPath
  exit 0
}
# Verify the command-line arguments
if ($version -lt -1) {
  throw "Package version parameter out of range"
}
if (-not (ValidateThemeIdFormat $id)) {
  throw "Invalid package ID format"
}
# Check the specified theme exists
if ($version -lt 1) {
  if (-not (CheckThemeExistence $id)) {
    throw "No such theme package"
  }
  Write-Output ("Verified: {0}" -f $id)
} else {
  if (-not (CheckThemeExistence $id $version)) {
    throw "No such theme package or specified version"
  }
  Write-Output ("Verified: {0} (version {1})" -f $id, $version)
}
# Downloading process
if ($version -eq -1) {
  # Download the all versions
  for ($i = 1; CheckThemeExistence $id $i; $i++) {
    Write-Output ("Downloading: {0} (version {1})" -f $id, $i)
    foreach ($platform in $platforms) {
      $dest = DownloadThemeZip $id $i $platform
      Write-Output ("Saved: {0} ({1})" -f $dest, $platform)
    }
  }
} elseif ($version -eq 0) {
  # Download the latest version
  $latest = 1;
  for ($i = 2; CheckThemeExistence $id $i; $i++) {
    Write-Output ("Skipped: {0} (version {1})" -f $id, $latest)
    $latest = $i
  }
  Write-Output ("Downloading: {0} (version {1})" -f $id, $latest)
  foreach ($platform in $platforms) {
    $dest = DownloadThemeZip $id $latest $platform
    Write-Output ("Saved: {0} ({1})" -f $dest, $platform)
  }
} else {
  # Download the specified version
  Write-Output ("Downloading: {0} (version {1})" -f $id, $version)
  foreach ($platform in $platforms) {
    $dest = DownloadThemeZip $id $version $platform
    Write-Output ("Saved: {0} ({1})" -f $dest, $platform)
  }
}
