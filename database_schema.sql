-- ============================================================
-- NGADHU — Ngada Gerbang Akses Data Handal dan Utama
-- Skema Database PostgreSQL v1.0
-- Portal Data Kabupaten Ngada, NTT
-- ============================================================

-- Enable extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis"; -- For spatial data
CREATE EXTENSION IF NOT EXISTS "pg_trgm"; -- For full-text search

-- ============================================================
-- ENUM TYPES
-- ============================================================

CREATE TYPE user_role AS ENUM (
  'super_admin',
  'admin_opd',
  'operator_opd',
  'publik'
);

CREATE TYPE dataset_status AS ENUM (
  'draft',
  'pending_review',
  'published',
  'rejected',
  'archived'
);

CREATE TYPE dataset_type AS ENUM (
  'numerik',
  'non_numerik',
  'spasial',
  'dokumen'
);

CREATE TYPE dataset_format AS ENUM (
  'csv', 'xlsx', 'json', 'geojson', 'shapefile', 'pdf', 'xml', 'api'
);

CREATE TYPE content_status AS ENUM (
  'draft', 'published', 'archived'
);

CREATE TYPE hukum_jenis AS ENUM (
  'perda', 'perbup', 'sk_bupati', 'instruksi_bupati', 'surat_edaran', 'lainnya'
);

-- ============================================================
-- 1. ORGANISASI (OPD / SKPD)
-- ============================================================

