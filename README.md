
# NovaPay Bank ATM — 8086 Assembly Language Project

**Computer Organization & Assembly Language (COAL) Lab Project**

## 📌 Overview

This project implements a functional **ATM (Automated Teller Machine) simulation** using **8086 Assembly Language** under DOS. It demonstrates low-level programming concepts covered in the Computer Organization and Assembly Language (COAL) course — including DOS interrupt calls, register operations, arrays, loops, and stack-based procedures.

The system, named **NovaPay Bank ATM**, provides core banking operations: PIN-based authentication, balance enquiry, cash withdrawal, and cash deposit — all built from direct **INT 21h** DOS service calls, without any high-level libraries.

## ⚙️ Features

- **PIN Authentication** — 4-digit PIN entry with character masking (`*`) and a 3-attempt lockout for security
- **Main Menu** — Simple text-based menu with 4 options:
  1. Check Balance
  2. Withdraw Cash
  3. Deposit Cash
  4. Exit
- **32-bit Balance Arithmetic** — Supports balances beyond the standard 16-bit limit (up to ~4 billion) using a `hi:lo` word pair
- **Input Validation** — Only numeric digits accepted for amounts
- **Modular Design** — Separate user-defined procedures for each function: `CheckPIN`, `PrintBalance`, `InputNumber32`, `PrintNumber32`

## 🧠 COAL Concepts Demonstrated

| Concept | Where Used |
|---|---|
| Segment Registers & Memory Model | `.model small`, `.data`, `.code` |
| Data Segment Definitions | `DB`/`DW` for strings, 32-bit balance, PIN array |
| Register Usage | `AX`/`DX` for 32-bit arithmetic, `BX` as carry, `CX` as loop counter, `SI` as array pointer |
| DOS INT 21h Services | `AH=09h` print string, `AH=08h` read no-echo, `AH=02h` print char, `AH=4Ch` exit |
| Conditional & Unconditional Jumps | `JE`, `JNE`, `JA`, `JB`, `JNZ`, `JMP` |
| Arrays & LOOP Instruction | `pin_buf` (4-byte array) read via `LOOP` |
| Stack & Procedures | `CALL`/`RET` with `PUSH`/`POP` register preservation |

## 📂 Repository Contents

- `atm.asm` — Full 8086 Assembly source code
- `NovaPay_Bank_ATM_Documentation_Updated.docx` — Complete project documentation

## ▶️ How to Run

1. Assemble and link using an 8086 assembler/emulator such as **MASM/TASM** or **DOSBox** with `emu8086`
2. Run the compiled `.exe` in a DOS environment (e.g., DOSBox)
3. Enter PIN `1234` when prompted to log in

## 👤 Author

**Ifra Abdullah Khan**
Roll No: 242719 · BSCS-EVE-F24-B · 4th Semester · Spring 2026
Air University Islamabad
Instructor: Mr. Danial Haider

---
*Developed as part of the Computer Organization & Assembly Language (COAL) lab course.*
