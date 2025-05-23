# 📁 FileNameToFolder

Organize your audiobook files by grouping matching `.pdf` and audio files (`.mp3` or `.m4b`) into clean, structured folders.

---

## ✅ What It Does

For each matching **base filename** (case-insensitive), the tool:

- 📂 Creates a folder named after the base filename  
- 📥 Moves the `.pdf` and `.mp3` or `.m4b` files into that folder  
- 🚫 Skips any unmatched (solo) `.pdf`, `.mp3`, or `.m4b` files  
- 📝 Logs all actions to `FileNameToFolder.log`

---

## 📂 Example Input

```
P:\Library\Audiobooks\
├── Book One.pdf
├── Book One.mp3
├── Book Two.pdf
├── Book Two.m4b
├── SoloFile.mp3
└── OrphanNote.pdf
```

---

## 📦 Example Output

```
P:\Library\Audiobooks\
├── Book One\
│   ├── Book One.pdf
│   └── Book One.mp3
├── Book Two\
│   ├── Book Two.pdf
│   └── Book Two.m4b
├── SoloFile.mp3         ← skipped
└── OrphanNote.pdf       ← skipped
```

---

## 🛠 Requirements

- Windows 10/11  
- PowerShell (built-in) 
   
- Files stored in a **flat folder** (not inside subfolders)  
- Both `.ps1` and `.bat` files in the same folder

---

## ⚙️ How to Use

1. Place `FileNameToFolder.ps1` and `FileNameToFolder.bat` in the same folder.
2. Open `FileNameToFolder.bat` in a text editor and update this line to point to your files:

   ```
   set "targetFolder=P:\Library\Audiobooks"
   ```

3. Double-click the `.bat` file to run the script.

---

## 📄 FileNameToFolder.bat

```
@echo off
setlocal

set "targetFolder=P:\Library\Audiobooks"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0FileNameToFolder.ps1" "%targetFolder%"

pause
```

---

## 💡 Script Behavior

- Folders are only created for files that share a base name and include both:
  - a `.pdf` and  
  - either a `.mp3` or `.m4b`
- Automatically truncates overly long folder or file names to prevent path errors
- Skips any file that does not have a valid pairing
- Generates a log file at `FileNameToFolder.log` with move and warning info

---

## 📜 Sample Log Output

```
Processing folder: P:\Library\Audiobooks

Creating folder: P:\Library\Audiobooks\Book One
Moved: Book One.pdf => P:\Library\Audiobooks\Book One
Moved: Book One.mp3 => P:\Library\Audiobooks\Book One

Creating folder: P:\Library\Audiobooks\Book Two
Moved: Book Two.pdf => P:\Library\Audiobooks\Book Two
Moved: Book Two.m4b => P:\Library\Audiobooks\Book Two

✅ Finished at 2025-05-21 17:45:12
```

---

## ❓ Troubleshooting

**param not recognized**  
You're trying to run the `.ps1` script directly. Always use the `.bat` file to launch the script.

**Nothing is moved**  
Make sure each `.pdf` has a matching `.mp3` or `.m4b` file with the same base name.

---

## 🏁 License

This project is licensed under the [MIT License](LICENSE).