CREATE TABLE organisasi (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  kode          VARCHAR(20) UNIQUE NOT NULL,
  nama          VARCHAR(255) NOT NULL,
  nama_singkat  VARCHAR(50),
  deskripsi     TEXT,
  logo_url      TEXT,
  kepala        VARCHAR(255),
  email         VARCHAR(100),
  telepon       VARCHAR(30),
  alamat        TEXT,
  website       VARCHAR(255),
  aktif         BOOLEAN DEFAULT true,
  urutan        INT DEFAULT 0,
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  updated_at    TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_organisasi_kode ON organisasi(kode);
CREATE INDEX idx_organisasi_aktif ON organisasi(aktif);

-- ============================================================
-- 2. URUSAN (Sektor/Kategori Pemerintahan)
-- ============================================================

CREATE TABLE urusan (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  kode        VARCHAR(10) UNIQUE NOT NULL,
  nama        VARCHAR(150) NOT NULL,
  deskripsi   TEXT,
  ikon        VARCHAR(10),
  warna       VARCHAR(20),
  parent_id   UUID REFERENCES urusan(id),
  urutan      INT DEFAULT 0,
  aktif       BOOLEAN DEFAULT true,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_urusan_parent ON urusan(parent_id);

-- ============================================================
-- 3. PENGGUNA (Users — Multiuser System)
-- ============================================================

CREATE TABLE pengguna (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email             VARCHAR(255) UNIQUE NOT NULL,
  password_hash     TEXT NOT NULL,
  nama_lengkap      VARCHAR(255) NOT NULL,
  nip               VARCHAR(30),
  peran             user_role NOT NULL DEFAULT 'publik',
  organisasi_id     UUID REFERENCES organisasi(id) ON DELETE SET NULL,
  foto_url          TEXT,
  telepon           VARCHAR(30),
  aktif             BOOLEAN DEFAULT true,
  email_verified    BOOLEAN DEFAULT false,
  last_login_at     TIMESTAMPTZ,
  login_count       INT DEFAULT 0,
  reset_token       TEXT,
  reset_expires_at  TIMESTAMPTZ,
  created_at        TIMESTAMPTZ DEFAULT NOW(),
  updated_at        TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_pengguna_email ON pengguna(email);
CREATE INDEX idx_pengguna_peran ON pengguna(peran);
CREATE INDEX idx_pengguna_organisasi ON pengguna(organisasi_id);
CREATE INDEX idx_pengguna_aktif ON pengguna(aktif);

-- ============================================================
-- 4. DATASET
-- ============================================================

CREATE TABLE dataset (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  slug            VARCHAR(255) UNIQUE NOT NULL,
  judul           VARCHAR(500) NOT NULL,
  deskripsi       TEXT,
  tipe            dataset_type NOT NULL,
  status          dataset_status NOT NULL DEFAULT 'draft',
  organisasi_id   UUID NOT NULL REFERENCES organisasi(id),
  urusan_id       UUID REFERENCES urusan(id),
  upload_by       UUID REFERENCES pengguna(id),
  review_by       UUID REFERENCES pengguna(id),
  reviewed_at     TIMESTAMPTZ,
  catatan_review  TEXT,
  periode_awal    INT,  -- Tahun mulai
  periode_akhir   INT,  -- Tahun akhir
  frekuensi       VARCHAR(50), -- tahunan, bulanan, triwulan, dll
  sumber          VARCHAR(255),
  tahun_rilis     INT,
  lisensi         VARCHAR(100) DEFAULT 'CC BY 4.0',
  tags            TEXT[],
  kecamatan       TEXT[], -- daftar kecamatan yang dicakup
  jumlah_baris    INT,
  jumlah_kolom    INT,
  ukuran_file     BIGINT, -- bytes
  format_tersedia dataset_format[],
  thumbnail_url   TEXT,
  metadata_json   JSONB,  -- custom metadata fields
  jumlah_unduhan  INT DEFAULT 0,
  jumlah_view     INT DEFAULT 0,
  is_unggulan     BOOLEAN DEFAULT false,
  is_spd          BOOLEAN DEFAULT false, -- Standar Pelayanan Dasar
  published_at    TIMESTAMPTZ,
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_dataset_slug ON dataset(slug);
CREATE INDEX idx_dataset_status ON dataset(status);
CREATE INDEX idx_dataset_organisasi ON dataset(organisasi_id);
CREATE INDEX idx_dataset_urusan ON dataset(urusan_id);
CREATE INDEX idx_dataset_tipe ON dataset(tipe);
CREATE INDEX idx_dataset_tags ON dataset USING GIN(tags);
CREATE INDEX idx_dataset_search ON dataset USING GIN(to_tsvector('indonesian', judul || ' ' || COALESCE(deskripsi, '')));

-- ============================================================
-- 5. FILE DATASET (Lampiran/Unduhan)
-- ============================================================

CREATE TABLE dataset_file (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  dataset_id    UUID NOT NULL REFERENCES dataset(id) ON DELETE CASCADE,
  nama_file     VARCHAR(255) NOT NULL,
  format        dataset_format NOT NULL,
  url           TEXT NOT NULL,
  ukuran        BIGINT,
  checksum_md5  VARCHAR(64),
  versi         VARCHAR(20) DEFAULT '1.0',
  keterangan    TEXT,
  aktif         BOOLEAN DEFAULT true,
  jumlah_dl     INT DEFAULT 0,
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_dataset_file_dataset ON dataset_file(dataset_id);

-- ============================================================
-- 6. STATISTIK UTAMA (BPS & OPD Key Indicators)
-- ============================================================

CREATE TABLE statistik_utama (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  kode            VARCHAR(50) UNIQUE NOT NULL,
  nama            VARCHAR(300) NOT NULL,
  nilai           DECIMAL(18,4),
  satuan          VARCHAR(50),
  sumber          VARCHAR(255),
  organisasi_id   UUID REFERENCES organisasi(id),
  urusan_id       UUID REFERENCES urusan(id),
  periode         INT NOT NULL,  -- Tahun
  bulan           INT,  -- Optional: 1-12
  keterangan      TEXT,
  is_utama        BOOLEAN DEFAULT false,
  icon            VARCHAR(10),
  urutan          INT DEFAULT 0,
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_statistik_periode ON statistik_utama(periode);
CREATE INDEX idx_statistik_utama ON statistik_utama(is_utama);

-- ============================================================
-- 7. SPM (Standar Pelayanan Minimal)
-- ============================================================

CREATE TABLE spm_capaian (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  kecamatan       VARCHAR(100) NOT NULL,
  kode_kecamatan  VARCHAR(20),
  urusan          VARCHAR(100) NOT NULL,
  jenis_layanan   VARCHAR(255) NOT NULL,
  indikator       TEXT,
  target          DECIMAL(10,2),
  realisasi       DECIMAL(10,2),
  satuan          VARCHAR(50),
  capaian_persen  DECIMAL(7,2) GENERATED ALWAYS AS (
    CASE WHEN target > 0 THEN ROUND((realisasi / target) * 100, 2) ELSE 0 END
  ) STORED,
  permasalahan    TEXT,
  rekomendasi     TEXT,
  profil_layanan  JSONB,
  link_pendukung  TEXT[],
  periode         INT NOT NULL,
  upload_by       UUID REFERENCES pengguna(id),
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(kecamatan, urusan, jenis_layanan, periode)
);

CREATE INDEX idx_spm_kecamatan ON spm_capaian(kecamatan);
CREATE INDEX idx_spm_urusan ON spm_capaian(urusan);
CREATE INDEX idx_spm_periode ON spm_capaian(periode);

-- ============================================================
-- 8. BERITA / ARTIKEL
-- ============================================================

CREATE TABLE berita (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  slug          VARCHAR(255) UNIQUE NOT NULL,
  judul         VARCHAR(500) NOT NULL,
  ringkasan     TEXT,
  konten        TEXT NOT NULL,
  thumbnail_url TEXT,
  penulis_id    UUID REFERENCES pengguna(id),
  organisasi_id UUID REFERENCES organisasi(id),
  status        content_status DEFAULT 'draft',
  kategori      VARCHAR(100),
  tags          TEXT[],
  views         INT DEFAULT 0,
  featured      BOOLEAN DEFAULT false,
  published_at  TIMESTAMPTZ,
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  updated_at    TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_berita_slug ON berita(slug);
CREATE INDEX idx_berita_status ON berita(status);
CREATE INDEX idx_berita_published ON berita(published_at DESC);

-- ============================================================
-- 9. PRODUK HUKUM
-- ============================================================

CREATE TABLE produk_hukum (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  nomor           VARCHAR(100) NOT NULL,
  jenis           hukum_jenis NOT NULL,
  judul           VARCHAR(500) NOT NULL,
  deskripsi       TEXT,
  tahun           INT NOT NULL,
  tanggal_terbit  DATE,
  file_url        TEXT,
  organisasi_id   UUID REFERENCES organisasi(id),
  status          content_status DEFAULT 'draft',
  tags            TEXT[],
  views           INT DEFAULT 0,
  unduhan         INT DEFAULT 0,
  upload_by       UUID REFERENCES pengguna(id),
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_hukum_tahun ON produk_hukum(tahun);
CREATE INDEX idx_hukum_jenis ON produk_hukum(jenis);

-- ============================================================
-- 10. LOG AKTIVITAS (Audit Trail)
-- ============================================================

CREATE TABLE log_aktivitas (
  id            BIGSERIAL PRIMARY KEY,
  pengguna_id   UUID REFERENCES pengguna(id),
  aksi          VARCHAR(100) NOT NULL,
  tabel         VARCHAR(100),
  record_id     UUID,
  detail        JSONB,
  ip_address    INET,
  user_agent    TEXT,
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_log_pengguna ON log_aktivitas(pengguna_id);
CREATE INDEX idx_log_tabel ON log_aktivitas(tabel);
CREATE INDEX idx_log_created ON log_aktivitas(created_at DESC);

-- Partitioning by month for performance (optional)
-- CREATE TABLE log_aktivitas_2025_01 PARTITION OF log_aktivitas FOR VALUES ...

-- ============================================================
-- 11. STATISTIK PENGUNJUNG
-- ============================================================

CREATE TABLE statistik_pengunjung (
  id          BIGSERIAL PRIMARY KEY,
  tanggal     DATE NOT NULL UNIQUE,
  harian      INT DEFAULT 0,
  bulanan     INT DEFAULT 0,
  total       INT DEFAULT 0,
  updated_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE dataset_view_log (
  id          BIGSERIAL PRIMARY KEY,
  dataset_id  UUID NOT NULL REFERENCES dataset(id) ON DELETE CASCADE,
  ip_address  INET,
  pengguna_id UUID REFERENCES pengguna(id),
  viewed_at   TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_viewlog_dataset ON dataset_view_log(dataset_id);
CREATE INDEX idx_viewlog_date ON dataset_view_log(viewed_at DESC);

-- ============================================================
-- 12. METADATA SKEMA
-- ============================================================

CREATE TABLE metadata_field (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  dataset_id    UUID NOT NULL REFERENCES dataset(id) ON DELETE CASCADE,
  nama_kolom    VARCHAR(255) NOT NULL,
  tipe_data     VARCHAR(50),
  deskripsi     TEXT,
  contoh_nilai  TEXT,
  unit          VARCHAR(50),
  nullable      BOOLEAN DEFAULT true,
  urutan        INT DEFAULT 0
);

-- ============================================================
-- 13. NOTIFIKASI
-- ============================================================

CREATE TABLE notifikasi (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  penerima_id   UUID NOT NULL REFERENCES pengguna(id) ON DELETE CASCADE,
  judul         VARCHAR(255) NOT NULL,
  pesan         TEXT NOT NULL,
  tipe          VARCHAR(50),
  link          TEXT,
  dibaca        BOOLEAN DEFAULT false,
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_notif_penerima ON notifikasi(penerima_id);
CREATE INDEX idx_notif_dibaca ON notifikasi(dibaca);

-- ============================================================
-- 14. PORTAL KEMITRAAN
-- ============================================================

CREATE TABLE portal_mitra (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  nama        VARCHAR(255) NOT NULL,
  logo_url    TEXT,
  url         TEXT,
  deskripsi   TEXT,
  kategori    VARCHAR(50),
  aktif       BOOLEAN DEFAULT true,
  urutan      INT DEFAULT 0,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- FUNCTIONS & TRIGGERS
-- ============================================================

-- Auto update updated_at
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply trigger to tables with updated_at
CREATE TRIGGER trg_organisasi_updated   BEFORE UPDATE ON organisasi     FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_pengguna_updated     BEFORE UPDATE ON pengguna       FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_dataset_updated      BEFORE UPDATE ON dataset        FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_statistik_updated    BEFORE UPDATE ON statistik_utama FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_spm_updated          BEFORE UPDATE ON spm_capaian    FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_berita_updated       BEFORE UPDATE ON berita         FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Auto-generate slug from judul
CREATE OR REPLACE FUNCTION generate_slug(judul TEXT)
RETURNS TEXT AS $$
DECLARE
  s TEXT;
BEGIN
  s := LOWER(judul);
  s := regexp_replace(s, '[àáâãäå]', 'a', 'g');
  s := regexp_replace(s, '[èéêë]', 'e', 'g');
  s := regexp_replace(s, '[ìíîï]', 'i', 'g');
  s := regexp_replace(s, '[òóôõö]', 'o', 'g');
  s := regexp_replace(s, '[ùúûü]', 'u', 'g');
  s := regexp_replace(s, '[^a-z0-9\s-]', '', 'g');
  s := regexp_replace(s, '\s+', '-', 'g');
  s := regexp_replace(s, '-+', '-', 'g');
  s := TRIM(BOTH '-' FROM s);
  RETURN s;
END;
$$ LANGUAGE plpgsql;

-- Increment download counter
CREATE OR REPLACE FUNCTION increment_download(p_dataset_id UUID, p_file_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE dataset SET jumlah_unduhan = jumlah_unduhan + 1 WHERE id = p_dataset_id;
  UPDATE dataset_file SET jumlah_dl = jumlah_dl + 1 WHERE id = p_file_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- VIEWS
-- ============================================================

-- Dataset publik (published only)
CREATE VIEW v_dataset_publik AS
SELECT
  d.id, d.slug, d.judul, d.deskripsi, d.tipe, d.status,
  d.periode_awal, d.periode_akhir, d.frekuensi, d.sumber,
  d.tags, d.kecamatan, d.jumlah_unduhan, d.jumlah_view,
  d.format_tersedia, d.thumbnail_url, d.published_at,
  o.nama AS nama_organisasi, o.nama_singkat,
  u.nama AS nama_urusan, u.ikon AS urusan_ikon
FROM dataset d
LEFT JOIN organisasi o ON d.organisasi_id = o.id
LEFT JOIN urusan u ON d.urusan_id = u.id
WHERE d.status = 'published';

-- Statistik dataset per OPD
CREATE VIEW v_statistik_opd AS
SELECT
  o.id, o.nama, o.nama_singkat,
  COUNT(d.id) AS total_dataset,
  COUNT(d.id) FILTER (WHERE d.status = 'published') AS published,
  COUNT(d.id) FILTER (WHERE d.status = 'pending_review') AS pending,
  SUM(d.jumlah_unduhan) AS total_unduhan,
  MAX(d.updated_at) AS last_update,
  ROUND(100.0 * COUNT(d.id) FILTER (WHERE d.status = 'published') / NULLIF(COUNT(d.id), 0), 1) AS pct_published
FROM organisasi o
LEFT JOIN dataset d ON d.organisasi_id = o.id
GROUP BY o.id, o.nama, o.nama_singkat;

-- ============================================================
-- SEED DATA AWAL
-- ============================================================

-- Urusan utama
INSERT INTO urusan (kode, nama, ikon, urutan) VALUES
  ('01', 'Pendidikan', '🎓', 1),
  ('02', 'Kesehatan', '🏥', 2),
  ('03', 'Pekerjaan Umum & Penataan Ruang', '🏗️', 3),
  ('04', 'Perumahan & Kawasan Permukiman', '🏘️', 4),
  ('05', 'Ketentraman & Ketertiban', '🛡️', 5),
  ('06', 'Sosial', '🤝', 6),
  ('07', 'Tenaga Kerja', '💼', 7),
  ('08', 'Pertanian', '🌾', 8),
  ('09', 'Kelautan & Perikanan', '🌊', 9),
  ('10', 'Perindustrian & Perdagangan', '🏛️', 10),
  ('11', 'Pariwisata & Kebudayaan', '🗺️', 11),
  ('12', 'Energi & Sumber Daya', '⚡', 12),
  ('13', 'Lingkungan Hidup', '🌿', 13),
  ('14', 'Kependudukan & Capil', '📋', 14),
  ('15', 'Pemberdayaan Perempuan', '👩', 15),
  ('16', 'Komunikasi & Informatika', '💻', 16),
  ('17', 'Keuangan Daerah', '💰', 17),
  ('18', 'Perencanaan Pembangunan', '📈', 18);

-- Organisasi contoh
INSERT INTO organisasi (kode, nama, nama_singkat, email) VALUES
  ('01.01', 'Sekretariat Daerah Kabupaten Ngada', 'Setda', 'setda@ngadakab.go.id'),
  ('02.01', 'Badan Perencanaan Pembangunan Daerah', 'Bappeda', 'bappeda@ngadakab.go.id'),
  ('02.02', 'Badan Keuangan dan Aset Daerah', 'BKAD', 'bkad@ngadakab.go.id'),
  ('02.03', 'Badan Kepegawaian dan PSDM', 'BKPSDM', 'bkpsdm@ngadakab.go.id'),
  ('03.01', 'Dinas Pendidikan dan Kebudayaan', 'Disdikbud', 'disdikbud@ngadakab.go.id'),
  ('03.02', 'Dinas Kesehatan', 'Dinkes', 'dinkes@ngadakab.go.id'),
  ('03.03', 'Dinas PUPR', 'PUPR', 'pupr@ngadakab.go.id'),
  ('03.04', 'Dinas Sosial', 'Dinsos', 'dinsos@ngadakab.go.id'),
  ('03.05', 'Dinas Pertanian', 'Distan', 'distan@ngadakab.go.id'),
  ('03.06', 'Dinas Pariwisata', 'Dispar', 'dispar@ngadakab.go.id'),
  ('03.07', 'Dinas Kominfo', 'Kominfo', 'kominfo@ngadakab.go.id'),
  ('03.08', 'Dinas Kelautan dan Perikanan', 'DKP', 'dkp@ngadakab.go.id'),
  ('04.01', 'Badan Pusat Statistik Kab. Ngada', 'BPS Ngada', 'ngada@bps.go.id');

-- Super admin default (password: change_me_asap!)
INSERT INTO pengguna (email, password_hash, nama_lengkap, peran, aktif, email_verified)
VALUES (
  'admin@ngadakab.go.id',
  -- This is bcrypt hash of 'admin123' - CHANGE IN PRODUCTION
  '$2b$12$placeholder_change_in_production_immediately',
  'Super Administrator NGADHU',
  'super_admin',
  true,
  true
);

-- ============================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================

ALTER TABLE dataset ENABLE ROW LEVEL SECURITY;
ALTER TABLE pengguna ENABLE ROW LEVEL SECURITY;

-- Super admin: full access
CREATE POLICY superadmin_all ON dataset
  USING (
    EXISTS (
      SELECT 1 FROM pengguna p
      WHERE p.id = current_setting('app.current_user_id')::UUID
      AND p.peran = 'super_admin'
    )
  );

-- Operator OPD: only their own org data
CREATE POLICY operator_own_org ON dataset
  USING (
    EXISTS (
      SELECT 1 FROM pengguna p
      WHERE p.id = current_setting('app.current_user_id')::UUID
      AND p.peran IN ('operator_opd', 'admin_opd')
      AND p.organisasi_id = dataset.organisasi_id
    )
  );

-- Public: only published datasets
CREATE POLICY public_read_published ON dataset
  FOR SELECT
  USING (status = 'published');

-- ============================================================
-- COMMENTS (Documentation)
-- ============================================================

COMMENT ON TABLE organisasi IS 'OPD/SKPD Kabupaten Ngada yang mengelola data';
COMMENT ON TABLE dataset IS 'Master dataset yang dikelola oleh OPD, bisa berupa numerik, spasial, atau dokumen';
COMMENT ON TABLE pengguna IS 'Pengguna sistem NGADHU dengan peran berbeda: super_admin, admin_opd, operator_opd, publik';
COMMENT ON TABLE spm_capaian IS 'Capaian Standar Pelayanan Minimal per kecamatan';
COMMENT ON TABLE log_aktivitas IS 'Audit trail semua aktivitas dalam sistem';
COMMENT ON COLUMN dataset.tags IS 'Array tag untuk pencarian dan kategorisasi';
COMMENT ON COLUMN dataset.metadata_json IS 'Field metadata tambahan dalam format JSON';
COMMENT ON COLUMN pengguna.peran IS 'Peran akses: super_admin=full, admin_opd=manage OPD, operator_opd=upload only, publik=read only';

-- ============================================================
-- END OF SCHEMA
-- ============================================================
