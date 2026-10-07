@echo off
chcp 65001 >nul
color 2
title TERMINAL DE TAREFAS

:: Configuração das Pastas do Kanban
set "folder_kanban=MEU_KANBAN"
set "k1=01_A_FAZER"
set "k2=02_FAZENDO"
set "k3=03_CONCLUIDO"

if not exist "%folder_kanban%" mkdir "%folder_kanban%"
if not exist "%folder_kanban%\%k1%" mkdir "%folder_kanban%\%k1%"
if not exist "%folder_kanban%\%k2%" mkdir "%folder_kanban%\%k2%"
if not exist "%folder_kanban%\%k3%" mkdir "%folder_kanban%\%k3%"

:: Cria o VBS para o alerta visual
echo Set objArgs = WScript.Arguments > "%temp%\alerta_reuniao.vbs"
echo MsgBox objArgs(0), 64, "Lembrete de Reuniao" >> "%temp%\alerta_reuniao.vbs"

:: Cria o script PowerShell que calcula data/hora do aviso (com virada de dia quando a data fica em branco)
echo param([string]$Data, [string]$Hora) > "%temp%\calc_agenda.ps1"
echo $vazio = [string]::IsNullOrWhiteSpace($Data) >> "%temp%\calc_agenda.ps1"
echo if ($vazio) { $dataBase = Get-Date -Format 'dd/MM/yyyy' } else { $dataBase = $Data } >> "%temp%\calc_agenda.ps1"
echo try { >> "%temp%\calc_agenda.ps1"
echo     $evento = [datetime]::ParseExact("$dataBase $Hora", 'dd/MM/yyyy HH:mm', $null) >> "%temp%\calc_agenda.ps1"
echo } catch { >> "%temp%\calc_agenda.ps1"
echo     Write-Output "ERRO|ERRO|ERRO" >> "%temp%\calc_agenda.ps1"
echo     exit 1 >> "%temp%\calc_agenda.ps1"
echo } >> "%temp%\calc_agenda.ps1"
echo $aviso = $evento.AddMinutes(-5) >> "%temp%\calc_agenda.ps1"
echo if ($vazio -and $aviso -le (Get-Date)) { >> "%temp%\calc_agenda.ps1"
echo     $evento = $evento.AddDays(1) >> "%temp%\calc_agenda.ps1"
echo     $aviso = $evento.AddMinutes(-5) >> "%temp%\calc_agenda.ps1"
echo } >> "%temp%\calc_agenda.ps1"
echo Write-Output ($evento.ToString('dd/MM/yyyy') + '^|' + $aviso.ToString('dd/MM/yyyy') + '^|' + $aviso.ToString('HH:mm')) >> "%temp%\calc_agenda.ps1"

:menu
cls
echo.
echo  ╔══════════════════════════════════════════════╗
echo  ║          🖥️ TERMINAL DE TAREFAS              ║
echo  ╠══════════════════════════════════════════════╣
echo  ║                                              ║
echo  ║   🕘 CRIAR LEMBRETES                         ║
echo  ║    [1] Lembrete Único                        ║
echo  ║    [2] Reunião Fixa (Diária)                 ║
echo  ║    [3] Reunião Fixa (Semanal)                ║
echo  ║    [4] Ver / Remover Lembretes               ║
echo  ║                                              ║
echo  ╠══════════════════════════════════════════════╣
echo  ║                                              ║
echo  ║   📋 ORGANIZAÇÃO                             ║
echo  ║    [5] Kanban                                ║
echo  ║                                              ║
echo  ╠══════════════════════════════════════════════╣
echo  ║   📤 SAIR                                    ║
echo  ║    [6] Sair                                  ║
echo  ╚══════════════════════════════════════════════╝
echo.
set /p opcao="Escolha uma opcao (1-6): "

if "%opcao%"=="1" goto unico
if "%opcao%"=="2" goto diaria
if "%opcao%"=="3" goto semanal
if "%opcao%"=="4" goto gerenciar
if "%opcao%"=="5" goto kanban
if "%opcao%"=="6" exit
goto menu

