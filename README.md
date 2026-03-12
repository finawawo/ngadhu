# NGADHU — Portal Satu Data Kabupaten Ngada

<div align="center">

**Ngada Gerbang Akses Data Handal dan Utama**

Portal data terpadu Pemerintah Kabupaten Ngada, Nusa Tenggara Timur

</div>

---

## 📋 Tentang NGADHU

**NGADHU** (*Ngada Gerbang Akses Data Handal dan Utama*) adalah platform portal data terpadu resmi Pemerintah Kabupaten Ngada yang dirancang untuk:

- 🔓 **Transparansi Data** — Membuka akses publik terhadap data pemerintahan daerah
- 📊 **Visualisasi Interaktif** — Dashboard analitik dengan grafik dan peta SPM kecamatan
- 👥 **Multiuser System** — Pengelolaan data berjenjang dengan Role-Based Access Control
- 🗄️ **Satu Data** — Integrasi dataset dari 28+ Organisasi Perangkat Daerah (OPD)
- 🔍 **Mudah Dicari** — Pencarian dan filter dataset berdasarkan sektor, organisasi, periode

---

## 🗂️ Struktur Proyek

```
ngadhu/
├── index.html              # Halaman utama portal publik
├── dataset-list.html       # Browser dataset dengan filter & pencarian
├── dataset-detail.html     # Detail dataset + preview + unduhan
├── analitik.html           # Dashboard visualisasi data Ngada
├── profil.html             # Profil Kabupaten Ngada
├── berita.html             # Berita & publikasi
├── login.html              # Halaman autentikasi
├── dashboard.html          # Dashboard admin multiuser
├── admin-dataset.html      # Form upload & kelola dataset
├── database_schema.sql     # Skema database PostgreSQL lengkap
└── README.md               # Dokumentasi ini
```

---

## 🚀 Fitur Utama

### 🌐 Portal Publik
| Fitur | Deskripsi |
|---|---|
| **Beranda** | Hero section, statistik, dataset terbaru, berita |
| **Dataset Browser** | Filter multi-dimensi: sektor, OPD, tipe, format, tahun |
| **Dataset Detail** | Preview tabel, visualisasi Chart.js, metadata kolom, API endpoint |
| **Analitik** | Dashboard 6 topik: IPM, Kesehatan, Pendidikan, Ekonomi, Infrastruktur, Pertanian |
| **Peta SPM** | Capaian Standar Pelayanan Minimal per kecamatan |
| **Profil Daerah** | Info 11 kecamatan, potensi daerah, identitas kabupaten |
| **Berita** | Listing artikel dengan kategorisasi sektor |

### 🔐 Dashboard Multiuser
| Fitur | Deskripsi |
|---|---|
| **Role System** | Super Admin → Admin OPD → Operator OPD → Publik |
| **Dataset Management** | Upload, review/approve, edit, publikasi dataset |
| **User Management** | CRUD pengguna, suspend, aktivasi, role assignment |
| **Analytics** | Tren dataset, distribusi sektor, top OPD contributor |
| **Activity Log** | Audit trail semua aktivitas sistem |

---

## 🗄️ Database (PostgreSQL)

14 tabel utama: `organisasi`, `urusan`, `pengguna`, `dataset`, `dataset_file`, `statistik_utama`, `spm_capaian`, `berita`, `produk_hukum`, `log_aktivitas`, `statistik_pengunjung`, `metadata_field`, `notifikasi`, `portal_mitra`

```bash
psql -U postgres -c "CREATE DATABASE ngadhu_db;"
psql -U postgres -d ngadhu_db -f database_schema.sql
```

---

## ⚙️ Tech Stack

```
Frontend:  HTML5 · CSS3 · Vanilla JS · Chart.js 4.4
Planned:   Next.js 14 · TypeScript · Prisma · PostgreSQL · NextAuth.js
DevOps:    GitHub · GitHub Pages / Vercel
```

---

## 🔑 Peran Pengguna

| Peran | Akses |
|---|---|
| **Super Admin** | Full akses — kelola semua pengguna, dataset, konten |
| **Admin OPD** | Kelola dataset OPD sendiri, approve operator |
| **Operator OPD** | Upload & edit draft dataset OPD sendiri |
| **Publik** | Lihat & unduh dataset yang dipublikasikan |

---

## 🏗️ Roadmap

- [x] Phase 1: Static Frontend (Portal + Dashboard + DB Schema)
- [ ] Phase 2: Next.js Backend API + Prisma ORM + Auth
- [ ] Phase 3: Peta interaktif Leaflet.js + Full-text search
- [ ] Phase 4: Integrasi API BPS + Satu Data Indonesia

---

## 📞 Kontak

**Pemerintah Kabupaten Ngada** | Jl. Soekarno-Hatta, Bajawa, NTT 86415  
📧 data@ngadakab.go.id | 🌐 ngadakab.go.id

---

**© 2025 NGADHU — Pemerintah Kabupaten Ngada, NTT**  
*Dibangun untuk transparansi dan pembangunan berbasis data*
