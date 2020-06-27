<#
    .DESCRIPTION
     Builds the Windows Agent code and Docker Image and pushes the docker image to specified repo

    .PARAMETER image
        docker image. format should be <repo>/<image-name>:<tag>
#>
param(
    [Parameter(mandatory = $true)]
    [string]$image
)

$currentdir =  $PSScriptRoot
Write-Host("current script dir : " + $currentdir + " ")

if ($false -eq (Test-Path -Path $currentdir)) {
    Write-Host("Invalid current dir : " + $currentdir + " ") -ForegroundColor Red
    exit
}

if ([string]::IsNullOrEmpty($image)) {
    Write-Host "Image parameter shouldnt be null or empty" -ForegroundColor Red
    exit
}

$imageparts = $image.split(":")
if (($imageparts.Length -ne 2)){
    Write-Host "Image not in valid format. Expected format should be <repo>/<image>:<imagetag>" -ForegroundColor Red
    exit
}

$imagetag = $imageparts[1]
Write-Host "image tag is :$imagetag"

Write-Host "start:Building the cert generator and out oms code via Makefile.ps1"
..\..\..\build\windows\Makefile.ps1
Write-Host "end:Building the cert generator and out oms code via Makefile.ps1"

$dockerFileDir = Split-Path -Path $currentdir
Write-Host("builddir dir : " + $dockerFileDir + " ")
if ($false -eq (Test-Path -Path $dockerFileDir)) {
    Write-Host("Invalid dockerFile Dir : " + $dockerFileDir + " ") -ForegroundColor Red
    exit
}

Write-Host "changing directory to DockerFile dir: $dockerFileDir"
Set-Location -Path $dockerFileDir

Write-Host "STAT:Triggering docker image build: $image"
docker build -t $image --build-arg IMAGE_TAG=$imageTag  .
Write-Host "END:Triggering docker image build: $image"

Write-Host "STAT:pushing docker image : $image"
docker push  $image
Write-Host "EnD:pushing docker image : $image"