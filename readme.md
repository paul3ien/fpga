# fpga-test

Petits projets de test FPGA écrits en **Verilog**, avec vérification par
simulation et visualisation des signaux dans **Surfer**.

Chaque projet est un module Verilog accompagné d'un testbench (`*_tb.v`).

## Prérequis

| Outil      | Rôle                                |
| ---------- | ----------------------------------- |
| `iverilog` | Compilation des sources Verilog     |
| `vvp`      | Exécution de la simulation          |
| `surfer`   | Visualisation des chronogrammes VCD |

Installation (macOS) :

```sh
brew install icarus-verilog surfer
```

Surfer est aussi disponible sur https://surfer-project.org.

## Compiler et simuler

On se place dans le dossier du projet (ex. `counter`) :

```sh
cd counter

# 1. Compilation : sources + testbench -> counter.vvp
iverilog -o counter.vvp counter.v counter_tb.v

# 2. Simulation : génère le fichier d'ondes counter.vcd
vvp counter.vvp

# 3. Visualisation des signaux avec Surfer
surfer counter.vcd
```

`iverilog` compile le module et son testbench en un exécutable de simulation
(`.vvp`), que `vvp` exécute. Le testbench écrit les signaux dans un fichier
`.vcd` à l'aide de `$dumpfile` / `$dumpvars`, et Surfer affiche ce fichier.

### Raccourci

Le script `run.sh` enchaîne les trois étapes pour un projet donné :

```sh
./run.sh counter
```

Il compile tous les `.v` du dossier, lance la simulation et ouvre le `.vcd`
dans Surfer.

## Ajouter un projet

1. Créer un dossier, par exemple `mon_module/`.
2. Y placer le module (`mon_module.v`) et son testbench (`mon_module_tb.v`).
3. Dans le testbench, nommer le fichier d'ondes : `$dumpfile("mon_module.vcd");`
4. Compiler et simuler avec les commandes ci-dessus.

## Projets

**Réalisé :**

- `counter/` — compteur 4 bits avec reset synchrone.

**À venir** (dossiers prêts à l'emploi) :

- *Bases* : `blinking_light`, `chaser_light`, `button`
- *Affichage* : `screen_7seg`, `VGA`
- *Logique & mémoire* : `ALU`, `RAM`, `FIFO`, `FSM`, `CPU_8bit`, `RISC_V`, `SoC`
- *Communication* : `UART_RX`, `UART_TX`, `terminal_UART`, `SPI`
