# 🖥️ TaskBat — Terminal de Tarefas

Um script `.bat` para Windows que junta, num único menu de terminal, **lembretes de reunião** (via Agendador de Tarefas do Windows) e um **quadro Kanban** simples baseado em pastas.

Sem instalação, sem dependências externas: só o `cmd`, o PowerShell e o `wscript` que já vêm no Windows.

```
 ╔══════════════════════════════════════════════╗
 ║          🖥️ TERMINAL DE TAREFAS              ║
 ╠══════════════════════════════════════════════╣
 ║   🕘 CRIAR LEMBRETES                         ║
 ║    [1] Lembrete Único                        ║
 ║    [2] Reunião Fixa (Diária)                 ║
 ║    [3] Reunião Fixa (Semanal)                ║
 ║    [4] Ver / Remover Lembretes               ║
 ╠══════════════════════════════════════════════╣
 ║   📋 ORGANIZAÇÃO                             ║
 ║    [5] Kanban                                ║
 ╠══════════════════════════════════════════════╣
 ║   📤 SAIR                                    ║
 ║    [6] Sair                                  ║
 ╚══════════════════════════════════════════════╝
```

---

## ✨ Funções

### 🕘 Lembretes

Todos os lembretes aparecem como uma **janela pop-up 5 minutos antes** do horário informado, com a mensagem:

> EM 5 MINUTOS: *descrição* (*horário*)

| Opção | O que faz |
|---|---|
| **[1] Lembrete Único** | Agenda um aviso para uma data e hora específicas. Se a data ficar em branco, usa **hoje** — e, se o horário de hoje já passou, joga automaticamente para **amanhã**. |
| **[2] Reunião Fixa (Diária)** | Cria um aviso que se repete todos os dias no mesmo horário. |
| **[3] Reunião Fixa (Semanal)** | Cria um aviso que se repete toda semana no dia escolhido (`MON`, `TUE`, `WED`, `THU`, `FRI`, `SAT`, `SUN`). |
| **[4] Ver / Remover Lembretes** | Lista os lembretes criados, separados por categoria, e permite remover um específico ou apagar todos os lembretes únicos de uma vez. |

Os lembretes são criados no **Agendador de Tarefas do Windows** (`schtasks`) com nomes no formato:

```
Unico_<descricao>_<numero>
Diaria_<descricao>_<numero>
Semanal_<descricao>_<numero>
```

Ou seja, continuam funcionando mesmo com o TaskBat fechado.

### 📋 Kanban

Um quadro Kanban de três colunas, onde cada tarefa é um arquivo `.txt` dentro de uma pasta:

```
MEU_KANBAN/
├── 01_A_FAZER/
├── 02_FAZENDO/
└── 03_CONCLUIDO/
```

| Opção | O que faz |
|---|---|
| **1. Nova Tarefa** | Cria a tarefa em **A Fazer** (o arquivo guarda a data/hora de criação). |
| **2. Mover p/ Fazendo** | Move de **A Fazer** para **Fazendo**. |
| **3. Mover p/ Concluir** | Move de **Fazendo** (ou direto de **A Fazer**) para **Concluído**. |
| **4. Excluir Tarefa** | Apaga a tarefa definitivamente, em qualquer coluna. |

As pastas são criadas automaticamente na primeira execução, ao lado do `.bat`. Como são arquivos comuns, você também pode mexer nelas direto pelo Explorer.

---

## 🚀 Como usar

1. Baixe o repositório (ou só o `TaskBat.bat`):
   ```bash
   git clone https://github.com/LucasGulich/TaskBat.git
   ```
2. Dê **dois cliques** em `TaskBat.bat`.
3. Escolha uma opção digitando o número e apertando **Enter**.

### Exemplos

**Lembrete único para hoje às 14:30**
```
Escolha uma opcao (1-6): 1
O que vai ser? (0 para CANCELAR): Call com cliente
Data (DD/MM/AAAA) (Vazio=Hoje, 0=Cancelar):
Horário Real (HH:MM) (0=Cancelar): 14:30
[OK] Agendado para 07/10/2026 as 14:25 (evento em 07/10/2026 14:30).
```

**Daily toda manhã às 09:00**
```
Escolha uma opcao (1-6): 2
O que vai ser? (0 para CANCELAR): Daily
Horário Real (HH:MM): 09:00
[OK] Agendado para as 08:55.
```

**Reunião semanal toda segunda às 10:00**
```
Escolha uma opcao (1-6): 3
O que vai ser? (0 para CANCELAR): Planejamento
Dias: MON, TUE, WED, THU, FRI, SAT, SUN
Dia (Sigla): MON
Horário Real (HH:MM): 10:00
[OK] Agendado para as 09:55.
```

### Removendo um lembrete

Em **[4] Ver / Remover Lembretes**, copie o nome exato da tarefa mostrado na lista (ex.: `Diaria_Daily_12345`) e cole na opção **1. Remover tarefa específica**.

Também é possível ver/remover pelo próprio **Agendador de Tarefas** do Windows (`taskschd.msc`).

---

## 📌 Requisitos e observações

- **Windows** 10 ou 11.
- Formatos de entrada: data em `DD/MM/AAAA` e hora em `HH:MM` (24h).
- O agendamento usa o formato de data do sistema; foi pensado para Windows configurado em **português (Brasil)**.
- Ao rodar, o script cria dois arquivos auxiliares em `%TEMP%` (`alerta_reuniao.vbs` e `calc_agenda.ps1`). Se a pasta temporária for limpa, os lembretes já agendados param de exibir o pop-up até o TaskBat ser aberto de novo (ele recria os arquivos).
- Evite caracteres especiais (`& | < > ^ % "`) nos nomes de tarefas e lembretes.
- Para o Kanban, digite o nome da tarefa **exatamente** como aparece no quadro.
