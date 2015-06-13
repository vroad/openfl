@echo off
haxe openfl-shared.hxml
if %ERRORLEVEL% neq 0 (
	exit /b
)
copy /b openfl-shared.hxml+openfl-shared.hxml.part openfl-export.hxml
haxe openfl-export.hxml