@echo off
rem Inicia o LF Kitnets no Windows, aberto para a rede de casa (porta 3000).
rem Use na pasta Inicializar ou no Agendador de Tarefas (veja o README).
title LF Kitnets
cd /d "%~dp0..\.."

rem Depois de um desligamento sem fechar o servidor, o arquivo de PID fica e impede de subir.
if exist tmp\pids\server.pid del /q tmp\pids\server.pid

rem Depois de um git pull: instala gems novas, atualiza o banco e gera o CSS.
call bundle check >nul 2>&1 || call bundle install || goto erro
call ruby bin\rails db:prepare || goto erro
call ruby bin\rails tailwindcss:build || goto erro

:servidor
ruby bin\rails server -b 0.0.0.0 -p 3000
rem Se o servidor cair, sobe de novo depois de 5 segundos.
timeout /t 5 /nobreak >nul
goto servidor

:erro
echo.
echo Nao foi possivel iniciar o LF Kitnets. Veja a mensagem acima.
pause
