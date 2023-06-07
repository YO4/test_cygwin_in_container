@echo off
set PATH=c:\cygwin64\bin
set PROMPT=+$s
set result=0

echo;
echo === normal directory : prepare

sh -x -c "rm -rf /cygdrive/c/normal_dir && mkdir -p /cygdrive/c/normal_dir"
sh -x -c "touch /cygdrive/c/normal_dir/file_to_unlink"
sh -x -c "touch /cygdrive/c/normal_dir/file_to_rename"
sh -x -c "find /cygdrive/c/normal_dir -type f"

echo;
echo === normal directory : test

sh -x -c "strace -o /cygdrive/c/opt/rm_on_normal_dir.trace rm /cygdrive/c/normal_dir/file_to_unlink"
call :a
sh -x -c "strace -o /cygdrive/c/opt/mv_on_normal_dir.trace mv /cygdrive/c/normal_dir/file_to_rename /cygdrive/c/normal_dir/rename_complete"
call :a
sh -x -c "find /cygdrive/c/normal_dir -type f"

echo;
echo === bind mounted directory : prepare

@echo on
del /q c:\binded_dir\*
@echo off
sh -x -c "touch /cygdrive/c/binded_dir/file_to_unlink"
sh -x -c "touch /cygdrive/c/binded_dir/file_to_rename"
sh -x -c "find /cygdrive/c/binded_dir -type f"

echo;
echo === bind mounted directory : test

sh -x -c "strace -o /cygdrive/c/opt/rm_on_mounted_dir.trace rm /cygdrive/c/binded_dir/file_to_unlink"
call :a
sh -x -c "strace -o /cygdrive/c/opt/mv_on_mounted_dir.trace mv /cygdrive/c/binded_dir/file_to_rename /cygdrive/c/binded_dir/rename_complete"
call :a
sh -x -c "find /cygdrive/c/binded_dir -type f"

echo;
echo === crossing directory mv : prepare

@echo on
del /q c:\binded_dir\*
@echo off
sh -x -c "rm -rf /cygdrive/c/normal_dir && mkdir -p /cygdrive/c/normal_dir"
sh -x -c "touch /cygdrive/c/normal_dir/normal_to_bind"
sh -x -c "touch /cygdrive/c/binded_dir/binded_to_normal"
sh -x -c "(find /cygdrive/c/normal_dir /cygdrive/c/binded_dir -type f)"

echo;
echo === crossing directory mv : test

sh -x -c "strace -o /cygdrive/c/opt/mv_normal_dir_to_mounted_dir.trace mv /cygdrive/c/normal_dir/normal_to_bind /cygdrive/c/binded_dir/to_binded_complete"
call :a
sh -x -c "strace -o /cygdrive/c/opt/mv_mounted_dir_to_normal_dir.trace mv /cygdrive/c/binded_dir/binded_to_normal /cygdrive/c/normal_dir/to_normal_complete"
call :a
sh -x -c "(find /cygdrive/c/normal_dir /cygdrive/c/binded_dir -type f)"

echo;
echo === container environment

sh -x -c "cygcheck -V"
ver

exit /b %result%

rem accumulate errorlevel
:a
if not errorlevel 1 exit /b
echo [41mfailed.[m
set /a result=%result%+%errorlevel%
exit /b