:: --- SEÇÃO KANBAN ---

:kanban
cls
echo ==================================================
echo              QUADRO KANBAN ATUAL
echo ==================================================
echo.
echo [ A FAZER ]
for /f "delims=" %%a in ('dir /b "%folder_kanban%\%k1%\*.txt" 2^>nul') do echo %%~na
echo --------------------------------------------------
echo [ FAZENDO ]
for /f "delims=" %%a in ('dir /b "%folder_kanban%\%k2%\*.txt" 2^>nul') do echo %%~na
echo --------------------------------------------------
echo [ CONCLUÍDO ]
for /f "delims=" %%a in ('dir /b "%folder_kanban%\%k3%\*.txt" 2^>nul') do echo %%~na
echo ==================================================
echo.
echo Opções:
echo 1. Nova Tarefa  
echo 2. Mover p/ Fazendo
echo 3. Mover p/ Concluir
echo 4. Excluir Tarefa
echo 0. Voltar
echo.
set /p okb="Escolha: "

if "%okb%"=="0" goto menu
if "%okb%"=="1" goto k_nova
if "%okb%"=="2" goto k_fazendo
if "%okb%"=="3" goto k_concluir
if "%okb%"=="4" goto k_deletar
goto kanban

:k_nova
set /p nt="Nome da tarefa: "
echo Criada em %date% %time% > "%folder_kanban%\%k1%\%nt%.txt"
goto kanban

:k_fazendo
set /p mt="Nome da tarefa para mover p/ Fazendo: "
if exist "%folder_kanban%\%k1%\%mt%.txt" (
    move "%folder_kanban%\%k1%\%mt%.txt" "%folder_kanban%\%k2%\" >nul
) else (
    echo Tarefa nao encontrada no 'A Fazer'.
    pause
)
goto kanban

:k_concluir
set /p mt="Nome da tarefa para concluir: "
if exist "%folder_kanban%\%k2%\%mt%.txt" (
    move "%folder_kanban%\%k2%\%mt%.txt" "%folder_kanban%\%k3%\" >nul
) else if exist "%folder_kanban%\%k1%\%mt%.txt" (
    move "%folder_kanban%\%k1%\%mt%.txt" "%folder_kanban%\%k3%\" >nul
) else (
    echo Tarefa nao encontrada.
    pause
)
goto kanban

:k_deletar
set /p dt="Nome da tarefa para deletar (definitivo): "
del /q "%folder_kanban%\%k1%\%dt%.txt" 2>nul
del /q "%folder_kanban%\%k2%\%dt%.txt" 2>nul
del /q "%folder_kanban%\%k3%\%dt%.txt" 2>nul
goto kanban

:: --- SEÇÕES DE LEMBRETES (COM %RANDOM%) ---

:unico
echo.
set "desc="
set /p desc="O que vai ser? (0 para CANCELAR): "
if "%desc%"=="0" goto menu
set "data="
set /p data="Data (DD/MM/AAAA) (Vazio=Hoje, 0=Cancelar): "
if "%data%"=="0" goto menu
set "hora_orig="
set /p hora_orig="Horário Real (HH:MM) (0=Cancelar): "
if "%hora_orig%"=="0" goto menu

set "data_evento="
set "data_aviso="
set "hora_nova="
for /f "usebackq tokens=1-3 delims=|" %%a in (`powershell -NoProfile -ExecutionPolicy Bypass -File "%temp%\calc_agenda.ps1" -Data "%data%" -Hora "%hora_orig%"`) do (
    set "data_evento=%%a"
    set "data_aviso=%%b"
    set "hora_nova=%%c"
)
if "%data_evento%"=="ERRO" (
    echo Data/Horario invalido. Use DD/MM/AAAA e HH:MM.
    pause
    goto menu
)

set nome_tarefa=Unico_%desc: =_%_%RANDOM%

