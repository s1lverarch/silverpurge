# Silverpurge / Cleaner For Arch Linux

> SilverArch system cleanup: orphans, package cache, journal, trash, and thumbnails, with dry-run first.

![version](https://img.shields.io/badge/version-0.1.0-00BFFF?style=flat-square)
![language](https://img.shields.io/badge/Nim-2.x-FFE953?style=flat-square&logo=nim&logoColor=black)
![platform](https://img.shields.io/badge/Arch%20Linux-SilverArch-1793D1?style=flat-square&logo=archlinux&logoColor=white)
![license](https://img.shields.io/badge/license-GPL--v3.0-00FF7F?style=flat-square)
![status](https://img.shields.io/badge/status-alpha-FFD700?style=flat-square)

---

<div align="center">

<table>
<tr>
<td align="center" width="33%">
<img src="demo/scan.gif" width="260" alt="silverpurge scan"><br>
<b>Dry-Run Scan</b><br>
<sub>see what would be cleaned, nothing deleted</sub><br><br>
<a href="https://s1lverarch.github.io/linuxdistro/"><img src="https://img.shields.io/badge/Website-00BFFF?style=flat-square&logo=googlechrome&logoColor=white"></a>
<a href="https://github.com/s1lverarch/silverpurge"><img src="https://img.shields.io/badge/GitHub-C0C0C0?style=flat-square&logo=github&logoColor=black"></a>
</td>
<td align="center" width="33%">
<img src="demo/clean.gif" width="260" alt="silverpurge clean"><br>
<b>Guided Clean</b><br>
<sub>asks backup or delete for every file category</sub><br><br>
<a href="https://s1lverarch.github.io/linuxdistro/"><img src="https://img.shields.io/badge/Website-00BFFF?style=flat-square&logo=googlechrome&logoColor=white"></a>
<a href="https://github.com/s1lverarch/silverpurge"><img src="https://img.shields.io/badge/GitHub-C0C0C0?style=flat-square&logo=github&logoColor=black"></a>
</td>
<td align="center" width="33%">
<img src="demo/backup.gif" width="260" alt="silverpurge backup"><br>
<b>Safe Backup</b><br>
<sub>moved files go to a timestamped backup folder</sub><br><br>
<a href="https://s1lverarch.github.io/linuxdistro/"><img src="https://img.shields.io/badge/Website-00BFFF?style=flat-square&logo=googlechrome&logoColor=white"></a>
<a href="https://github.com/s1lverarch/silverpurge"><img src="https://img.shields.io/badge/GitHub-C0C0C0?style=flat-square&logo=github&logoColor=black"></a>
</td>
</tr>
</table>

<sub>Open Source Projects Hosted at SilverArch · Silvercore (s1lverarch) · <a href="https://github.com/s1lverarch">GitHub</a></sub>

</div>

<img width="1000" height="560" alt="scan" src="https://github.com/user-attachments/assets/8c07a4d4-6026-4f84-8f83-71c714a69f76" />

---

## ✨ Features

- 🔍 **Dry-run by default**: `silverpurge` only scans, nothing is removed
- 🧹 **Five categories**: orphans, package cache, journal, trash, thumbnails
- 💾 **Backup or delete**: for file categories you choose every time
- 📦 **Safe package cleanup**: `pacman -Rns` for orphans, `paccache` keeps 2 versions
- 📝 **Logged actions**: every cleanup is written to `/var/log/silverpurge.log`
- 🎨 **Styled output**: truecolor SilverArch palette

---

## 📂 Categories

| Category | What it cleans | Tool | Needs root |
|----------|----------------|------|------------|
| `orphans` | packages no longer required | `pacman -Rns` | yes |
| `cache` | old package versions (keeps 2) | `paccache -rk2` | yes |
| `logs` | journal older than 2 weeks | `journalctl --vacuum-time` | yes |
| `trash` | `~/.local/share/Trash/files` | built-in | no |
| `thumbnails` | `~/.cache/thumbnails` | built-in | no |

---

## 📥 Installation

### Dependencies

```bash
sudo pacman -S nim pacman-contrib
```

### Build and install

```bash
git clone https://github.com/s1lverarch/silverpurge.git
cd silverpurge
nim c -d:release -o:silverpurge src/silverpurge.nim
sudo install -Dm755 silverpurge /usr/local/bin/silverpurge
```

---

## 🚀 Usage

```bash
silverpurge                        # scan all categories (dry-run)
silverpurge scan trash cache       # scan selected categories
sudo silverpurge clean all         # clean all, with confirmations
sudo silverpurge clean trash       # clean one category
silverpurge --version
silverpurge --help
```

When cleaning file categories (`trash`, `thumbnails`), you pick:

```
» backup or delete? [b/d]
```

- `b`: moves items to `~/.local/share/silverpurge/backup/<timestamp>/`
- `d`: deletes them permanently

Every confirmation is asked before anything changes.

---

## 🛡️ Safety

- Scan is the default, so a bare `silverpurge` never deletes anything.
- Every destructive step asks for `y` first.
- Package and journal cleanup need root, and the tool refuses to run them without it.
- File categories can be moved to backup instead of deleted.
- Actions are logged to `/var/log/silverpurge.log`.
- The Developer Is Not Responsible With Any Break In Your System " The Tool Ask You About The destructives steps for `y` first
---

## 🗺️ Roadmap

- [ ] Config file for default categories and journal age
- [ ] Size threshold filter (`--min-size 100M`)
- [ ] Restore command for backed-up items
- [ ] Automatic backup retention (delete backups older than N days)

---

## 👤 Author

**Silvercore (s1lverarch)**
- Email: s1lv3rcore@proton.me
- Website: https://s1lverarch.github.io/linuxdistro/
- GitHub: https://github.com/s1lverarch

## 📄 License

GPL-v3.0. See `LICENSE`.

## 🔗 Related

- [silvergrab](https://github.com/s1lverarch/silvergrab): package manager (pacman wrapper)
- [silverflux](https://github.com/s1lverarch/silverflux): sync + mirrors + AUR
- [SilverSaphire](https://github.com/s1lverarch/SilverSaphire): installer

---

**SilverArch Linux Project**: Made With Love In Tunisia
Available In Silvernebula Reposotory
