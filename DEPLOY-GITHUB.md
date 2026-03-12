# 🚀 Panduan Deploy NGADHU ke GitHub Pages
### Portal akan LIVE dan bisa diakses online oleh siapa saja — GRATIS

---

## ⏱️ Estimasi waktu: 5 menit

---

## LANGKAH 1 — Buat akun GitHub (jika belum punya)

1. Buka **https://github.com**
2. Klik **Sign up**
3. Isi username, email, password
4. Verifikasi email
5. ✅ Selesai — akun sudah aktif

> **Rekomendasi username:** `ngada-opendata` atau `pemkab-ngada`

---

## LANGKAH 2 — Buat Repository Baru

1. Login ke GitHub
2. Klik tombol **"New"** (hijau) di pojok kiri atas
3. Isi form:
   - **Repository name:** `ngadhu-portal`
   - **Description:** `Portal Satu Data Kabupaten Ngada — NGADHU`
   - Pilih **Public** ✅
   - **JANGAN** centang "Add README" (sudah ada)
4. Klik **"Create repository"**

---

## LANGKAH 3 — Upload File (tanpa coding!)

### Cara A: Upload via Browser (paling mudah)
1. Di halaman repository yang baru dibuat, klik **"uploading an existing file"**
2. Extract file `ngadhu-portal.zip` yang sudah didownload
3. **Drag & drop** semua file dari folder `ngadhu/` ke browser
4. Di bawah, isi commit message: `🚀 Launch NGADHU Portal v1.0`
5. Klik **"Commit changes"**

### Cara B: Pakai Git di terminal
```bash
# Buka terminal/command prompt, masuk ke folder ngadhu/
cd ngadhu

# Inisialisasi dan push
git init
git add .
git commit -m "🚀 Launch NGADHU Portal v1.0"
git branch -M main
git remote add origin https://github.com/USERNAME_ANDA/ngadhu-portal.git
git push -u origin main
```
> Ganti `USERNAME_ANDA` dengan username GitHub Anda

---

## LANGKAH 4 — Aktifkan GitHub Pages

1. Di repository, klik **Settings** (tab paling kanan)
2. Di menu kiri, klik **Pages**
3. Di bagian **"Source"**, pilih:
   - Branch: **main**
   - Folder: **/ (root)**
4. Klik **Save**
5. Tunggu 1–2 menit

---

## ✅ SELESAI — Portal Anda LIVE!

URL portal Anda akan menjadi:
```
https://USERNAME_ANDA.github.io/ngadhu-portal/
```

Contoh jika username `ngada-opendata`:
```
https://ngada-opendata.github.io/ngadhu-portal/
```

### Link halaman lengkap:
| Halaman | URL |
|---|---|
| 🏠 Beranda | `/ngadhu-portal/index.html` |
| 🗄️ Dataset | `/ngadhu-portal/dataset-list.html` |
| 📊 Analitik | `/ngadhu-portal/analitik.html` |
| 👤 Profil | `/ngadhu-portal/profil.html` |
| 📰 Berita | `/ngadhu-portal/berita.html` |
| 🔐 Login | `/ngadhu-portal/login.html` |
| 📋 Dashboard | `/ngadhu-portal/dashboard.html` |

---

## 🔑 Akun Demo untuk Testing

| Peran | Email | Password |
|---|---|---|
| Super Admin | `admin@ngadhu.id` | `Admin@2025` |
| Operator | `operator@dinkes.ngada.id` | `Op3rator#25` |
| Publik | (tanpa login) | — |

> ⚠️ Catatan: Login page bersifat simulasi (belum terhubung backend). Akun di atas adalah placeholder untuk tampilan dashboard.

---

## 🌐 Custom Domain (Opsional)

Jika ingin menggunakan domain `data.ngadakab.go.id`:
1. Settings → Pages → Custom domain
2. Isi `data.ngadakab.go.id`
3. Hubungi pengelola domain IT Pemkab Ngada untuk setting DNS:
   ```
   CNAME data USERNAME_ANDA.github.io
   ```

---

## ❓ Butuh bantuan?

Hubungi tim pengembang atau kirim pertanyaan melalui GitHub Issues.
