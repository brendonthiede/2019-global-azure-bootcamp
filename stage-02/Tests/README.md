# Tests

## Installing ChromeDriver

Install ChromeDriver from [http://chromedriver.storage.googleapis.com/index.html](http://chromedriver.storage.googleapis.com/index.html) by downloading the latest zip file for your operating system and then putting the executable from the zip into your path.

Example for Windows:

```powershell
Invoke-WebRequest "http://chromedriver.storage.googleapis.com/74.0.3729.6/chromedriver_win32.zip" -OutFile chromedriver_win32.zip
Expand-Archive -Path .\chromedriver_win32.zip -DestinationPath $env:USERPROFILE\bin
$systemPath = [System.Environment]::GetEnvironmentVariable('PATH', 'User') + ";$env:USERPROFILE\bin" -replace ';;',';'
[System.Environment]::SetEnvironmentVariable('PATH', $systemPath, 'User')
$env:PATH += ";$env:USERPROFILE\bin"
```

## Running Unit Tests

```powershell
.\node_modules\.bin\gulp unittest
```

## Running Functional Tests

```powershell
.\node_modules\.bin\gulp functionaltest --webAppUrl "https://yoursitename.azurewebsites.net/"
```