schtasks /create /tn "%nome_tarefa%" /tr "wscript.exe \"%temp%\alerta_reuniao.vbs\" \"EM 5 MINUTOS: %desc% (%hora_orig%)\"" /sc ONCE /sd %data_aviso% /st %hora_nova% /f
echo [OK] Agendado para %data_aviso% as %hora_nova% (evento em %data_evento% %hora_orig%).
pause
goto menu

:diaria
echo.
set "desc="
set /p desc="O que vai ser? (0 para CANCELAR): "
if "%desc%"=="0" goto menu
set "hora_orig="
set /p hora_orig="Horário Real (HH:MM): "
call :subtrair_tempo %hora_orig%
set nome_tarefa=Diaria_%desc: =_%_%RANDOM%
schtasks /create /tn "%nome_tarefa%" /tr "wscript.exe \"%temp%\alerta_reuniao.vbs\" \"EM 5 MINUTOS: %desc% (%hora_orig%)\"" /sc DAILY /st %hora_nova% /f
echo [OK] Agendado para as %hora_nova%.
pause
goto menu

:semanal
echo.
set "desc="
set /p desc="O que vai ser? (0 para CANCELAR): "
if "%desc%"=="0" goto menu
echo Dias: MON, TUE, WED, THU, FRI, SAT, SUN
set "dia_sem="
set /p dia_sem="Dia (Sigla): "
set "hora_orig="
set /p hora_orig="Horário Real (HH:MM): "
call :subtrair_tempo %hora_orig%
set nome_tarefa=Semanal_%desc: =_%_%RANDOM%
schtasks /create /tn "%nome_tarefa%" /tr "wscript.exe \"%temp%\alerta_reuniao.vbs\" \"EM 5 MINUTOS: %desc% (%hora_orig%)\"" /sc WEEKLY /d %dia_sem% /st %hora_nova% /f
echo [OK] Agendado para as %hora_nova%.
pause
goto menu

:gerenciar
cls
echo ==================================================
echo          LISTA DE TAREFAS POR CATEGORIA
echo ==================================================
echo [ LEMBRETES ÚNICOS ]
schtasks /query /fo table | findstr /i "Unico_"
echo.
echo [ REUNIÕES DIÁRIAS ]
schtasks /query /fo table | findstr /i "Diaria_"
echo.
echo [ REUNIÕES SEMANAIS ]
schtasks /query /fo table | findstr /i "Semanal_"
echo ==================================================
echo.
echo Opções:
echo 1. Remover tarefa específica  
echo 2. Limpar Únicos  
echo 0. Voltar
echo.
set /p opt_g="Escolha: "
if "%opt_g%"=="0" goto menu
if "%opt_g%"=="1" goto remover_um
if "%opt_g%"=="2" goto limpar_unicos
goto gerenciar

:remover_um
set /p nome_del="Digite o nome exato da tarefa para remover: "
schtasks /delete /tn "%nome_del%" /f
pause
goto gerenciar

:limpar_unicos
for /f "tokens=1 delims= " %%a in ('schtasks /query /fo table ^| findstr /i "Unico_"') do (
    schtasks /delete /tn "%%a" /f
)
pause
goto gerenciar

:: --- FUNÇÃO PARA SUBTRAIR 5 MINUTOS ---
:subtrair_tempo
set "hora_full=%1"
set "h=%hora_full:~0,2%"
set "m=%hora_full:~3,2%"
if "%h:~0,1%"=="0" set "h=%h:~1%"
if "%m:~0,1%"=="0" set "m=%m:~1%"
set /a total_min=(h*60)+m-5
if %total_min% lss 0 set /a total_min=1440+total_min
set /a h_nova=total_min/60
set /a m_nova=total_min%%60
if %h_nova% lss 10 (set "h_final=0%h_nova%") else (set "h_final=%h_nova%")
if %m_nova% lss 10 (set "m_final=0%m_nova%") else (set "m_final=%m_nova%")
set "hora_nova=%h_final%:%m_final%"
goto :eof