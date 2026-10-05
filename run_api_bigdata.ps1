$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $projectRoot

$env:PYTHONUTF8 = "1"
python -c "from bigdata_platform import configure_bigdata_env; print(configure_bigdata_env())"
python flask_api.py
